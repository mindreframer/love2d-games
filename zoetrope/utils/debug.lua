-- Class: DebugConsole
-- It can be used to keep track of fps, the position of a sprite,
-- and so on. It only updates when visible.
--
-- This also allows debugging hotkeys -- e.g. you could set it so that
-- pressing Control-Alt-I toggles invincibility of the player sprite.
-- Out of the box:
--		- Control-Alt-F toggles fullscreen
--		- Control-Alt-Q quits the app.
--		- Control-Alt-P deactivates the view.
-- 		- Control-Alt-R reloads all app code from on disk.
--		- Control-Alt-S saves a screenshot to the app's directory --
--		  see https://love2d.org/wiki/love.filesystem for where this is.

DebugConsole = Group:extend{
	-- Property: toggleKey
	-- What key toggles visibility. By default, this is the tab key.
	toggleKey = 'tab',

	-- Property: hotkeyModifiers
	-- A table of modifier keys that must be held in order to activate
	-- a debugging hotkey (set via <addHotkey()>). If you want hotkeys to
	-- activate without having to hold any keys down, set this to nil.
	hotkeyModifiers = {'ctrl'},

	-- Property: watchBasics
	-- If true, the console will automatically start watching the frames
	-- per second and memory usage. Changing this value after the object has
	-- been created has no effect.
	watchBasics = true,

	-- Property: watchWidth
	-- How wide the sidebar, where watch values are displayed, should be.
	watchWidth = 150,

	-- Property: inputHistory
	-- A table of previously-entered commands.
	inputHistory = {},

	-- Property: inputHistoryIndex
	-- Which history entry, if any, we are displaying.
	inputHistoryIndex = 1,

	-- Property: bg
	-- The background <Fill> used to darken the view.

	-- Property: log
	-- The <Text> sprite showing recent lines in the log.

	-- Property: watchList
	-- The <Text> sprite showing the state of all watched variables.

	-- Property: input
	-- The <TextInput> that the user types into to enter commands.

	-- Property: prompt
	-- The <Text> sprite that shows a > in front of commands.

	-- internal property: _bindings
	-- Keeps track of debugging hotkeys.

	new = function (self, obj)
		local width = the.app.width
		local height = the.app.height

		obj = self:extend(obj)
		
		obj.visible = false
		obj._watches = {}
		obj._hotkeys = {}

		obj.fill = Fill:new{ x = 0, y = 0, width = width, height = height, fill = {0, 0, 0, 200} }
		obj:add(obj.fill)

		obj.log = Text:new{ x = 4, y = 4, width = width - self.watchWidth - 8, height = height - 8, text = '' }
		obj:add(obj.log)

		obj.watchList = Text:new{ x = width - self.watchWidth - 4, y = 4,
								   width = self.watchWidth - 8, height = height - 8, text = '', wordWrap = false }
		obj:add(obj.watchList)

		obj.prompt = Text:new{ x = 4, y = 0, width = 100, text = '>' }
		obj:add(obj.prompt)

		local inputIndent = obj.log._fontObj:getWidth('>') + 4
		obj.input = TextInput:new{
			x = inputIndent, y = 0, width = the.app.width,
			active = false,
			onType = function (self, char)
				return char ~= the.console.toggleKey
			end
		}
		obj:add(obj.input)

		-- some default behavior

		obj:addHotkey('f', function() the.app:toggleFullscreen() end)
		obj:addHotkey('p', function()
			the.view.active = not the.view.active
			if the.view.active then
				the.view:tint()
			else
				the.view:tint(0, 0, 0, 200)
			end
		end)
		obj:addHotkey('q', love.event.quit)
		if debugger then obj:addHotkey('r', debugger.reload) end
		obj:addHotkey('s', function() the.app:saveScreenshot('screenshot.png') end)
		
		if obj.watchBasics then
			obj:watch('FPS', 'love.timer.getFPS()')
			obj:watch('Memory', 'math.floor(collectgarbage("count") / 1024) .. "M"')
		end

		-- hijack print function
		-- this is nasty to debug if it goes wrong, be careful

		obj._oldPrint = print
		print = function (...)
			for _, value in pairs{...} do
				obj.log.text = obj.log.text .. tostring(value) .. ' '
			end

			obj.log.text = obj.log.text .. '\n'
			obj._updateLog = true
			obj._oldPrint(...)
		end

		the.console = obj
		if obj.onNew then obj.onNew() end
		return obj
	end,

	-- Method: watch
	-- Adds an expression to be watched.
	--
	-- Arguments:
	--		label - string label
	--		expression - expression to evaluate as a string

	watch = function (self, label, expression)
		table.insert(self._watches, { label = label,
									  func = loadstring('return ' .. expression) })
	end,

	-- Method: addHotkey
	-- Adds a hotkey to execute a function. This hotkey will require
	-- holding down whatever modifiers are set in <hotkeyModifiers>.
	--
	-- Arguments:
	--		key - key to trigger the hotkey
	--		func - function to run. This will receive the key that
	--			   was pressed, so you can re-use functions (i.e. 
	--			   the 1 key loads level 1, the 2 key loads level 2).
	--
	-- Returns:
	--		nothing

	addHotkey = function (self, key, func)
		table.insert(self._hotkeys, { key = key, func = func })
	end,

	-- Method: execute
	-- Safely executes a string of code and prints the result.
	--
	-- Arguments:
	--		code - string code to execute
	--
	-- Returns:
	--		string result

	execute = function (self, code)
		if string.sub(code, 1, 1) == '=' then
			code = 'print (' .. string.sub(code, 2) .. ')'
		end

		local func, err = loadstring(code)

		if func then
			local ok, result = pcall(func)

			if not ok then
				print('Error, ' .. tostring(result) .. '\n')
			else
				print('')
			end

			return tostring(result)
		else
			print('Syntax error, ' .. string.gsub(tostring(err), '^.*:', '') .. '\n')
		end
	end,

	-- Method: show
	-- Shows the debug console.
	-- 
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	show = function (self)
		self.visible = true
		self.input.active = true
	end,

	-- Method: hide
	-- Hides the debug console.
	-- 
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	hide = function (self)
		self.visible = false
		self.input.active = false
	end,

	update = function (self, elapsed)
		-- listen for visibility key

		if the.keys:justPressed(self.toggleKey) then
			self.visible = not self.visible
			self.input.active = self.visible
		end

		-- listen for hotkeys

		local modifiers = (self.hotkeyModifiers == nil)

		if not modifiers then
			modifiers = true

			for _, key in pairs(self.hotkeyModifiers) do
				if not the.keys:pressed(key) then
					modifiers = false
					break
				end
			end
		end

		if modifiers then
			for _, hotkey in pairs(self._hotkeys) do
				if the.keys:justPressed(hotkey.key) then
					hotkey.func(hotkey.key)
				end
			end
		end

		if self.visible then
			-- update watches

			self.watchList.text = ''
			
			for _, watch in pairs(self._watches) do
				local ok, value = pcall(watch.func)
				if not ok then value = nil end

				self.watchList.text = self.watchList.text .. watch.label .. ': ' .. tostring(value) .. '\n'
			end

			-- update log

			if self._updateLog then
				local maxHeight = the.app.height - 20
				local _, height = self.log:getSize()

				while height > maxHeight do
					self.log.text = string.gsub(self.log.text, '^.-\n', '') 
					_, height = self.log:getSize()
				end

				self.prompt.y = height + 4
				self.input.y = height + 4
				self._updateLog = false
			end

			-- handle special keys at the console

			if the.keys:pressed('ctrl') and the.keys:justPressed('a') then
				self.input.caret = 0
			end

			if the.keys:pressed('ctrl') and the.keys:justPressed('e') then
				self.input.caret = string.len(self.input.text)
			end

			if the.keys:pressed('ctrl') and the.keys:justPressed('k') then
				self.input.caret = 0
				self.input.text = ''
			end

			if the.keys:justPressed('up') and self.inputHistoryIndex > 1 then
				-- save what the user was in the middle of typing

				self.inputHistory[self.inputHistoryIndex] = self.input.text

				self.input.text = self.inputHistory[self.inputHistoryIndex - 1]
				self.input.caret = string.len(self.input.text)
				self.inputHistoryIndex = self.inputHistoryIndex - 1
			end

			if the.keys:justPressed('down') and self.inputHistoryIndex < #self.inputHistory then
				self.input.text = self.inputHistory[self.inputHistoryIndex + 1]
				self.input.caret = string.len(self.input.text)
				self.inputHistoryIndex = self.inputHistoryIndex + 1
			end

			if the.keys:justPressed('return') then
				print('>' .. self.input.text)
				self:execute(self.input.text)
				table.insert(self.inputHistory, self.inputHistoryIndex, self.input.text)

				while #self.inputHistory > self.inputHistoryIndex do
					table.remove(self.inputHistory)
				end

				self.inputHistoryIndex = self.inputHistoryIndex + 1
				self.input.text = ''
				self.input.caret = 0
			end
		end

		Group.update(self, elapsed)
	end
}

-- Function: debugger.reload
-- Resets the entire app and forces all code to be reloaded from 
-- on disk. via https://love2d.org/forums/viewtopic.php?f=3&t=7965
-- 
-- Arguments:
--		none
--
-- Returns:
--		nothing

if debugger then
	debugger.reload = function()
		if DEBUG then
			-- create local references to needed variables
			-- because we're about to blow the global scope away

			local initialGlobals = debugger._initialGlobals
			local initialPackages = debugger._initialPackages
			
			-- reset global scope

			for key, _ in pairs(_G) do
				_G[key] = initialGlobals[key]
			end

			-- reload main file and restart

			for key, _ in pairs(package.loaded) do
				if not initialPackages[key] then
					package.loaded[key] = nil
				end
			end

			require('main')
			love.load()
		end
	end
end
