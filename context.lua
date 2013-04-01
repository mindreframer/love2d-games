--[[

#########################################################################
#                                                                       #
# context.lua                                                           #
#                                                                       #
# Top-level gamestate object helper.                                    #
#                                                                       #
# Copyright 2011 Josh Bothun                                            #
# joshbothun@gmail.com                                                  #
# http://minornine.com                                                  #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License <http://www.gnu.org/licenses/> for         #
# more details.                                                         #
#                                                                       #
#########################################################################

--]]

require 'leaf.object'
require 'leaf.containers'

-- Context class, represents a running state with input/update/draw
local Context = leaf.Object:extend {
    -- Controls whether or not self is passed to love callbacks
    call_self = true,
}

-- App class, for containing contexts and wrapping love callbacks
local App = leaf.Object:extend()

function App:init()
    self.cstack = leaf.Stack()
end

-- Push a context to the front of the screen
function App:pushContext(context)
    self.cstack:push(context)
end

-- Pop the outermost context
function App:popContext()
    self.cstack:pop()
end

-- Swaps the outermost context for a new one, or pushes if the stack is empty
function App:swapContext(context)
    if self.cstack:isEmpty() then
        self.cstack:push(context)
    else
        self.cstack[#app.cstack] = context
    end
end

-- Reroute all love callbacks to this app
function App:bind()
    for i, func in ipairs{'update', 'keypressed', 'mousepressed', 'mousereleased', 'quit', 'draw'} do
        love[func] = function (...)
            for i, context in ipairs(self.cstack) do
                if type(context[func]) == 'function' then
                    if context.call_self then
                        if context[func](context, ...) == true then 
                            break 
                        end
                    else
                        if context[func](...) == true then
                            break
                        end
                    end
                end
            end
        end
    end
end


-- Namespace exports
leaf.Context = Context
leaf.App = App
