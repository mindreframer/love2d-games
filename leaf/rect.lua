--[[

#########################################################################
#                                                                       #
# rect.lua                                                              #
#                                                                       #
# 2D rectangle operations                                               #
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
require 'leaf.vector'

local vector = leaf.vector

local rect = {}

function rect.new(a, b, c, d)
    -- If only two values passed, assume right and bottom
    if c == nil then
        return rect.new(0, 0, a, b)
    end
    return {
        left = a or 0,
        top = b or 0,
        right = c or 0,
        bottom = d or 0,
    }
end

function rect.width(left, top, right, bottom)
    return right - left
end

function rect.height(left, top, right, bottom)
    return bottom - top
end

function rect.size(left, top, right, bottom)
    return rect.width(left, top, right, bottom),
           rect.height(left, top, right, bottom)
end

function rect.area(left, top, right, bottom)
    return rect.width(left, top, right, bottom) *
           rect.height(left, top, right, bottom)
end

-- Return the center coordinate of the rectangle
function rect.center(left, top, right, bottom)
    local w, h = rect.size(left, top, right, bottom)
    return left + w / 2, top + h / 2
end

function rect.translate(left, top, right, bottom, x, y)
    local left, top = vector.translate(left, top, x, y)
    local right, bottom = vector.translate(right, bottom, x, y)
    return left, top, right, bottom
end

function rect.scale(left, top, right, bottom, sx, sy)
    local sy = sy or sx
    local w, h = rect.size(left, top, right, bottom)
    return left, top, left + w * sx, top + h * sy
end

function rect.scaleCenter(left, top, right, bottom, sx, sy)
    local nleft, ntop, nright, nbottom = rect.scale(left, top, right, bottom, sx, sy)
    local dx, dy = nright - right, nbottom - bottom
    return rect.translate(nleft, ntop, nright, nbottom, -dx / 2, -dy / 2)
end

-- Convert to an x, y, w, h rectangle
function rect.toRel(left, top, right, bottom)
    return left, top, rect.size(left, top, right, bottom)
end

-- Convert to a left, top, right, bottom rectangle
function rect.toAbs(left, top, width, height)
    return left, top, left + width, top + height
end

-- Check if a rect contains a point
function rect.contains(left, top, right, bottom, a, b)
    if type(a) == 'table' then
        -- Assume a is vector table
        return rect.contains(left, top, right, bottom, a.x, a.y)
    end
    return a >= left and a <= right and b >= top and b <= bottom
end

-- Check if rect intersects another rect
local function axis_overlaps(head, tail, head2, tail2)
    return head >= head2 and head <= tail2 or
           tail >= head2 and tail <= tail2
end
function rect.intersects(left, top, right, bottom, a, b, c, d)
    if type(a) == 'table' then
        -- Assume a is a rect table
        return rect.intersects(left, top, right, bottom,
                               a.left, a.top, a.right, a.bottom)
    end
    return axis_overlaps(left, right, a, c) and axis_overlaps(top, bottom, b, d)
end


-- Wrap all rect methods to accept either a table or flat args
for k, v in pairs(rect) do
    rect[k] = function(a, b, c, d, ...)
        if type(a) == 'table' then
            return v(a.left, a.top, a.right, a.bottom, b, c, d, ...)
        end
        return v(a, b, c, d, ...)
    end
end


-- Must pass a table to unpack
function rect.unpack(r)
    return r.left, r.top, r.right, r.bottom
end


-- Define in-place functions
for _, key in ipairs({"translate", "scale", "scaleCenter"}) do
    rect[key .. "_i"] = function(r, ...)
        r.left, r.top, r.right, r.bottom = rect[key](r, ...)
        return r
    end
end


-- Call shortcut
setmetatable(rect, {
    __call = function(self, ...)
        return rect.new(...)
    end,
})


-- Namespace exports
leaf.rect = rect
