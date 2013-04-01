-- Class: Button
-- A button is a composite sprite made of two things: a label (e.g.
-- some text like "OK") and a background (e.g. a graphic or fill).
-- A button's dimensions, e.g. its clickable area, is determined by
-- its background's dimensions.
--
-- The x and y position of the label sprite is relative to the button's
-- top-left corner. The background sprite is always drawn at the button's
-- top-left corner. The label is always drawn on top of the background.
--
-- Extends:
--		<Sprite>
--
-- Event: onMouseOver
-- Called each frame the mouse is over the button.
--
-- Event: onMouseEnter
-- Called during the first frame the user moves the mouse over the button.
--
-- Event: onMouseExit
-- Called during the first frame the user moves the mouse off of the button.
--
-- Event: onMouseDown
-- Called during the first frame the user is clicking the mouse when it is over the button.
--
-- Event: onMouseUp
-- Called when the user releases the mouse over the button.

Button = Sprite:extend{
	-- Property: background
	-- The background <Sprite> of the button.

	-- Propetrty: label
	-- The label <Sprite> of the button.

	-- Property: mouseOver
	-- Tracks whether the user's mouse is over the button this frame.
	mouseOver = false,

	-- Property: beingClicked
	-- Tracks whether the user has the mouse button down and started
	-- clicking the mouse inside the button.
	beingClicked = false,

	draw = function (self, x, y)
		local bg = self.background
		local label = self.label

		x = x or self.x
		y = y or self.y

		if bg then bg:draw(x + bg.x, y + bg.y) end
		if label then label:draw(x + label.x, y + label.y) end
		Sprite.draw(self, x, y)
	end,

	update = function (self, elapsed)
		local bg = self.background
		local label = self.label

		-- keep dimensions in sync with background

		if bg then
			self.width = bg.width
			self.height = bg.height
		end

		-- call hooks for mouse movement events

		local mouseOver = self:intersects(the.mouse.x, the.mouse.y)

		if mouseOver then self:callHook('onMouseOver') end
		if mouseOver and not self.mouseOver then self:callHook('onMouseEnter') end
		if not mouseOver and self.mouseOver then self:callHook('onMouseExit') end

		-- check for clicks

		if mouseOver and the.mouse:justPressed() then
			self.beingClicked = true
			self:callHook('onMouseDown')
		end

		if self.beingClicked and the.mouse:justReleased() then
			if mouseOver then
				self:callHook('onMouseUp')
			else
				if label and label.onMouseUp then label:onMouseUp() end
				if bg and bg.onMouseUp then label:onMouseUp() end
				if self.onMouseUp then self:onMouseUp() end
			end

			self.beingClicked = false
		end

		self.mouseOver = mouseOver

		-- let label and background update

		if bg then bg:update(elapsed) end
		if label then label:update(elapsed) end

		Sprite.update(self, elapsed)
	end,

	callHook = function (self, name)
		local label = self.label
		local bg = self.background

		if label and label[name] then label[name](label) end
		if bg and bg[name] then bg[name](bg) end
		if self[name] then self[name](self) end
	end
}
