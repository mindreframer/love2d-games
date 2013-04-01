-- Class: Emitter
-- An emitter periodically emits sprites with varying properties --
-- for example, velocity. These are set with the emitter's min and
-- max properties. For example, you could set the x velocity of
-- particles to range between -100 and 100 with these statements:
--
-- > emitter.min.velocity.x = -100
-- > emitter.max.velocity.x = 100
--
-- Properties can descend two levels deep at most.
--
-- You can specify any property in min and max, and it will be set
-- on sprites as they are emitted. Mins and maxes can only be used
-- with numeric properties.
--
-- Particles when emitted will appear at a random spot inside the
-- rectangle defined by the emitter's x, y, width, and height
-- properties.
--
-- Because emitters are <Group> subclasses, all particles appear at
-- the same z index onscreen. This also means that setting active,
-- visible, and solid properties on the emitter will affect all particles.
--
-- Any sprite may be used as a particle. When a sprite is added as
-- a particle, its die() method is called. When emitted, revive() is
-- called on it. If you want a particle to remain invisible after being
-- emitted, for example, then write an onEmit method on your sprite to do so.
--
-- Extends:
--		<Group>
--
-- Event: onEmit
-- Called on both the parent emitter and the emitted sprite
-- when it is emitted. If multiple particles are emitted at once, the
-- emitter will receive multiple onEmit events.

Emitter = Group:extend{
	-- Property: x
	-- The x coordinate of the upper-left corner of the rectangle where particles may appear.
	x = 0,

	-- Property: y
	-- The y coordinate of the upper-left corner of the rectangle where particles may appear.
	y = 0,

	-- Property: width
	-- The width of the rectangle where particles may appear.
	width = 0,

	-- Property: height
	-- The height of the retangle where particles may appear.
	height = 0,

	-- Property: emitting
	-- Boolean whether this emitter is actually emitting particles.
	emitting = true,
	
	-- Property: period
	-- How long, in seconds, the emitter should wait before emitting.
	period = math.huge,

	-- Property: emitCount
	-- How many particles to emit at once.
	emitCount = 1,

	-- Property: min
	-- Minimum numeric properties for particles.
	min = {},

	-- Property: max
	-- Maximum numeric properties for particles.
	max = {},

	-- Property: emitTimer
	-- Used to keep track of when the next emit should take place.
	-- To restart the timer, set it to 0. To immediately force a particle
	-- to be emitted, set it to the emitter's period property. (Although
	-- you should probably call emit() instead.)
	emitTimer = 0,

	-- which particle to emit next
	_emitIndex = 1,

	-- Method: loadParticles
	-- Creates a number of particles to use based on a class.
	-- This calls new() on the particle class with no arguments.
	--
	-- Arguments:
	--		class - class object to instantiate
	--		count - number of particles to create
	--
	-- Returns:
	--		nothing

	loadParticles = function (self, class, count)
		for i = 1, count do
			self:add(class:new())
		end
	end,

	-- Method: emit
	-- Emits one or more particles. This ignores the emitting property.
	-- If no particles are ready to be emitted, this does nothing. 
	--
	-- Arguments:
	--		count - how many particles to emit, default 1
	--
	-- Returns:
	--		emitted particle

	emit = function (self, count)
		count = count or 1

		if #self.sprites == 0 then return end

		for i = 1, count do
			local emitted = self.sprites[self._emitIndex]
			self._emitIndex = self._emitIndex + 1
			
			if self._emitIndex > #self.sprites then self._emitIndex = 1 end

			-- revive it and set properties

			emitted:revive()
			emitted.x = math.random(self.x, self.x + self.width)
			emitted.y = math.random(self.y, self.y + self.height)

			for key, _ in pairs(self.min) do
				if self.max[key] then
					-- simple case, single value
					
					if type(self.min[key]) == 'number' then
						emitted[key] = self.min[key] + math.random() * (self.max[key] - self.min[key])
					end

					-- complicated case, table

					if type(self.min[key]) == 'table' then
						for subkey, _ in pairs(self.min[key]) do
							if type(self.min[key][subkey]) == 'number' then
								emitted[key][subkey] = self.min[key][subkey] + math.random() *
													   (self.max[key][subkey] - self.min[key][subkey])
							end
						end
					end
				end
			end
	
			if emitted.onEmit then emitted:onEmit(self) end
			if self.onEmit then self:onEmit(emitted) end
		end
	end,

	-- Method: explode
	-- This emits many particles simultaneously then immediately stops any further
	-- emissions. If you want to keep the emitter going, call emitter.emit(#emitter.sprites).
	--
	-- Arguments:
	--		count - number of particles to emit, defaults to all of them
	--
	-- Returns:
	--		nothing

	explode = function (self, count)
		count = count or #self.sprites

		self:emit(count)
		self.emitting = false
	end,

	-- Method: extinguish
	-- This immediately calls die() on all particles, then the emitter itself.
	-- This differs from a regular die() call in that if you call revive() on the
	-- emitter later, particles will not appear where they last left off.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	extinguish = function (self)
		for _, spr in pairs(self.sprites) do
			spr:die()
		end

		self:die()
	end,

	update = function (self, elapsed)
		if not self.active then return end

		if self.emitting then
			self.emitTimer = self.emitTimer + elapsed

			if self.emitTimer > self.period then
				self:emit(self.emitCount)
				self.emitTimer = self.emitTimer - self.period
			end
		end

		Group.update(self, elapsed)
	end,

	add = function (self, sprite)
		sprite:die()
		Group.add(self, sprite)
	end,

	__tostring = function (self)
		local result = 'Emitter (x: ' .. self.x .. ', y: ' .. self.y ..
					   ', w: ' .. self.width .. ', h: ' .. self.height .. ', '

		if self.emitting then
			result = result .. 'emitting with period ' .. self.period .. ', '
		else
			result = result .. 'not emitting, '
		end

		return result
	end
}
