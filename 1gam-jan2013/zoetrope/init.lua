-- copy references to existing globals so that
-- debug.reload() will have a correct initial starting point.

if DEBUG then
	-- remember initial state

	local _initialGlobals = {}
	local _initialPackages = {}

	for key, value in pairs(_G) do
		_initialGlobals[key] = value
	end

	for key, value in pairs(package.loaded) do
		-- it looks as though the type of a module
		-- that is currently being loaded, but hasn't
		-- completed is userdata

		if type(value) ~= 'userdata' then
			_initialPackages[key] = value
		end
	end

	debugger =
	{
		_initialGlobals = _initialGlobals,
		_initialPackages = _initialPackages,
		_originalErrhand = love.errhand,
		_crashed = false
	}

	-- replace crash handler
	-- we have to do this at this stage; there seems to be
	-- some magic that happens to connect to this function
	-- such that changing it later, even when creating the
	-- initial view, doesn't work

	love.errhand = function (message)
		if debugger._crashed then
			debugger._originalErrhand(message)
			return
		end

		if the.console and the.keys then
			debugger._crashed = true
			print(string.rep('=', 40))
			print('\nCrash, ' .. message .. '\n')
			print(debug.traceback())
			print('\n' .. string.rep('=', 40) .. '\n')
			the.console:show()
			love.audio.stop()

			-- enter a mini event loop, just updating the
			-- console and keys

			local elapsed = 0

			while true do
				if love.event then
					love.event.pump()
					
					for e, a, b, c, d in love.event.poll() do
						if e == 'quit' then
							if not love.quit or not love.quit() then return end
						end

						love.handlers[e](a, b, c, d)
					end
				end

				if love.timer then
					love.timer.step()
					elapsed = love.timer.getDelta()
				end

				the.keys:startFrame(elapsed)
				the.console:startFrame(elapsed)
				the.keys:update(elapsed)
				the.console:update(elapsed)
				the.keys:endFrame(elapsed)
				the.console:endFrame(elapsed)

				if the.keys:pressed('escape') then
					if not love.quit or not love.quit() then return end
				end

				if love.graphics then
					love.graphics.clear()
					if love.draw then
						the.console:draw()
					end
				end

				if love.timer then love.timer.sleep(0.02) end
				if love.graphics then love.graphics.present() end
			end
		else
			debugger._originalErrhand(message)
		end
	end
end

-- Warn about accessing undefined globals in strict mode

if STRICT then
	setmetatable(_G, {
		__index = function (table, key)
			local info = debug.getinfo(2, 'Sl')
			print('Warning: accessing undefined global ' .. key .. ', ' ..
				  info.short_src .. ' line ' .. info.currentline)
		end
	})
end

require 'zoetrope.core.class'

require 'zoetrope.core.app'
require 'zoetrope.core.cached'
require 'zoetrope.core.globals'
require 'zoetrope.core.sprite'
require 'zoetrope.core.gamepad'
require 'zoetrope.core.group'
require 'zoetrope.core.keys'
require 'zoetrope.core.mouse'
require 'zoetrope.core.promise'
require 'zoetrope.core.timer'
require 'zoetrope.core.tween'
require 'zoetrope.core.view'

require 'zoetrope.sprites.animation'
require 'zoetrope.sprites.emitter'
require 'zoetrope.sprites.fill'
require 'zoetrope.sprites.map'
require 'zoetrope.sprites.text'
require 'zoetrope.sprites.tile'

require 'zoetrope.ui.button'
require 'zoetrope.ui.cursor'
require 'zoetrope.ui.textinput'

require 'zoetrope.utils.debug'
require 'zoetrope.utils.factory'
require 'zoetrope.utils.recorder'
require 'zoetrope.utils.storage'
require 'zoetrope.utils.subview'

-- simple load function to bootstrap the app if love.load() hasn't already been defined;
-- defining it again after this works fine as well

if not love.load then
	love.load = function()
		if the.app then
			-- if we only extended an app, instantiate it
			if not (the.app.view and the.app.meta) then the.app = the.app:new() end
			the.app:run()
		end
	end
end
