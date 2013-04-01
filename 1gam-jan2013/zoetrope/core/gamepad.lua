-- Class: Gamepad
-- This represents a single gamepad connected to the user's computer. This offers the 
-- usual functions to check on the status of buttons; you can also inspect other
-- controls, like analog joysticks, by checking properties like <axes> and <hats>.
-- (Incidentally, a hat is used for things like a digital control pad.) 
--
-- Normally, gamepad buttons are indexed by number. This class also adds virtual buttons
-- named 'left', 'right', 'up', 'down'. This consults the first two analog axes
-- and the first hat of the gamepad (if they exist) to set these.
--
-- A gamepad is only recognized if it is plugged in when LOVE starts up. There's no way
-- to tell if the user has unplugged it after that; it just acts inert. A gamepad object
-- with no connected hardware at startup will exist and respond to calls like <pressed()>,
-- but it will always return false. You can tell it's unplugged because its active property
-- will be false, and its name will always be 'NO DEVICE CONNECTED'.
--
-- Extends:
--		<Sprite>

Gamepad = Sprite:extend
{
	-- Property: number
	-- The index of the gamepad, starting at 1.

	-- Property: name
	-- The name of the gamepad, e.g. "XBox Controller".

	-- Property: numAxes
	-- The number of available axes, e.g. for analog controls.

	-- Property: numBalls
	-- The number of available balls.

	-- Property: numButtons
	-- The number of available buttons.

	-- Property: numHats
	-- The number of available hats, e.g. digital movement controls.

	-- Property: axes
	-- The state of all analog axes on the gamepad, indexed by number.
	-- Values range from -1 to 1, where 0 is completely neutral.

	-- Property: balls
	-- The amount of motion by a each ball on the gamepad, indexed by number.
	-- Not sure what the range of values is here.

	-- Property: hats
	-- The state of each hat on the gamepad, indexed by number. Each one has
	-- one of these values: https://love2d.org/wiki/JoystickConstant

	-- Property: deadZone
	-- Any motion by an analog control (from 0 to 1) less than this value is
	-- ignored when simulating digital controls.

	deadZone = 0.1,

	-- private property: _thisFrame
	-- what keys are pressed this frame
	-- if you are interested in this, use allPressed() instead

	_thisFrame = {},

	-- private property: _lastFrame
	-- what buttons were pressed last frame

	_lastFrame = {},

	new = function (self, obj)
		obj = self:extend(obj)
		assert(type(obj.number) == 'number', 'must set a gamepad number')

		obj.axes = {}
		obj.balls = {}
		obj.hats = {}

		if obj.number <= love.joystick.getNumJoysticks() then
			if not love.joystick.isOpen(obj.number) then love.joystick.open(obj.number) end
			obj.name = love.joystick.getName(obj.number)
			obj.numAxes = love.joystick.getNumAxes(obj.number)
			obj.numBalls = love.joystick.getNumBalls(obj.number)
			obj.numButtons = love.joystick.getNumButtons(obj.number)
			obj.numHats = love.joystick.getNumHats(obj.number)

			-- set initial values for axes and balls
			-- hat values are strings so nil comparisons are safe

			for i = 1, obj.numAxes do
				obj.axes[i] = 0
			end

			for i = 1, obj.numBalls do
				obj.balls[i] = { x = 0, y = 0 }
			end
		else
			obj.name = 'NO DEVICE CONNECTED'
			obj.numAxes = 0
			obj.numBalls = 0
			obj.numButtons = 0
			obj.numHats = 0
		end

		love.joystickpressed = Gamepad._dispatchPress
		love.joystickreleased = Gamepad._dispatchRelease
		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: pressed
	-- Are *any* of the buttons passed held down this frame?
	--
	-- Arguments:
	--		button numbers passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	pressed = function (self, ...)
		local buttons = {...}

		for _, value in pairs(buttons) do
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
	--		button numbers passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	justPressed = function (self, ...)
		local buttons = {...}

		for _, value in pairs(buttons) do
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
	--		button numbers passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	released = function (self, ...)
		local buttons = {...}
	
		for _, value in pairs(buttons) do
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
	--		button numbers passed as individual arguments
	--
	-- Returns:
	-- 		boolean

	justReleased = function (self, ...)
		local buttons = {...}
	
		for _, value in pairs(buttons) do
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
	--		string button descriptions; if nothing is just pressed, nil

	allJustPressed = function (self)
		local result = {}

		for key, value in pairs(self._thisFrame) do
			if not value and self._lastFrame[key] then table.insert(result, key) end
		end
		
		return unpack(result)
	end,

	buttonPressed = function (self, button)
		self._thisFrame[button] = true
	end,

	buttonReleased = function (self, button)
		self._thisFrame[button] = false
	end,

	endFrame = function (self, elapsed)
		-- move button values to the previous frame

		for key, value in pairs(self._thisFrame) do
			self._lastFrame[key] = value
		end

		-- set values

		for i = 1, self.numAxes do
			self.axes[i] = love.joystick.getAxis(self.number, i)
		end

		for i = 1, self.numBalls do
			self.balls[i].x, self.balls[i].y = love.joystick.getBall(self.number, i)
		end

		for i = 1, self.numHats do
			self.hats[i] = love.joystick.getHat(self.number, i)
		end

		-- simulate digital controls

		self._thisFrame['up'] = false
		self._thisFrame['down'] = false
		self._thisFrame['left'] = false
		self._thisFrame['right'] = false

		if self.numHats > 0 then
			local hat = self.hats[1]

			if hat == 'u' then
				self._thisFrame['up'] = true
			elseif hat == 'd' then
				self._thisFrame['down'] = true
			elseif hat == 'l' then
				self._thisFrame['left'] = true
			elseif hat == 'r' then
				self._thisFrame['right'] = true
			elseif hat == 'lu' then
				self._thisFrame['up'] = true
				self._thisFrame['left'] = true
			elseif hat == 'ru' then
				self._thisFrame['up'] = true
				self._thisFrame['right'] = true
			elseif hat == 'ld' then
				self._thisFrame['down'] = true
				self._thisFrame['left'] = true
			elseif hat == 'rd' then
				self._thisFrame['down'] = true
				self._thisFrame['right'] = true
			end
		end

		if self.numAxes > 1 then
			local xAxis = self.axes[1]
			local yAxis = self.axes[2]

			if math.abs(xAxis) > self.deadZone then
				if xAxis < 0 then
					self._thisFrame['left'] = true
				else
					self._thisFrame['right'] = true
				end
			end

			if math.abs(yAxis) > self.deadZone then
				if yAxis < 0 then
					self._thisFrame['up'] = true
				else
					self._thisFrame['down'] = true
				end
			end
		end
	
		Sprite.endFrame(self)
	end,

	-- private method: _dispatchPress
	-- receives a Love joystickpressed callback and hands it off
	-- to the appropriate gamepad.

	_dispatchPress = function (number, button)
		if the.gamepads[number] then
			the.gamepads[number]:buttonPressed(button)
		end
	end,

	-- private method: _dispatchRelease
	-- receives a Love joystickreleased callback and hands it off
	-- to the appropriate gamepad.

	_dispatchRelease = function (number, button)
		if the.gamepads[number] then
			the.gamepads[number]:buttonReleased(button)
		end
	end
}
