-- Class: Keys
-- This tracks the state of the keyboard, i.e. if a key
-- was just pressed or released this frame. You can look
-- up a key either by its name or its Unicode number.
-- Not all keys sensed have Unicode equivalents (e.g. modifiers
-- like Control or Alt).
--
-- Only one Keys object can be active at one time. The one currently
-- listening to the keyboard can be accessed globally via <the>.keys.
--
-- See http://love2d.org/wiki/KeyConstant for a list of key names.
-- This class aliases modifiers for you, so that if you want to check
-- whether either the left or right Control key is pressed, you can check
-- on 'ctrl' instead of both 'lctrl' and 'rctrl'.
--
-- Extends:
--		<Sprite>

Keys = Sprite:extend{
	visible = false,

	-- Property: typed
	-- This is literally what is being typed during the current frame.
	-- e.g. if the user holds the shift key and presses the 'a' key,
	-- this will be set to 'A'. Consult <allPressed()> if you
	-- want to know what specific keys are being pressed.

	typed = '',

	-- private property: _thisFrame
	-- what keys are pressed this frame
	-- if you are interested in this, use allPressed() instead

	_thisFrame = {},

	-- private property: _lastFrame
	-- what keys were pressed last frame
	
	_lastFrame = {},
	
	new = function (self, obj)
		obj = self:extend(obj)
		the.keys = obj
		love.keypressed = function (key, unicode) obj:keyPressed(key, unicode) end
		love.keyreleased = function (key, unicode) obj:keyReleased(key, unicode) end
		if obj.onNew then obj:onNew() end
		return obj
	end,
	
	-- Method: pressed
	-- Are *any* of the keys passed held down this frame?
	--
	-- Arguments:
	--		string key descriptions passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	pressed = function (self, ...)
		local keys = {...}
		for _, value in pairs(keys) do
			if STRICT then
				assert(type(value) == 'string', 'all keys are strings; asked to check a ' .. type(value))
			end

			if self._thisFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Method: justPressed
	-- Are *any* of the keys passed pressed for the first time this frame?
	--
	-- Arguments:
	--		string key descriptions passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	justPressed = function (self, ...)
		local keys = {...}

		for _, value in pairs(keys) do
			if STRICT then
				assert(type(value) == 'string', 'all keys are strings; asked to check a ' .. type(value))
			end

			if self._thisFrame[value] and not self._lastFrame[value] then
				return true
			end
		end
		
		return false
	end,

	-- Method: released
	-- Are *all* of the keys passed not held down this frame?
	-- 
	-- Arguments:
	--		string key descriptions passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	released = function (self, ...)
		local keys = {...}

		for _, value in pairs(keys) do
			if STRICT then
				assert(type(value) == 'string', 'all keys are strings; asked to check a ' .. type(value))
			end

			if self._thisFrame[value] then
				return false
			end
		end
		
		return true
	end,

	-- Method: justReleased
	-- Are *any* of the keys passed released after being held last frame?
	--
	-- Arguments:
	--		string key descriptions passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	justReleased = function (self, ...)
		local keys = {...}

		for _, value in pairs(keys) do
			if STRICT then
				assert(type(value) == 'string', 'all keys are strings; asked to check a ' .. type(value))
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
	--		string key descriptions; if nothing is pressed, nil

	allPressed = function (self)
		local result = {}

		for key, value in pairs(self._thisFrame) do
			if value then table.insert(result, key) end
		end
		
		return unpack(result)
	end,

	-- Method: allJustPressed
	-- Returns all keys just pressed this frame.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		string key descriptions; if nothing is just pressed, nil

	allJustPressed = function (self)
		local result = {}

		for key, value in pairs(self._thisFrame) do
			if value and not self._lastFrame[key] then table.insert(result, key) end
		end
		
		return unpack(result)
	end,

	-- Method: allJustReleased
	-- Returns all keys just released this frame.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		string key descriptions; if nothing is just pressed, nil

	allJustReleased = function (self)
		local result = {}

		for key, value in pairs(self._thisFrame) do
			if not value and self._lastFrame[key] then table.insert(result, key) end
		end
		
		return unpack(result)
	end,

	-- Connects to the love.keypressed callback

	keyPressed = function (self, key, unicode)
		self._thisFrame[key] = true
		if unicode and unicode >= 0x20 and unicode ~= 127 and unicode < 0x3000 then
			self.typed = self.typed .. string.char(unicode)
		end

		-- aliases for modifiers

		if key == 'rshift' or key == 'lshift' or
		   key == 'rctrl' or key == 'lctrl' or
		   key == 'ralt' or key == 'lalt' or
		   key == 'rmeta' or key == 'lmeta' or
		   key == 'rsuper' or key == 'lsuper' then
			self._thisFrame[string.sub(key, 2)] = true
		end
	end,

	-- Connects to the love.keyreleased callback

	keyReleased = function (self, key, unicode)
		self._thisFrame[key] = false

		-- aliases for modifiers

		if key == 'rshift' or key == 'lshift' or
		   key == 'rctrl' or key == 'lctrl' or
		   key == 'ralt' or key == 'lalt' or
		   key == 'rmeta' or key == 'lmeta' or
		   key == 'rsuper' or key == 'lsuper' then
			self._thisFrame[string.sub(key, 2)] = false
		end
	end,

	endFrame = function (self, elapsed)
		for key, value in pairs(self._thisFrame) do
			self._lastFrame[key] = value
		end

		self.typed = ''
		Sprite.endFrame(self, elapsed)
	end,

	update = function() end
}
