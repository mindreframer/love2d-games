-- Class: App 
-- An app is where all the magic happens. :) It contains a 
-- view, the group where all major action happens, as well as the
-- meta view, which persists across views. Only one app may run at
-- a time.
--
-- An app's job is to get things up and running -- most of its logic
-- lives in its onRun handler, but for a simple app, you can also
-- use the onUpdate handler instead of writing a custom <View>.
-- 
-- Once an app has begun running, it may be accessed globally via
-- <the>.app.
--
-- Extends:
--  	<Class>
--
-- Event: onRun
-- 		Called once, when the app begins running.
--
-- Event: onEnterFullscreen
--		Called after entering fullscreen successfully.
--
-- Event: onExitFullscreen
--		Called after exiting fullscreen successfully.

App = Class:extend
{
	-- Property: name
	-- This is shown in the window title bar.
	name = 'Zoetrope',
	
	-- Property: icon
	-- A path to an image to use as the window icon (a 32x32 PNG is recommended).
	-- This doesn't affect the actual executable's icon in the taskbar or dock. 

	-- Property: fps
	-- Maximum frames per second requested. In practice, your
	-- FPS may vary from frame to frame. Every event handler (e.g. onUpdate)
	-- is passed the exact elapsed time in seconds.
	fps = 60,
	
	-- Property: timeScale
	-- Multiplier for elapsed time; 1.0 is normal, 0 is completely frozen.
	timeScale = 1,
	
	-- Property: active
	-- If false, nothing receives update-related events, including the meta view.
	-- These events specifically are onStartFrame, onUpdate, and onEndFrame.
	active = true,

	-- Property: deactivateOnBlur
	-- Should the app automatically set its active property to false when its
	-- window loses focus?
	deactivateOnBlur = true,
	
	-- Property: view
	-- The current <View>. When the app is running, this is also accessible
	-- globally via <the>.view. In order to switch views, you must set this
	-- property, *not* <the>.view.

	-- Property: meta
	-- A <Group> that persists across all views during the app's lifespan.

	-- Property: keys
	-- A <Keys> object that listens to the keyboard. When the app is running, this
	-- is also accessible globally via <the>.keys.

	-- Property: width
	-- The width of the app's canvas in pixels. Changing this value has no effect. To
	-- set this for real, edit conf.lua. This may *not* correspond to the overall
	-- resolution of the window when in fullscreen mode.

	-- Property: height
	-- The height of the window in pixels. Changing this value has no effect. To
	-- set this for real, edit conf.lua. This may *not* correspond to the overall
	-- resolution of the window when in fullscreen mode.

	-- Property: fullscreen
	-- Whether the app is currently running in fullscreen mode. Changing this value
	-- has no effect. To change this, use the enterFullscreen(), exitFullscreen(), or
	-- toggleFullscreen() methods.

	-- Property: inset
	-- The screen coordinates where the app's (0, 0) origin should lie. This is only
	-- used by Zoetrope to either letterbox or pillar fullscreen apps, but there may
	-- be other uses for it.
	inset = { x = 0, y = 0},

	-- internal property: _sleepTime
	-- The amount of time the app intentionally slept for, and should not
	-- be counted against elapsed time.

	-- internal property: _nextFrameTime
	-- Set at the start of a frame to be the next time a frame should be rendered,
	-- in timestamp format. This is used to properly maintain FPS -- see the example
	-- in https://love2d.org/wiki/love.timer.sleep for how this works.

	new = function (self, obj)
		obj = self:extend(obj)

		-- set icon if possible
		
		if self.icon then
			love.graphics.setIcon(Cached:image(self.icon))
		end
	
		-- view containers

		obj.meta = obj.meta or Group:new()
		obj.view = obj.view or View:new()		
		
		-- input

		if love.keyboard then
			obj.keys = obj.keys or Keys:new()
			love.keyboard.setKeyRepeat(0.4, 0.04)
			obj.meta:add(obj.keys)
		end

		if love.mouse then
			obj.mouse = obj.mouse or Mouse:new()
			obj.meta:add(obj.mouse)
		end

		if love.joystick then
			obj.gamepads = {}
			the.gamepads = obj.gamepads
		end

		if obj.numGamepads and obj.numGamepads > 0 then
			for i = 1, obj.numGamepads do
				obj.gamepads[i] = Gamepad:new{ number = i }
				obj.meta:add(obj.gamepads[i])
			end
		end

		-- screen dimensions and state

		obj.width, obj.height, obj.fullscreen = love.graphics.getMode()

		-- housekeeping
		
		the.app = obj
		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: run
	-- Starts the app running. Nothing will occur until this call.
	--
	-- Arguments:
	-- 		none
	-- 
	-- Returns:
	--		nothing

	run = function (self)
		math.randomseed(os.time())

		-- sync the.view

		the.view = self.view

		-- attach debug console

		if DEBUG then
			self.console = DebugConsole:new()
			self.meta:add(self.console)
		end

		-- set up callbacks
		
		love.graphics.setCaption(self.name)
		love.update = function (elapsed) self:update(elapsed) end
		love.draw = function() self:draw() end
		love.focus = function (value) self:onFocus(value) end	

		if self.onRun then self:onRun() end
		self._nextFrameTime = love.timer.getMicroTime()
	end,
	
	-- Method: quit
	-- Quits the application immediately.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	quit = function (self)
		love.event.quit()
	end,

	-- Method: useSysCursor
	-- Shows or hides the system mouse cursor.
	--
	-- Arguments:
	--		value - show the cursor?
	--
	-- Returns:
	--		nothing
	
	useSysCursor = function (self, value)
		if STRICT then
			assert(value == true or value == false,
				   'tried to set system cursor visibility to ' .. type(value))
		end

		love.mouse.setVisible(value)
	end,

	-- Method: enterFullscreen
	-- Enters fullscreen mode. If the app is already in fullscreen, this has no effect.
	-- This tries to use the highest resolution that will not result in distortion, and
	-- adjust the app's offset property to accomodate this.
	--
	-- Arguments:
	--		hint - whether to try to letterbox (vertical black bars) or pillar the app
	--			   (horizontal black bars). You don't need to specify this; the method
	--			   will try to infer based on the aspect ratio of your app.
	--
	-- Returns:
	--		boolean whether this succeeded

	enterFullscreen = function (self, hint)
		if STRICT then
			assert(not self.fullscreen, 'asked to enter fullscreen when already in fullscreen')
		end

		local modes = love.graphics.getModes()

		if not hint then
			if self.width * 9 == self.height * 16 then
				hint = 'letterbox'
			elseif self.width * 3 == self.height * 4 then
				hint = 'pillar'
			end
		end

		-- find the mode with the highest screen area that
		-- matches either width or height, according to our hint

		local bestMode = { area = 0 }

		for _, mode in pairs(modes) do
			mode.area = mode.width * mode.height

			if (mode.area > bestMode.area) and 
			   ((hint == 'letterbox' and mode.width == self.width) or
			    (hint == 'pillar' and mode.height == self.height)) then
					bestMode = mode
			end
		end

		-- if we found a match, switch to it

		if bestMode.width then
			love.graphics.setMode(bestMode.width, bestMode.height, true)
			self.fullscreen = true

			-- and adjust inset and scissor

			self.inset.x = math.floor((bestMode.width - self.width) / 2)
			self.inset.y = math.floor((bestMode.height - self.height) / 2)
			love.graphics.setScissor(self.inset.x, self.inset.y, self.width, self.height)

			if self.onEnterFullscreen then self:onEnterFullscreen() end
		end

		return self.fullscreen
	end,

	-- Method: exitFullscreen
	-- Exits fullscreen mode. If the app is already windowed, this has no effect.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	exitFullscreen = function (self)
		if STRICT then
			assert(self.fullscreen, 'asked to exit fullscreen when already out of fullscreen')
		end
	
		love.graphics.setMode(self.width, self.height, false)
		love.graphics.setScissor(0, 0, self.width, self.height)
		self.fullscreen = false
		self.inset.x = 0
		self.inset.y = 0
		if self.onExitFullscreen then self:onExitFullscreen() end
	end,

	-- Method: toggleFullscreen
	-- Toggles between windowed and fullscreen mode.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	toggleFullscreen = function (self)
		if self.fullscreen then
			self:exitFullscreen()
		else
			self:enterFullscreen()
		end
	end,

	-- Method: saveScreenshot
	-- Saves a snapshot of the current frame to disk.
	--
	-- Arguments:
	--		filename - filename to save as, image format is implied by suffix.
	--				   This is forced inside the app's data directory,
	--				   see https://love2d.org/wiki/love.filesystem for details.
	--
	-- Returns:
	--		nothing

	saveScreenshot = function (self, filename)
		if not filename then
			error('asked to save screenshot to a nil filename')
		end

		local screenshot = love.graphics.newScreenshot()
		screenshot:encode(filename)
	end,

	-- Method: add
	-- A shortcut for adding a sprite to the app's view.
	--
	-- Arguments:
	--		sprite - sprite to add
	-- 
	-- Returns:
	--		nothing

	add = function (self, sprite)
		self.view:add(sprite)
	end,

	-- Method: remove
	-- A shortcut for removing a sprite from the app's view.
	--
	-- Arguments:
	--		sprite - sprite to remove
	--
	-- Returns: nothing

	remove = function (self, sprite)
		self.view:remove(sprite)
	end,

	update = function (self, elapsed)
		-- set the next frame time right at the start
		self._nextFrameTime = self._nextFrameTime + 1 / self.fps

		elapsed = elapsed - (self._sleepTime or 0)

		local realElapsed = elapsed
		elapsed = elapsed * self.timeScale

		-- sync the.view with our current view
		
		local view = self.view
		if the.view ~= view then the.view = view end

		-- if we are not active at all, sleep for a half-second

		if not self.active then
			love.timer.sleep(0.5)
			self._sleepTime = 0.5
			return
		end

		self._sleepTime = 0

		-- update everyone
		-- app gets precedence, then meta view, then view

		if self.onStartFrame then self:onStartFrame(elapsed) end
		self.meta:startFrame(elapsed)
		
		view:startFrame(elapsed)
		view:update(elapsed)	
		self.meta:update(elapsed)
		if self.onUpdate then self:onUpdate(elapsed) end

		view:endFrame(elapsed)
		self.meta:endFrame(elapsed)
		if self.onEndFrame then self:onEndFrame(elapsed) end
	end,
	
	draw = function (self)
		local inset = self.inset.x ~= 0 or self.inset.y ~= 0

		if inset then love.graphics.translate(self.inset.x, self.inset.y) end
		self.view:draw()
		self.meta:draw()
		if self.onDraw then self:onDraw() end
		if inset then love.graphics.translate(0, 0) end

		-- sleep off any unneeded time to keep up at our FPS

		local now = love.timer.getMicroTime()

		if self._nextFrameTime < now then
			self._nextFrameTime = now
		else
			love.timer.sleep(self._nextFrameTime - now)
		end
	end,

	onFocus = function (self, value)
		if self.deactivateOnBlur then
			self.active = value

			if value then
				love.audio.resume()
			else
				love.audio.pause()
			end
		end
	end,

	__tostring = function (self)
		local result = 'App ('

		if self.active then
			result = result .. 'active'
		else
			result = result .. 'inactive'
		end

		return result .. ', ' .. self.fps .. ' fps, ' .. self.view:count(true) .. ' sprites)'
	end
}
