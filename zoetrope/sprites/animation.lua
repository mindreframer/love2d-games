-- Class: Animation
-- An animation displays a sequence of frames. If you do not specify
-- a width and height for the sprite, it will size itself so that
-- it is a square, where each side is as tall as the source image's height.
--
--
-- Event: onEndSequence
-- Called whenever an animation sequence ends. It is passed the name
-- of the sequence that just ended.
-- 
-- Extends:
--		<Sprite>

Animation = Sprite:extend{
	-- Property: paused
	-- Set this to true to freeze the animation on the current frame.
	paused = false,

	-- Property: sequences
	-- A lookup table of sequences. Each one is stored by name and has
	-- the following properties:
	-- * name - string name for the sequence.
	-- * frames - table of frames to display. The first frame in the sheet is at index 1.
	-- * fps - frames per second.
	-- * loops - does the animation loop? defaults to true
	sequences = {},

	-- Property: image
	-- A string filename to the image to use as a sprite strip. A sprite
	-- strip can have multiple rows of frames.

	-- Property: currentSequence
	-- A reference to the current animation sequence table.

	-- Property: currentName
	-- The name of the current animation sequence.

	-- Property: currentFrame
	-- The current frame being displayed; starts at 1.

	-- Property: frameIndex
	-- Numeric index of the current frame in the current sequence; starts at 1.

	-- Property: frameTimer
	-- Time left before the animation changes to the next frame in seconds.
	-- Normally you shouldn't need to change this directly.

	-- private property: used to check whether the source image
	-- for our quad is up-to-date
	_set = {},

	-- private property imageObj: actual Image instance used to draw
	-- this is normally set via the image property, but you may set it directly
	-- so long as you never change that image property afterwards.

	new = function (self, obj)
		obj = obj or {}
		self:extend(obj)
		obj:updateQuad()

		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: play 
	-- Begins playing an animation in the sprite's library.
	-- If the animation is already playing, this has no effect.
	--
	-- Arguments:
	--		name - name of the animation
	--
	-- Returns:
	--		nothing

	play = function (self, name)
		if self.currentName == name and not self.paused then
			return
		end
		
		assert(self.sequences[name], 'no animation sequence named "' .. name .. '"')
		
		self.currentName = name
		self.currentSequence = self.sequences[name]
		self.frameIndex = 0
		self.frameTimer = 0
		self.paused = false
	end,

	-- Method: freeze
	-- Freezes the animation on the specified frame.
	--
	-- Arguments:
	--		* index - integer frame index relative to the entire sprite sheet,
	--				  starts at 1. If omitted, this freezes the current frame.
	--				  If there is no current frame, this freezes on the first frame.
	--
	-- Returns:
	--		nothing

	freeze = function (self, index)
		if self.currentSequence then
			index = index or self.currentSequence[self.frameIndex]
		end
		
		index = index or self.currentFrame or 1

		if self._set.image ~= self.image then
			self:updateQuad()
		end

		self.currentFrame = index
		self:updateFrame(index)
		self.paused = true
	end,

	-- private method: updateQuad
	-- sets up the sprite's quad property based on the image;
	-- needs to be called whenever the sprite's image property changes.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	updateQuad = function (self)
		if self.image then 
			self._imageObj = Cached:image(self.image)
			if not self.width then self.width = self._imageObj:getHeight() end
			if not self.height then self.height = self.width end

			self._quad = love.graphics.newQuad(0, 0, self.width, self.height,
											  self._imageObj:getWidth(), self._imageObj:getHeight())
			self._imageWidth = self._imageObj:getWidth()
			self._set.image = self.image
		end
	end,

	-- private method: updateFrame
	-- changes the sprite's quad property based on the current frame;
	-- needs to be called whenever the sprite's currentFrame property changes.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	updateFrame = function (self)
		assert(type(self.currentFrame) == 'number', "current frame is not a number")
		assert(self.image, "asked to set the frame of a nil image")

		if self._set.image ~= self.image then
			self:updateQuad()
		end

		local frameX = (self.currentFrame - 1) * self.width
		local viewportX = frameX % self._imageWidth
		local viewportY = self.height * math.floor(frameX / self._imageWidth)
		self._quad:setViewport(viewportX, viewportY, self.width, self.height)
	end,

	update = function (self, elapsed)
		-- move the animation frame forward

		if self.currentSequence and not self.paused then
			self.frameTimer = self.frameTimer - elapsed
			
			if self.frameTimer <= 0 then
				self.frameIndex = self.frameIndex + 1

				if self.frameIndex > #self.currentSequence.frames then
					if self.onEndSequence then self:onEndSequence(self.currentName) end

					if self.currentSequence.loops ~= false then
						self.frameIndex = 1
					else
						self.frameIndex = self.frameIndex - 1
						self.paused = true
					end
				end

				self.currentFrame = self.currentSequence.frames[self.frameIndex]
				self:updateFrame()
				self.frameTimer = 1 / self.currentSequence.fps
			end
		end

		Sprite.update(self, elapsed)
	end,

	draw = function (self, x, y)
		x = math.floor(x or self.x)
		y = math.floor(y or self.y)

		if STRICT then
			assert(type(x) == 'number', 'visible animation does not have a numeric x property')
			assert(type(y) == 'number', 'visible animation does not have a numeric y property')
			assert(type(self.width) == 'number', 'visible animation does not have a numeric width property')
			assert(type(self.height) == 'number', 'visible animation does not have a numeric height property')
		end

		if not self.visible or not self.image or self.alpha <= 0 then return end
		
		-- if our image changed, update the quad
		
		if self._set.image ~= self.image then
			self:updateQuad()
		end
		
		-- set color if needed

		local colored = self.alpha ~= 1 or self.tint[1] ~= 1 or self.tint[2] ~= 1 or self.tint[3] ~= 1

		if colored then
			love.graphics.setColor(self.tint[1] * 255, self.tint[2] * 255, self.tint[3] * 255, self.alpha * 255)
		end

		-- draw the quad

		local scaleX = self.scale * self.distort.x
		local scaleY = self.scale * self.distort.y

		if self.flipX then scaleX = scaleX * -1 end
		if self.flipY then scaleY = scaleY * -1 end
			
		love.graphics.drawq(self._imageObj, self._quad, x + self.width / 2, y + self.height / 2, self.rotation,
							scaleX, scaleY, self.width / 2, self.height / 2)
		
		-- reset color
		
		if colored then
			love.graphics.setColor(255, 255, 255, 255)
		end
		
		Sprite.draw(self, x, y)
	end,

	__tostring = function (self)
		local result = 'Animation (x: ' .. self.x .. ', y: ' .. self.y ..
					   ', w: ' .. self.width .. ', h: ' .. self.height .. ', '

		if self.currentName then
			result = result .. 'playing ' .. self.currentName .. ', '
		end

		result = result .. ' frame ' .. self.currentFrame .. ', '

		if self.active then
			result = result .. 'active, '
		else
			result = result .. 'inactive, '
		end

		if self.visible then
			result = result .. 'visible, '
		else
			result = result .. 'invisible, '
		end

		if self.solid then
			result = result .. 'solid'
		else
			result = result .. 'not solid'
		end

		return result .. ')'
	end
}
