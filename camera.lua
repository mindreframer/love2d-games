--[[

#########################################################################
#                                                                       #
# camera.lua                                                            #
#                                                                       #
# Simple Love2D camera class                                            #
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
require 'leaf.vector'

local Camera = leaf.Object:extend()



function Camera:init(prop)
    self.screenWidth = love.graphics.getWidth
    self.screenHeight = love.graphics.getHeight
    local prop = prop or {}
    self.x, self.y = 0, 0
    self.scale = prop.scale or 1
    if prop.track_func then self:track(prop.track_func) end
end

-- Set the cameras tracking function
function Camera:track(track_func)
    assert(type(track_func) == 'function')
    self.track_func = track_func
end

function Camera:untrack()
    self.track_func = nil
end

-- Return the upper left corner of the camera in world space
function Camera:getWorldPosition()
    local tx, ty = self.x, self.y
    if self.track_func then
        tx, ty = self.track_func()
    end
    return tx - self:screenWidth() / 2 / self.scale, ty - self:screenHeight() / 2 / self.scale
end

-- Return a rect representing the viewable rectangle in world space
function Camera:getClipRect()
    local x, y = self:getWorldPosition()
    return x, y, x + self:screenWidth() / self.scale, y + self:screenHeight()
end

-- Sets up matrix to center the active target
-- If a Z parameter is specified, it is considered a depth factor relative to the target
-- e.g., if z = 2.0, objects in worldspace will appear 2x as close as the target
function Camera:applyMatrix(z)  
    -- Default depth to 1, which is the plane of the target
    local z = z or 1
    local x, y = self:getWorldPosition()

    -- Center on target, offset depth by Z, scale by camera scale
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(z * -x, z * -y)
end

-- Convert a vector in screen space to world space.
-- ("World space" means the coordinate space of the camera's target)
function Camera:toWorld(x, y)
    local cam_x, cam_y = self:getWorldPosition()
    return x / self.scale + cam_x, y / self.scale + cam_y
end

-- Convert a vector in world space to screen space.
-- ("World space" means the coordinate space of the camera's target)
function Camera:toScreen(x, y)
    local cam_x, cam_y = self:getWorldPosition()
    return x * self.scale - cam_x, y * self.scale - cam_y
end


-- Namespace exports
leaf.Camera = Camera
