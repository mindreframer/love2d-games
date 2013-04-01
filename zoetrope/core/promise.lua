-- Class: Promise
-- This is a way to communicate with an asynchronous function call that
-- is modeled after the Promises/A CommonJS spec <http://wiki.commonjs.org/wiki/Promises/A>.
-- The main difference is that instead of then(), it uses andThen() as the connecting
-- method name, since 'then' is a reserved word in Lua.
--
-- A function that is asynchronous in nature can return a new Promise instance.
-- The caller can then register callbacks via the promise's andThen() method, which
-- are called when the asynchronous operation completes (in the parlance, fulfilling
-- the promise) or fails (rejecting the promise). A promise can have many callbacks attached
-- by repeatedly calling andThen() on the same promise. All callbacks will fire simultaneously.
--
-- If a promise has already failed or been fulfilled, you can still call andThen() on it.
-- If this happens, the callbacks trigger immediately. This may not be what you expect, so
-- beware.
--
-- This implementation is based heavily on RSVP.js <https://github.com/tildeio/rsvp.js>.

Promise = Class:extend
{
	-- Property: state
	-- Current state of the promise: may be 'unfulfilled', 'fulfilled', or 'failed'.
	-- This property should be considered read-only. Use resolve() or reject() to change
	-- the state of the promise.
	state = 'unfulfilled',

	-- private property: _onFulfills
	-- A table of functions to call when the promise is fulfilled.
	_onFulfills = {},
	
	-- private property: _onFails
	-- A table of functions to call when the promise is rejected.
	_onFails = {},

	-- private property: _onProgresses
	-- A function that receives calls periodically as progress is made towards completing
	-- the promise. It's up to whatever asynchronous function that owns the promise to make
	-- these calls; promises do not call this by themselves.
	_onProgresses = {},

	-- Method: fulfill
	-- Fulfills the promise, notifying all registered fulfillment handlers (e.g. via <andThen>).
	--
	-- Arguments:
	--		Multiple, will be passed to fulfillment handlers
	--
	-- Returns:
	--		nothing

	fulfill = function (self, ...)
		if STRICT then
			assert(self.state == 'unfulfilled', 'Tried to fulfill a promise whose state is ' .. (self.state or 'nil'))
		end

		self.state = 'fulfilled'
		self._fulfilledWith = {...}

		for _, func in pairs(self._onFulfills) do
			func(...)
		end
	end,
	
	-- Method: progress
	-- Notifies all registered progress handlers.
	--
	-- Arguments:
	--		Multiple, will be passed to progress handlers
	--
	-- Returns:
	--		nothing
	
	progress = function (self, ...)
		if STRICT then
			assert(self.state == 'unfulfilled', 'Tried to send progress on a promise whose state is ' .. (self.state or 'nil'))
		end

		for _, func in pairs(self._onProgresses) do
			func(...)
		end
	end,

	-- Method: fail
	-- Fails the promise, notifying all registered failure handlers (e.g. via <andThen>).
	--
	-- Arguments:
	--		errorMessage - error message, will be passed to failure handlers
	--
	-- Returns:
	--		nothing
	
	fail = function (self, errorMessage)
		if STRICT then
			assert(self.state == 'unfulfilled', 'Attempted to fail a promise whose state is ' .. (self.state or 'nil'))
		end

		self.state = 'failed'
		self._failedWith = errorMessage

		for _, func in pairs(self._onFails) do
			func(errorMessage)
		end
	end,

	-- Method: andThen
	-- Registers fulfillment, failure, and progress handlers for a promise. This can be called
	-- repeatedly to register several handlers on the same event, and all handlers are optional.
	--
	--
	-- Arguments:
	--		onFulfill - function to call when this promise is fulfiled
	--		onFail - function to call when this promise fails
	--		onProgress - function to call when this promise makes progress
	--
	-- Returns:
	--		A new promise that fulfills or fails after the passed onFulfill or onFail handlers
	--		complete. If either a onFulfill or onFail returns a promise, this new promise will
	--		not fulfill or fail until that returned promise does the same. This way, you can chain
	--		together promises.

	andThen = function (self, onFulfill, onFail, onProgress)
		if STRICT then
			local tFulfill = type(onFulfill)
			local tFail = type(onFail)
			local tProgress = type(onProgress)

			assert(tFulfill == 'function' or tFulfill == 'nil', 'Fulfilled handler for promise is not a function')
			assert(tFail == 'function' or tFail == 'nil', 'Failed handler for promise is not a function')
			assert(tProgress == 'function' or tProgress == 'nil', 'Progress handler for promise is not a function')
		end

		local childPromise = Promise:new()

		-- we add entries, even with nil callbacks, so that
		-- fulfillments and failures propagate up the chain

		table.insert(self._onFulfills, function (...)
			childPromise:_complete(onFulfill, 'fulfill', ...)
		end)

		table.insert(self._onFails, function (errorMessage)
			childPromise:_complete(onFail, 'fail', errorMessage)
		end)

		table.insert(self._onProgresses, onProgress)

		-- immediately trigger callbacks if we are already fulfilled or failed

		if self.state == 'fulfilled' and onFulfill then
			if self._fulfilledWith then
				childPromise:_complete(onFulfill, 'fulfill', unpack(self._fulfilledWith))
			else
				childPromise:_complete(onFulfill, 'fulfill')
			end
		end

		if self.state == 'failed' and onFail then
			childPromise:_complete(onFail, 'fail', self._failedWith)
		end

		return childPromise
	end,

	-- Method: andAlways
	-- A shortcut method that adds both fulfillment and failure handlers
	-- to a promise.
	--
	-- Arguments:
	--		func - function to call when this promise is fulfiled or failed
	--
	-- Returns:
	--		A new promise that fulfills or fails after the handler
	--		complete. If the handler returns a promise, this new promise will
	--		not fulfill or fail until that returned promise does the same.
	--		This way, you can chain together promises.

	andAlways = function (self, func)
		self:andThen(func, func)
	end,

	-- internal method: _complete
	-- Handles fulfilling or failing a promise so that chaining works properly,
	-- and that errors are passed to the promise's fail method. 
	--
	-- arguments:
	--		callback - callback to call, can be nil
	--		defaultAction - if unsure as to whether to fulfill or fail, use this
	--		... - values to pass to the callback

	_complete = function (self, callback, defaultAction, ...)
		local results, errorMessage

		-- call the callback

		if callback then
			results = { pcall(callback, ...) }

			-- if the call succeeded, peel off that flag

			if results[1] then
				table.remove(results, 1)
			else
				errorMessage = results[2]
				results = nil
			end
		end

		-- if the callback returned a new promise, we link the current promise to it

		if results and type(results[1]) == 'table' and results[1].instanceOf and results[1]:instanceOf(Promise) then
			results[1]:andThen(function(...) self:fulfill(...) end, function(errorMessage) self:fail(errorMessage) end)

		-- if the callback returned a regular value, fulfill the promise

		elseif callback and results then
			if #results > 1 then
				self:fulfill(unpack(results))
			else
				self:fulfill(results[1])
			end

		-- if there was any kind of error, fail

		elseif errorMessage then
			self:fail(errorMessage)

		-- and if we did not actually have a callback, fall back to the default action
		-- (we have to simulate colon calling syntax here)

		else
			self[defaultAction](self, ...)
		end
	end
}
