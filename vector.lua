--[[

#########################################################################
#                                                                       #
# vector.lua                                                            #
#                                                                       #
# 2D vector operations                                                  #
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

require 'math'
require 'leaf.object'

local sin, cos, sqrt = math.sin, math.cos, math.sqrt

local vector = {}


function vector.new(x, y)
    return {
        x = x or 0,
        y = y or 0,
    }
end

function vector.translate(x, y, dx, dy)
    return x + dx, y + dy
end

function vector.rotate(x, y, theta)
    local rx = x * math.cos(theta) - y * math.sin(theta)
    local ry = x * math.sin(theta) + y * math.cos(theta)
    return rx, ry
end

function vector.scale(x, y, sx, sy)
    local sy = sy or sx
    return x * sx, y * sy
end

function vector.length(x, y)
    return math.sqrt(x * x + y * y)
end

function vector.normalize(x, y)
    local len = vector.length(x, y)
    if len > 0 then
        return x / len, y / len
    end
    return x, y
end

function vector.perpendicular(x, y, right)
    if not right then
        return -y, x
    else
        return y, -x
    end
end


-- Wrap all vector methods to accept either a table or flat args
for k, v in pairs(vector) do
    vector[k] = function(a, b, ...)
        if type(a) == 'table' then
            return v(a.x, a.y, b, ...)
        end
        return v(a, b, ...)
    end
end


-- Must pass a table to unpack
function vector.unpack(v)
    return v.x, v.y
end


-- Define in-place functions
for _, key in ipairs({"translate", "rotate", "scale", "normalize"}) do
    vector[key .. "_i"] = function(v, ...)
        v.x, v.y = vector[key](v, ...)
        return v
    end
end


-- Call shortcut
setmetatable(vector, {
    __call = function(self, ...) 
        return vector.new(...)
    end,
})

-- Namespace exports
leaf.vector = vector
