-- Class: Mouse
-- This tracks the state of the mouse, i.e. its coordinates onscreen
-- and if a button was just pressed or released this frame.
--
-- See http://love2d.org/wiki/MouseConstant for a list of mouse button names.
--
-- Extends:
--		<Sprite>

Mouse = Sprite:extend{
	visible = false,

	-- private property: _thisFrame
	-- what buttons are pressed this frame
	-- if you are interested in this, use allPressed() instead
	_thisFrame = {},

	-- private property: lastFrame
	-- what mouse buttons were pressed last frame
	_lastFrame = {},
	
	new = function (self, obj)
		obj = self:extend(obj)
		the.mouse = obj
		love.mousepressed = function (x, y, button) obj:mousePressed(button) end
		love.mousereleased = function (x, y, button) obj:mouseReleased(button) end
		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: pressed
	-- Are *any* of the buttons passed held down this frame?
	--
	-- Arguments:
	--		string button descriptions passed as individual arguments;
	--		if none are passed, the left mouse button is assumed
	--
	-- Returns:
	-- 		boolean

	pressed = function (self, ...)
		local buttons = {...}

		if #buttons == 0 then buttons[1] = 'l' end
	
		for _, value in pairs(buttons) do
			if STRICT then
				assert(type(value) == 'string', 'all mouse buttons are strings; asked to check a ' .. type(value))
			end

			if self._thisFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Method: justPressed
	-- Are *any* of the buttons passed pressed for the first time this frame?
	--
	-- Arguments:
	--		string button descriptions passed as individual arguments;
	--		if none are passed, the left mouse button is assumed
	--
	-- Returns:
	-- 		boolean

	justPressed = function (self, ...)
		local buttons = {...}

		if #buttons == 0 then buttons[1] = 'l' end
	
		for _, value in pairs(buttons) do
			if STRICT then
				assert(type(value) == 'string', 'all mouse buttons are strings; asked to check a ' .. type(value))
			end

			if self._thisFrame[value] and not self._lastFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Method: released
	-- Are *all* of the buttons passed not held down this frame?
	--
	-- Arguments:
	--		string button descriptions passed as individual arguments;
	--		if none are passed, the left mouse button is assumed
	--
	-- Returns:
	-- 		boolean

	released = function (self, ...)
		local buttons = {...}
		if #buttons == 0 then buttons[1] = 'l' end
	
		for _, value in pairs(buttons) do
			if STRICT then
				assert(type(value) == 'string', 'all mouse buttons are strings; asked to check a ' .. type(value))
			end

			if self._thisFrame[value] then
				return false
			end
		end
		
		return true
	end,

	-- Method: justReleased
	-- Are *any* of the buttons passed released after being held last frame?
	--
	-- Arguments:
	--		string button descriptions passed as individual arguments;
	--		if none are passed, the left mouse button is assumed
	--
	-- Returns:
	-- 		boolean

	justReleased = function (self, ...)
		local buttons = {...}
		if #buttons == 0 then buttons[1] = 'l' end	
	
		for _, value in pairs(buttons) do
			if STRICT then
				assert(type(value) == 'string', 'all mouse buttons are strings; asked to check a ' .. type(value))
			end

			if self._lastFrame[value] and not self._thisFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Method: allPressed
	-- Returns all buttons currently pressed this frame.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		string button descriptions; if nothing is pressed, nil

	allPressed = function (self)
		local result = {}

		for key, value in pairs(self._thisFrame) do
			if value then table.insert(result, key) end
		end
		
		return unpack(result)
	end,

	-- Method: allJustPressed
	-- Returns all buttons just pressed this frame.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		string button descriptions; if nothing is just pressed, nil

	allJustPressed = function (self)
		local result = {}

		for key, value in pairs(self._thisFrame) do
			if value and not self._lastFrame[key] then table.insert(result, key) end
		end
		
		return unpack(result)
	end,

	-- Method: allJustReleased
	-- Returns all buttons just released this frame.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		string buttons descriptions; if nothing is just pressed, nil

	allJustPressed = function (self)
		local result = {}

		for key, value in pairs(self._thisFrame) do
			if not value and self._lastFrame[key] then table.insert(result, key) end
		end
		
		return unpack(result)
	end,

	mousePressed = function (self, button)
		self._thisFrame[button] = true
	end,

	mouseReleased = function (self, button)
		self._thisFrame[button] = false
	end,

	endFrame = function (self, elapsed)
		for key, value in pairs(self._thisFrame) do
			self._lastFrame[key] = value
		end
	
		self.x = love.mouse.getX() - the.app.inset.x
		self.y = love.mouse.getY() - the.app.inset.y

		Sprite.endFrame(self)
	end,

	update = function() end
}
