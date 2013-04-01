-- Class: TextInput
-- This is like a <Text> object, only it listens to user input and
-- adjusts its text property accordingly.
--
-- Extends:
--		<Text>
--
-- Events:
--		onChange - Occurs when the input's text has changed, either by a
--				   user's input or programmtically.
--		onType - Occurs when the input is about to accept input from a key.
--				 This event handler is passed the key about to be inserted.
--				 If the handler returns false, *not* nil or any other value,
--				 then the key is ignored.

TextInput = Text:extend{
	text = '',

	-- Property: listening
	-- Whether the input is currently listening to input.
	listening = true,

	-- Property: caret
	-- This shows the current insert position.
	caret = 0,

	-- Property: blinkRate
	-- How quickly the caret blinks, in seconds.
	blinkRate = 0.5,

	-- internal property: _blinkTimer
	-- Used to keep track of caret blinking.
	_blinkTimer = 0,

	-- internal property: _repeatKey
	-- Used to keep track of what movement key is being held down.
	
	-- internal property: _repeatTimer
	-- Used to keep track of how quickly movement keys repeat.

	-- internal property: _caretHeight
	-- How tall the caret is onscreen, based on the font.

	-- internal property: _caretX
	-- Where to draw the caret, relative to the sprite's x position.

	update = function (self, elapsed)
		if self.listening then
			-- listen to normal keys

			if the.keys.typed ~= '' then
				if (self.onType and self:onType(the.keys.typed)) or not self.onType then
					self.text = string.sub(self.text, 1, self.caret) .. the.keys.typed
								.. string.sub(self.text, self.caret + 1)
					self.caret = self.caret + string.len(the.keys.typed)
				end
			end

			if the.keys:justPressed('home') then
				self.caret = 0
			end

			if the.keys:justPressed('end') then
				self.caret = string.len(self.text)
			end

			-- handle movement keys that repeat
			-- we have to simulate repeat rates manually :(

			local delay, rate = love.keyboard.getKeyRepeat()
			local frameAction

			for _, key in pairs{'backspace', 'delete', 'left', 'right'} do
				if the.keys:pressed(key) then
					if self._repeatKey == key then
						self._repeatTimer = self._repeatTimer + elapsed
						
						-- if we've made it past the maximum delay, then
						-- we reset the timer and take action

						if self._repeatTimer > delay + rate then
							self._repeatTimer = delay
							frameAction = key
						end
					else
						-- we've just started holding down the key

						self._repeatKey = key
						self._repeatTimer = 0
						frameAction = key
					end
				else
					if self._repeatKey == key then
						self._repeatKey = nil
					end
				end
			end

			if frameAction == 'backspace' and self.caret > 0 then
				self.text = string.sub(self.text, 1, self.caret - 1) .. string.sub(self.text, self.caret + 1)
				self.caret = self.caret - 1
			end

			if frameAction == 'delete' and self.caret < string.len(self.text) then
				self.text = string.sub(self.text, 1, self.caret) .. string.sub(self.text, self.caret + 2)
			end

			if frameAction == 'left' and self.caret > 0 then
				self.caret = self.caret - 1
			end

			if frameAction == 'right' and self.caret < string.len(self.text) then
				self.caret = self.caret + 1
			end
		end

		-- update caret position

		if self._set.caret ~= self.caret and self._fontObj then
			self._caretX = self._fontObj:getWidth(string.sub(self.text, 1, self.caret))
			self._caretHeight = self._fontObj:getHeight()
			self._set.caret = self.caret
		end

		-- update caret timer

		self._blinkTimer = self._blinkTimer + elapsed
		if self._blinkTimer > self.blinkRate * 2 then self._blinkTimer = 0 end

		-- call onChange handler as needed

		if self.text ~= self._set.text then
			if self.onChange then self:onChange() end
			self._set.text = self.text
		end

		Text.update(self, elapsed)
	end,

	draw = function (self, x, y)
		if self.visible then
			x = x or self.x
			y = y or self.y

			Text.draw(self, x, y)

			-- draw caret
			
			if (self._repeatKey or self._blinkTimer < self.blinkRate) and
			   (self._caretX and self._caretHeight) then
				love.graphics.setLineWidth(1)
				love.graphics.line(x + self._caretX, y, x + self._caretX, y + self._caretHeight)
			end
		end
	end
}
