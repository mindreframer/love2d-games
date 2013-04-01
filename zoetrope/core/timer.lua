-- Class: Timer
-- A timer allows delayed or periodic execution of a function according
-- to elapsed time in an app. In order for it to work properly, it must
-- receive update events, so it must be added somewhere in the current
-- view or app. If you are using the <View> class, then this is already
-- done for you; one is created as the View's timer property.

Timer = Sprite:extend{
	timers = {},
	visible = false,
	active = false,
	solid = false,

	-- Method: wait

	-- Method: after
	-- Delays a function call after a certain a mount of time.
	--
	-- Arguments:
	--		* delay - how long to wait, in seconds
	--		* func - function to call
	--
	-- Returns:
	--		A <Promise> that is fulfilled after the function is called
	
	after = function (self, delay, func)
		if STRICT then
			assert(type(func) == 'function', 'func property of timer must be a function')
			assert(type(delay) == 'number', 'delay must be a number')

			if delay <= 0 then
				local info = debug.getinfo(2, 'Sl')
				print('Warning: timer delay is ' .. delay .. ', will be triggered immediately (' .. 
					  info.short_src .. ', line ' .. info.currentline .. ')')
			end
		end
		
		self.active = true
		local promise = Promise:new()
		table.insert(self.timers, { func = func, timeLeft = delay, promise = promise })
		return promise
	end,

	-- Method: every
	-- Repeatedly makes a function call. To stop these calls from
	-- happening in the future, you must call stop().
	--
	-- Arguments:
	--		* delay - how often to make the function call, in seconds
	--		* func - function to call
	--
	-- Returns:
	--		nothing
	
	every = function (self, delay, func)
		if STRICT then
			assert(type(func) == 'function', 'func property of timer must be a function')
			assert(type(delay) == 'number', 'delay must be a number')

			if delay <= 0 then
				local info = debug.getinfo(2, 'Sl')
				print('Warning: timer delay is ' .. delay .. ', will be triggered immediately (' .. 
					  info.short_src .. ', line ' .. info.currentline .. ')')
			end
		end
		
		self.active = true
		table.insert(self.timers, { func = func, timeLeft = delay, interval = delay })
	end,

	-- Method: status
	-- Returns how much time is left before a function call is scheduled.
	--
	-- Arguments:
	--		func - the function that is queued
	--
	-- Returns:
	--		the time left until the soonest call matching these arguments,
	--		or nil if there is no call scheduled

	status = function (self, func, bind, arg)
		local result

		for _, t in pairs(self.timers) do
			if t.func == func and (not result or result < t.timeLeft) then
			   result = t.timeLeft
			end
		end

		return result
	end,
	
	-- Method: stop
	-- Stops a timer from executing. The promise belonging to it is failed. 
	-- If there is no function associated with this timer, then this has no effect.
	--
	-- Arguments:
	--		func - function to stop; if omitted, stops all timers
	--
	-- Returns:
	--		nothing

	stop = function (self, func, bind)
		local found = false

		for i, timer in ipairs(self.timers) do
			if not func or timer.func == func then
				if timer.promise then
					timer.promise:fail('Timer stopped')
				end

				table.remove(self.timers, i)
				found = true
			end
		end

		if STRICT and not found then
			local info = debug.getinfo(2, 'Sl')
			print('Warning: asked to stop a timer on a function that was not queued (' ..
				  info.short_src .. ', line ' .. info.currentline .. ')')
		end
	end,

	update = function (self, elapsed)
		for i, timer in ipairs(self.timers) do
			timer.timeLeft = timer.timeLeft - elapsed
			
			if timer.timeLeft <= 0 then
				timer.func()
				
				if timer.promise then
					timer.promise:fulfill()
				end

				if timer.interval then
					timer.timeLeft = timer.interval
					keepActive = true
				else
					table.remove(self.timers, i)
				end
			else
				keepActive = true
			end
		end
		
		self.active = (#self.timers > 0)
	end,

	__tostring = function (self)
		local result = 'Timer ('

		if self.active then
			result = result .. 'active, '
			result = result .. #self.timers .. ' timers running'
		else
			result = result .. 'inactive'
		end

		return result .. ')'
	end
}
