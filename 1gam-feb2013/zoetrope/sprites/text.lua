-- Class: Text
-- Shows text onscreen using an outline (e.g. TrueType) or bitmap font. 
-- You can control the width of the text but the height is ignored for
-- display purposes; it will always draw the entirety of its text property.
-- If you do not specify a height and width, the sprite will size itself
-- so that it fits its entire text as a single line.
--
-- By default, an outline font will display as white. To change its color,
-- change its <Sprite.tint> property.
--
-- Extends:
--		<Sprite>

Text = Sprite:extend{
	-- Property: text
	-- Text string to draw.
	text = '',

	-- Property: font
	-- Font to use to draw. See <Cached.font> for possible values here; if
	-- you need more than one value, use table notation. Some example values:
	-- 		* 12 (default font, size 12)
	--		* 'fonts/bitmapfont.png' (bitmap font, default character order)
	--		* { 'fonts/outlinefont.ttf', 12 } (outline font, font size)
	--		* { 'fonts/bitmapfont.ttf', 'ABCDEF' } (bitmap font, custom character order)
	font = 12,

	-- Property: align
	-- Horizontal alignment, see http://love2d.org/wiki/AlignMode.
	-- This affects how lines wrap relative to each other, not how
	-- a single line will wrap relative to the sprite's width and height.
	-- If <wordWrap> is set to false, then this has no effect. 
	align = 'left',

	-- Property: wordWrap
	-- Wrap lines to the width of the sprite?
	wordWrap = true,

	-- private property: used to check whether our font has changed
	_set = { font = {} },

	new = function (self, obj)
		obj = obj or {}
		self:extend(obj)
		obj:updateFont()
		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: getSize
	-- Returns the width and height of the text onscreen as line-wrapped
	-- to the sprite's boundaries. This disregards the sprite's height property.
	--
	-- Arguments:
	--		none
	-- 
	-- Returns:
	--		width, height in pixels
	
	getSize = function (self)
		if self.text == '' then return 0, 0 end

		-- did our font change on us?

		if type(self.font) == 'table' then
			for key, value in pairs(self.font) do
				if self._set.font[key] ~= self.font[key] then
					self:updateFont()
					break
				end
			end
		else
			if self.font ~= self._set.font then
				self:updateFont()
			end
		end

		local _, lines = self._fontObj:getWrap(self.text, self.width)
		local lineHeight = self._fontObj:getHeight()

		return self.width, lines * lineHeight
	end,

	-- Method: centerAround
	-- Centers the text around a position onscreen.
	--
	-- Arguments:
	--		x - center's x coordinate
	--		y - center's y coordinate
	--		centering - can be either 'horizontal', 'vertical', or 'both';
	--					default 'both'
	
	centerAround = function (self, x, y, centering)
		centering = centering or 'both'
		local width, height = self:getSize()

		if width == 0 then return end

		if centering == 'both' or centering == 'horizontal' then
			self.x = x - width / 2
		end

		if centering == 'both' or centering == 'vertical' then
			self.y = y - height / 2
		end
	end,

	-- private method: updateFont
	-- Updates the _fontObj property based on self.font.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	updateFont = function (self)
		if self.font then
			if type(self.font) == 'table' then
				self._fontObj = Cached:font(unpack(self.font))
			else
				self._fontObj = Cached:font(self.font)
			end

			if not self.height then self.height = self._fontObj:getHeight() end
			if not self.width and self.text then self.width = self._fontObj:getWidth(self.text) end
		end
	end,

	draw = function (self, x, y)
		if not self.visible or self.alpha <= 0 or not self.text or not self.font then return end

		x = math.floor(x or self.x)
		y = math.floor(y or self.y)

		if STRICT then
			assert(type(x) == 'number', 'visible text sprite does not have a numeric x property')
			assert(type(y) == 'number', 'visible text sprite does not have a numeric y property')
			assert(type(self.width) == 'number', 'visible text sprite does not have a numeric width property')
			assert(type(self.height) == 'number', 'visible text sprite does not have a numeric height property')
			if not self.text then error('visible text sprite has no text property') end
			if not self.font then error('visible text sprite has no font property') end
		end

		-- did our font change on us?

		if type(self.font) == 'table' then
			for key, value in pairs(self.font) do
				if self._set.font[key] ~= self.font[key] then
					self:updateFont()
					break
				end
			end
		else
			if self.font ~= self._set.font then
				self:updateFont()
			end
		end

		-- rotate and scale

		local scaleX = self.scale * self.distort.x
		local scaleY = self.scale * self.distort.y

		if self.flipX then scaleX = scaleX * -1 end
		if self.flipY then scaleY = scaleY * -1 end

		if scaleX ~= 1 or scaleY ~= 1 or self.rotation ~= 0 then
			love.graphics.push()
			love.graphics.translate(x + self.width / 2, y + self.height / 2)
			love.graphics.scale(scaleX, scaleY)
			love.graphics.rotate(self.rotation)
			love.graphics.translate(- (x + self.width / 2), - (y + self.height / 2))
		end

		-- set color if needed

		local colored = self.alpha ~= 1 or self.tint[1] ~= 1 or self.tint[2] ~= 1 or self.tint[3] ~= 1

		if colored then
			love.graphics.setColor(self.tint[1] * 255, self.tint[2] * 255, self.tint[3] * 255, self.alpha * 255)
		end
		
		love.graphics.setFont(self._fontObj)

		if self.wordWrap then
			love.graphics.printf(self.text, x, y, self.width, self.align)
		else
			love.graphics.print(self.text, x, y)
		end

		-- reset color and rotation
	
		if colored then love.graphics.setColor(255, 255, 255, 255) end

		if scaleX ~= 1 or scaleY ~= 1 or self.rotation ~= 0 then
			love.graphics.pop()
		end
		
		Sprite.draw(self, x, y)
	end,

	__tostring = function (self)
		local result = 'Text (x: ' .. self.x .. ', y: ' .. self.y ..
					   ', w: ' .. self.width .. ', h: ' .. self.height .. ', '

		result = result .. 'font ' .. dump(self.font) .. ', ' .. string.len(self.text) .. ' chars, '

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
