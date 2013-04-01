--[[

########################################################################
#                                                                      #
# object.lua                                                           #
#                                                                      #
# Base object for all modules in leaf, and simple OO implementation.   #
#                                                                      #
# Copyright 2011 Josh Bothun                                           #
# joshbothun@gmail.com                                                 #
# http://minornine.com                                                 #
#                                                                      #
# This program is free software: you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation, either version 3 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License <http://www.gnu.org/licenses/> for        #
# more details.                                                        #
#                                                                      #
########################################################################

--]]

local function new(class, ...)
    local obj = setmetatable({}, class)
    if obj.init then obj:init(...) end
    return obj
end
local function extend(class, sub)
    local sub = sub or {}
    sub.__index = sub
    sub.__call = new
    return setmetatable(sub, class)
end
local Object = extend({}, {extend=extend})

-- Export
leaf.Object = Object
