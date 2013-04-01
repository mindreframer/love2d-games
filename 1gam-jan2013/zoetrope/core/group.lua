-- Class: Group
-- A group is a set of sprites. Groups can be used to
-- implement layers or keep categories of sprites together.
--
-- Extends:
--		<Class>
--
-- Event: onDraw
-- Called after all member sprites are drawn onscreen.
--
-- Event: onUpdate
-- Called once each frame, with the elapsed time since the last frame in seconds.
--
-- Event: onBeginFrame
-- Called once each frame like onUpdate, but guaranteed to fire before any others' onUpdate handlers.
--
-- Event: onEndFrame
-- Called once each frame like onUpdate, but guaranteed to fire after all others' onUpdate handlers.

Group = Class:extend
{
	-- Property: active
	-- If false, none of its member sprites will receive update-related events.
	active = true,

	-- Property: visible
	-- If false, none of its member sprites will be drawn.
	visible = true,

	-- Property: solid
	-- If false, nothing will collide against this group. This does not prevent
	-- collision checking against individual sprites in this group, however.
	solid = true,

	-- Property: sprites
	-- A table of member sprites, in drawing order.
	sprites = {},

	-- Property: timeScale
	-- Multiplier for elapsed time; 1.0 is normal, 0 is completely frozen.
	timeScale = 1,

	-- Property: translate
	-- This table's x and y properties shift member sprites' positions when drawn.
	-- To draw sprites at their normal position, set both x and y to 0.
	translate = { x = 0, y = 0 },
	
	-- Property: translateScale
	-- This table's x and y properties multiply member sprites'
	-- positions, which you can use to simulate parallax scrolling. To draw
	-- sprites at their normal position, set both x and y to 1.
	translateScale = { x = 1, y = 1 },

	-- Property: gridSize
	-- The size, in pixels, of the grid used for collision detection.
	-- This partitions off space so that collision checks only need to do real
	-- checks against a few sprites at a time. If you notice collision detection
	-- taking a long time, changing this number may help.
	gridSize = 50,

	-- Method: add
	-- Adds a sprite to the group.
	--
	-- Arguments:
	--		sprite - <Sprite> to add
	--
	-- Returns:
	--		nothing

	add = function (self, sprite)
		assert(sprite, 'asked to add nil to a group')
		assert(sprite ~= self, "can't add a group to itself")
	
		if STRICT and self:contains(sprite) then
			local info = debug.getinfo(2, 'Sl')
			print('Warning: adding a sprite to a group it already belongs to (' ..
				  info.short_src .. ' line ' .. info.currentline .. ')')
		end

		table.insert(self.sprites, sprite)
	end,

	-- Method: remove
	-- Removes a sprite from the group. If the sprite is
	-- not in the group, this does nothing.
	-- 
	-- Arguments:
	-- 		sprite - <Sprite> to remove
	-- 
	-- Returns:
	-- 		nothing

	remove = function (self, sprite)
		for i, spr in ipairs(self.sprites) do
			if spr == sprite then
				table.remove(self.sprites, i)
				return
			end
		end
		
		if STRICT then
			local info = debug.getinfo(2, 'Sl')
			print('Warning: asked to remove a sprite from a group it was not a member of (' ..
				  info.short_src .. ' line ' .. info.currentline .. ')')
		end
	end,

	-- Method: collide
	-- Collides all solid sprites in the group with another sprite or group.
	-- This calls the <Sprite.onCollide> event handlers on all sprites that
	-- collide with the same arguments <Sprite.collide> does.
	--
	-- It's often useful to collide a group with itself, e.g. myGroup:collide(myGroup).
	-- This checks for collisions between the sprites that make up the group.
	--
	-- Arguments:
	-- 		other - <Sprite> or <Group> to collide with, default self
	-- 
	-- Returns:
	--		boolean, whether any collision was detected
	--
	-- See Also:
	--		<Sprite.collide>

	collide = function (self, other)
		other = other or self

		if STRICT then
			assert(other:instanceOf(Group) or other:instanceOf(Sprite), 'asked to collide non-group/sprite ' ..
				   type(other))
		end

		if not self.solid or not other then return false end
		local hit = false

		if other.sprites then
			local grid = self:grid()
			local gridSize = self.gridSize

			for _, othSpr in pairs(other.sprites) do
				local startX = math.floor(othSpr.x / gridSize)
				local endX = math.floor((othSpr.x + othSpr.width) / gridSize)
				local startY = math.floor(othSpr.y / gridSize)
				local endY = math.floor((othSpr.y + othSpr.height) / gridSize)

				for x = startX, endX do
					if grid[x] then
						for y = startY, endY do
							if grid[x][y] then
								for _, spr in pairs(grid[x][y]) do
									hit = spr:collide(othSpr) or hit
								end
							end
						end
					end
				end
			end
		else
			for _, spr in pairs(self.sprites) do
				hit = spr:collide(other) or hit
			end
		end

		return hit
	end,

	-- Method: displace
	-- Displaces a sprite or group by all solid sprites in this group.
	--
	-- Arguments:
	-- 		other - <Sprite> or <Group> to collide with
	-- 		xHint - force horizontal displacement in one direction, uses direction constants, optional
	--		yHint - force vertical displacement in one direction, uses direction constants, optional
	-- 
	-- Returns:
	--		nothing
	--
	-- See Also:
	--		<Sprite.displace>

	displace = function (self, other, xHint, yHint)
		if STRICT then
			assert(other:instanceOf(Group) or other:instanceOf(Sprite), 'asked to displace non-group/sprite ' ..
				   type(other))
		end

		if not self.solid or not other then return false end

		if other.sprites then
			local grid = self:grid()
			local gridSize = self.gridSize

			for _, othSpr in pairs(other.sprites) do
				local startX = math.floor(othSpr.x / gridSize)
				local endX = math.floor((othSpr.x + othSpr.width) / gridSize)
				local startY = math.floor(othSpr.y / gridSize)
				local endY = math.floor((othSpr.y + othSpr.height) / gridSize)

				for x = startX, endX do
					if grid[x] then
						for y = startY, endY do
							if grid[x][y] then
								for _, spr in pairs(grid[x][y]) do
									spr:displace(othSpr)
								end
							end
						end
					end
				end
			end
		else
			for _, spr in pairs(self.sprites) do
				spr:displace(other)
			end
		end
	end,

	-- Method: setEffect
	-- Sets a pixel effect to use while drawing sprites in this group.
	-- See https://love2d.org/wiki/PixelEffect for details on how pixel
	-- effects work. After this call, the group's effect property will be
	-- set up so you can send variables to it. Only one pixel effect can
	-- be active on a group at a time.
	--
	-- Arguments:
	--		filename - filename of effect source code; if nil, this
	--				   clears any existing pixel effect.
	--		effectType - either 'screen' (applies the effect to the entire
	--					 group once, via an offscreen canvas), or 'sprite'
	--					 (applies to the effect to each individual draw operation).
	--					 Screen effects use more resources, but certain effects
	--					 need to work on the entire screen to be effective.
	--
	-- Returns:
	--		whether the effect was successfully created

	setEffect = function (self, filename, effectType)
		effectType = effectType or 'screen'

		if love.graphics.isSupported('pixeleffect') and
		   (effectType == 'sprite' or love.graphics.isSupported('canvas'))then
			if filename then
				self.effect = love.graphics.newPixelEffect(Cached:text(filename))
				self.effectType = effectType
			else
				self.effect = nil
			end

			return true
		else
			return false
		end
	end,

	-- Method: count
	-- Counts how many sprites are in this group.
	-- 
	-- Arguments:
	--		subgroups - include subgroups?
	-- 
	-- Returns:
	--		integer count

	count = function (self, subgroups)
		if subgroups then
			local count = 0

			for _, spr in pairs(self.sprites) do
				if spr:instanceOf(Group) then
					count = count + spr:count(true)
				else
					count = count + 1
				end
			end

			return count
		else
			return #self.sprites
		end
	end,

	-- Method: die
	-- Makes the group totally inert. It will not receive
	-- update events, draw anything, or be collided.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	-- 		nothing

	die = function (self)
		self.active = false
		self.visible = false
		self.solid = false
	end,

	-- Method: revive
	-- Makes this group completely active. It will receive
	-- update events, draw itself, and be collided.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	-- 		nothing

	revive = function (self)
		self.active = true
		self.visible = true
		self.solid = true
	end,

	-- Method: contains
	-- Returns whether this group contains a sprite.
	--
	-- Arguments:
	--		sprite - sprite to look for
	--		recurse - check subgroups? defaults to true
	--
	-- Returns:
	--		boolean

	contains = function (self, sprite, recurse)
		if recurse ~= false then recurse = true end

		for _, spr in pairs(self.sprites) do
			if spr == sprite then return true end

			if recurse and spr:instanceOf(Group) and spr:contains(sprite) then
				return true
			end
		end

		return false
	end,

	-- Method: grid
	-- Creates a table indexed by x and y dimensions, with each
	-- cell a table of sprites that touch this grid element. For
	-- example, with a grid size of 50, a sprite at (10, 10) that 
	-- is 50 pixels square would be in the grid at [0][0], [1][0],
	-- [0][1], and [1][1].
	--
	-- This can be used to speed up work that involves checking
	-- for sprites near each other, e.g. collision detection.
	--
	-- Arguments:
	--		existing - existing grid table to add sprites into,
	--				   optional. Anything you pass must have
	--				   used the same size as the current call.
	--
	-- Returns:
	--		table

	grid = function (self, existing)
		local result = existing or {}
		local size = self.gridSize

		for _, spr in pairs(self.sprites) do
			if spr.sprites then
				local oldSize = spr.gridSize
				spr.gridSize = self.gridSize
				result = spr:grid(result)
				spr.gridSize = oldSize
			else
				local startX = math.floor(spr.x / size)
				local endX = math.floor((spr.x + spr.width) / size)
				local startY = math.floor(spr.y / size)
				local endY = math.floor((spr.y + spr.height) / size)

				for x = startX, endX do
					if not result[x] then result[x] = {} end

					for y = startY, endY do
						if not result[x][y] then result[x][y] = {} end
						table.insert(result[x][y], spr)
					end
				end
			end
		end

		return result
	end,

	-- passes startFrame events to member sprites

	startFrame = function (self, elapsed)
		if not self.active then return end
		elapsed = elapsed * self.timeScale
		if self.onStartFrame then self:onStartFrame(elapsed) end
		
		for _, spr in pairs(self.sprites) do
			if spr.active then spr:startFrame(elapsed) end
		end
	end,

	-- passes update events to member sprites

	update = function (self, elapsed)
		if not self.active then return end
		elapsed = elapsed * self.timeScale
		if self.onUpdate then self:onUpdate(elapsed) end

		for _, spr in pairs(self.sprites) do
			if spr.active then spr:update(elapsed) end
		end
	end,

	-- passes endFrame events to member sprites

	endFrame = function (self, elapsed)
		if not self.active then return end
		elapsed = elapsed * self.timeScale
		if self.onEndFrame then self:onEndFrame(elapsed) end

		for _, spr in pairs(self.sprites) do
			if spr.active then spr:endFrame(elapsed) end
		end
	end,

	-- Method: draw
	-- Draws all visible member sprites onscreen.
	--
	-- Arguments:
	--		x - x offset in pixels
	--		y - y offset in pixels

	draw = function (self, x, y)
		if not self.visible then return end
		x = x or self.translate.x
		y = y or self.translate.y
		
		local scrollX = x * self.translateScale.x
		local scrollY = y * self.translateScale.y
		local appWidth = the.app.width
		local appHeight = the.app.height

		if self.effect then
			if self.effectType == 'screen' then
				if not self._canvas then self._canvas = love.graphics.newCanvas() end
				self._canvas:clear()
				love.graphics.setCanvas(self._canvas)
			elseif self.effectType == 'sprite' then
				love.graphics.setPixelEffect(self.effect)
			end
		end
		
		for _, spr in pairs(self.sprites) do	
			if spr.visible then
				if spr.translate then
					spr:draw(spr.translate.x + scrollX, spr.translate.y + scrollY)
				elseif spr.x and spr.y and spr.width and spr.height then
					local sprX = spr.x + scrollX
					local sprY = spr.y + scrollY

					if sprX < appWidth and sprX + spr.width > 0 and
					   sprY < appHeight and sprY + spr.height > 0 then
						spr:draw(sprX, sprY)
					end
				else
					spr:draw(scrollX, scrollY)
				end
			end
		end
			
		if self.onDraw then self:onDraw() end

		if self.effect then
			if self.effectType == 'screen' then
				love.graphics.reset()
				love.graphics.setPixelEffect(self.effect)
				love.graphics.setCanvas()
				love.graphics.draw(self._canvas)
			end

			love.graphics.setPixelEffect()
		end
	end,

	__tostring = function (self)
		local result = 'Group ('

		if self.active then
			result = result .. 'active'
		else
			result = result .. 'inactive'
		end

		if self.visible then
			result = result .. ', visible'
		else
			result = result .. ', invisible'
		end

		if self.solid then
			result = result .. ', solid'
		else
			result = result .. ', not solid'
		end

		return result .. ', ' .. self:count(true) .. ' sprites)'
	end
}
