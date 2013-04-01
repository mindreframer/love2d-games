--[[

Copyright (C) 2011-2012 RasMoon Developpement team

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.


]]-- 

package.path = package.path .. ";RasMoon/?.lua"
require 'RasMoon.index'

local CURRENT_STATE = nil
local STATES = {}

New.State = function(name)
	       local _func = function() end
	       STATES[name] = {
		  onEnter = _func,
		  onLeave = _func,
		  update = _func,
		  draw = _func,
		  mousepressed = _func,
		  mousereleased = _func,
		  keypressed = _func,
		  keyreleased = _func,
		  focus = _func
	       }
	       return (STATES[name])
	    end

State = {}

State.goTo = function(name)
		if _(CURRENT_STATE) then CURRENT_STATE.onLeave() end
		CURRENT_STATE = STATES[name]
		CURRENT_STATE.onEnter()
	     end

State.get = function()
	       return (STATES)
	    end

State.Current = function()
		   return (CURRENT_STATE)
		end

function love.load()
   assert(nil ~= RASMOON)
   State.goTo("index")
end

function love.update(dt)
   CURRENT_STATE.update(dt)
end

function love.draw()
   CURRENT_STATE.draw()
end

function love.mousepressed(x, y, button)
   CURRENT_STATE.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
   CURRENT_STATE.mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
   CURRENT_STATE.keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
   CURRENT_STATE.keyreleased(key, unicode)
end

function love.focus(f)
   CURRENT_STATE.focus(f)
end

function love.quit()
   CURRENT_STATE.onLeave()
end

require 'index'
