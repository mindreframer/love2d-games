--[[

#########################################################################
#                                                                       #
# polygon.lua                                                           #
#                                                                       #
# Generic 2D polygon class                                              #
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

local Polygon = leaf.Object:extend()

-- Convex polygon --
function Polygon:init(...)
    if type(arg[1]) == 'table' then
        return self:init(unpack(arg[1]))
    end

    -- Add initial points from args
    for i=1, math.max(#arg, 6), 2 do
        local x, y = arg[i], arg[i+1]
        self:addPoint(x or 0, y or 0)
        table.insert(self, point)
    end
end

-- Add a new point to the polygon
function Polygon:addPoint(x, y)
    table.insert(self, x)
    table.insert(self, y)
end

-- Remove a point from the polygon, defaults to last point
function Polygon:removePoint(i)
    local npoints = self:numPoints()
    if npoints <= 3 then
        return nil
    end
    local i = i or npoints
    local x = table.remove(self, i * 2 - 1)
    local y = table.remove(self, i * 2 - 1)
    return x, y
end

function Polygon:numPoints()
    return math.floor(#self / 2)
end

function Polygon:getPoint(i)
    return self[i * 2 - 1], self[i * 2]
end

function Polygon:setPoint(i, x, y)
    self[i * 2 - 1] = x
    self[i * 2] = y
end

function Polygon:getPointTables()
    local points = {}
    for x, y in self:iterPoints() do
        table.insert(points, vector(x, y))
    end
    return points
end

function Polygon:setPointTables(points)
    for i, point in ipairs(points) do
        self:setPoint(i, point.x, point.y)
    end
end

function Polygon:iterPoints()
    local i = 1
    return function()
        if i > self:numPoints() then
            return nil
        end
        local tmp = i
        i = i + 1
        return self:getPoint(tmp)
    end
end

-- Get the centroid of the polygon
-- http://en.wikipedia.org/wiki/Centroid
function Polygon:getCentroid()
    local tx, ty = 0, 0
    for x, y in self:iterPoints() do
        tx = tx + x
        ty = ty + y
    end
    local npoints = self:numPoints()
    return tx / npoints, ty / npoints
end


-- Reorder the points such that the polygon is regular
-- Note this function is expensive
function Polygon:normalize()
    local cx, cy = self:getCentroid()
    local points = self:getPointTables()
    table.sort(points, function(a, b)
        return math.atan2(a.y - cy, a.x - cx) >
               math.atan2(b.y - cy, b.x - cx)
    end)
    self:setPointTables(points)
end


-- Check if this polygon contains a point
-- Ray casting theorem
function Polygon:contains(mx, my)
    local points = self:getPointTables()
    local i, j = #points, #points
    local oddNodes = false

    for i=1, #points do
        if ((points[i].y < my and points[j].y >= my
                or points[j].y< my and points[i].y>=my) and (points[i].x<=mx
                or points[j].x<=mx)) then
                if (points[i].x+(my-points[i].y)/(points[j].y-points[i].y)*(points[j].x-points[i].x)<mx) then
                        oddNodes = not oddNodes
                end
        end
        j = i
    end

    return oddNodes
end


-- Check if the polygon intersects with another
-- Separating axis theorem


-- Namespace exports
leaf.Polygon = Polygon
