-- Class: Tween
-- A tween transitions a property from one state to another
-- in in-game time. A tween instance is designed to manage
-- many of these transitions at once, in fact. In order for it
-- to work properly, it must receive update events, so it must
-- be added somewhere in the current view or app. If you are using
-- the <View> class, this is already done for you.

Tween = Sprite:extend{
	tweens = {},
	visible = false,
	active = false,
	solid = false,

	-- Property: easers
	-- These are different methods of easing a tween, and
	-- can be set via the ease property of an individual tween.
	-- They should be referred to by their key name, not the property
	-- (e.g. 'linear', no Tweener.easers.linear).
	-- See http://www.gizma.com/easing/ for details.
	
	easers =
	{
		linear = function (elapsed, start, change, duration)
			return change * elapsed / duration + start
		end,
		
		quadIn = function (elapsed, start, change, duration)
			elapsed = elapsed / duration
			return change * elapsed * elapsed + start
		end,
		
		quadOut = function (elapsed, start, change, duration)
			elapsed = elapsed / duration
			return - change * elapsed * (elapsed - 2) + start
		end,
		
		quadInOut = function (elapsed, start, change, duration)
			elapsed = elapsed / (duration / 2)
			
			if (elapsed < 1) then
				return change / 2 * elapsed * elapsed + start
			else
				elapsed = elapsed - 1
				return - change / 2 * (elapsed * (elapsed - 2) - 1) + start
			end
		end
	},
	
	-- Method: reverseForever
	-- A utility function; if set via <Promise.andAfter()> for an individual
	-- tween, it reverses the tween that just happened. Use this to get a tween
	-- to repeat back and forth indefinitely (e.g. to have something glow).
	
	reverseForever = function (tween, tweener)
		tween.to = tween.from
		tweener:start(tween.target, tween.property, tween.to, tween.duration, tween.ease):andThen(Tween.reverseForever)
	end,

	-- Method: reverseOnce
	-- A utility function; if set via <Promise.andAfter()> for an individual
	-- tween, it reverses the tween that just happened-- then stops the tween after that.
	
	reverseOnce = function (tween, tweener)
		tween.to = tween.from
		tweener:start(tween.target, tween.property, tween.to, tween.duration, tween.ease)
	end,

	-- Method: start
	-- Begins a tweened transition, overriding any existing tween.
	--
	-- Arguments:
	--		target - target object
	--		property - Usually, this is a string name of a property of the target object.
	--				   You may also specify a table of getter and setter methods instead,
	--				   i.e. { myGetter, mySetter }. In either case, the property or functions
	--				   must work with either number values, or tables of numbers.
	--		to - destination value, either number or color table
	--		duration - how long the tween should last in seconds, default 1
	--		ease - function name (in Tween.easers) to use to control how the value changes, default 'linear'
	--
	-- Returns:
	--		A <Promise> that is fulfilled when the tween completes. If the object is already
	--		in the state requested, the promise resolves immediately. The tween object returns two
	--		things to the promise: a table of properties about the tween that match the arguments initially
	--		passed, and a reference to the Tween that completing the tween.

	start = function (self, target, property, to, duration, ease)
		duration = duration or 1
		ease = ease or 'linear'
		local propType = type(property)
		
		if STRICT then
			assert(type(target) == 'table' or type(target) == 'userdata', 'target must be a table or userdata')
			assert(propType == 'string' or propType == 'number' or propType == 'table', 'property must be a key or table of getter/setter methods')
			
			if propType == 'string' or propType == 'number' then
				assert(target[property], 'no such property ' .. tostring(property) .. ' on target') 
			end

			assert(type(duration) == 'number', 'duration must be a number')
			assert(self.easers[ease], 'easer ' .. ease .. ' is not defined')
		end

		-- check for an existing tween for this target and property
		
		for i, existing in ipairs(self.tweens) do
			if target == existing.target and property == existing.property then
				if to == existing.to then
					return existing.promise
				else
					table.remove(self.tweens, i)
				end
			end
		end
		
		-- add it

		tween = { target = target, property = property, propType = propType, to = to, duration = duration, ease = ease }
		tween.from = self:getTweenValue(tween)
		tween.type = type(tween.from)
		
		-- calculate change; if it's trivial, skip the tween
		
		if tween.type == 'number' then
			tween.change = tween.to - tween.from
			if math.abs(tween.change) < NEARLY_ZERO then
				return Promise:new{ state = 'fulfilled', _resolvedWith = { tween, self } }
			end
		elseif tween.type == 'table' then
			tween.change = {}
			
			local skip = true
			
			for i, value in ipairs(tween.from) do
				tween.change[i] = tween.to[i] - tween.from[i]
				
				if math.abs(tween.change[i]) > NEARLY_ZERO then
					skip = false
				end
			end
			
			if skip then
				return Promise:new{ state = 'fulfilled', _resolvedWith = { tween, self } }
			end
		else
			error('tweened property must either be a number or a table of numbers, is ' .. tween.type)
		end
			
		tween.elapsed = 0
		tween.promise = Promise:new()
		table.insert(self.tweens, tween)
		self.active = true
		return tween.promise
	end,

	-- Method: status
	-- Returns how much time is left for a particular tween to run.
	--
	-- Arguments:
	--		target - target object
	--		property - name of the property being tweened, or getter
	--				   (as set in the orignal <start()> call)
	--
	-- Returns:
	--		Either the time left in the tween, or nil if there is
	--		no tween matching the arguments passed.

	status = function (self, target, property)
		for _, t in pairs(self.tweens) do
			if t.target == target then
				if t.property == property or (type(t.property) == 'table' and t.property[1] == property) then
					return t.duration - t.elapsed
				end
			end
		end

		return nil
	end,

	-- Method: stop
	-- Stops a tween. The promise associated with it will be failed.
	--
	-- Arguments:
	--		target - tween target
	-- 		property - name of property being tweened, or getter (as set in the original <start()> call); 
	--				   if omitted, stops all tweens on the target
	--
	-- Returns:
	--		nothing

	stop = function (self, target, property)
		local found = false

		for i, tween in ipairs(self.tweens) do
			if tween.target == target and (tween.property == property or
			   (type(tween.property) == 'table' and tween.property[1] == property) or
			   not property) then
			   	found = true
				tween.promise:fail('Tween stopped')
				table.remove(self.tweens, i)
				end
		end

		if STRICT and not found then
			local info = debug.getinfo(2, 'Sl')
			print('Warning: asked to stop a tween, but no active tweens match it (' ..
				  info.short_src .. ', line ' .. info.currentline .. ')')
		end
	end,

	update = function (self, elapsed)	
		for i, tween in ipairs(self.tweens) do
			self.active = true
			tween.elapsed = tween.elapsed + elapsed
			
			if tween.elapsed >= tween.duration then
				-- tween is completed
				
				self:setTweenValue(tween, tween.to)
				table.remove(self.tweens, i)
				tween.promise:fulfill(tween, self)
			else
				-- move tween towards finished state
				
				if tween.type == 'number' then
					self:setTweenValue(tween, self.easers[tween.ease](tween.elapsed,
									   tween.from, tween.change, tween.duration))
				elseif tween.type == 'table' then
					local now = {}
					
					for i, value in ipairs(tween.from) do
						now[i] = self.easers[tween.ease](tween.elapsed, tween.from[i],
														 tween.change[i], tween.duration)
					end
					
					self:setTweenValue(tween, now)
				end
			end
		end
		
		self.active = (#self.tweens > 0)
	end,

	getTweenValue = function (self, tween)
		if tween.propType == 'string' or tween.propType == 'number' then
			return tween.target[tween.property]
		else
			return tween.property[1](tween.target)
		end
	end,

	setTweenValue = function (self, tween, value)
		if tween.propType == 'string' or tween.propType == 'number' then
			tween.target[tween.property] = value
		else
			tween.property[2](tween.target, value)
		end
	end,

	__tostring = function (self)
		local result = 'Tween ('

		if self.active then
			result = result .. 'active, '
			result = result .. #self.tweens .. ' tweens running'
		else
			result = result .. 'inactive'
		end

		return result .. ')'
	end
}
