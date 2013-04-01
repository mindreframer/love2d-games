--[[

#########################################################################
#                                                                       #
# screen.lua                                                            #
#                                                                       #
# LOVE abstract screen helper                                           #
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


local w, h, f, v, a = love and love.graphics and love.graphics.getMode()
local screen = {
    -- Represents the dimensions of the game screen (as opposed to resolution)
    width = w,
    height = h,

    -- Scale boundaries
    min_scale = 1,
    max_scale = 100,

    -- Screen scaling mode.  Supported modes:
    --  "fixed": Scale the game screen by the largest integer fitting inside resolution, clipping extra screen space (Default)
    --  "stretched": Stretch the game screen to the resolution
    mode = 'fixed',
}

-- Override settings
function screen.setSize(w, h)
    screen.setWidth(w)
    screen.setHeight(h)
end

function screen.setWidth(w)
    screen.width = w
end

function screen.setHeight(h)
    screen.height = h
end

function screen.setMinScale(s)
    screen.min_scale = s
end

function screen.setMaxScale(s)
    screen.max_scale = s
end

function screen.setMode(mode)
    screen.mode = mode
end


-- Get the dimensions of the game screen
function screen.getSize()
    return screen.getWidth(), screen.getHeight()
end

function screen.getWidth()
    return screen.width
end

function screen.getHeight()
    return screen.height
end


-- Apply screen transformations, this should wrap all your drawing code
function screen.apply()
    local res_w, res_h = love.graphics.getMode()
    local scale = math.min(math.floor(res_w / screen.width), math.floor(res_h / screen.height))
    love.graphics.push()
    love.graphics.translate((res_w % (screen.width * scale)) / 2, (res_h % (screen.height * scale)) / 2)
    love.graphics.scale(scale)
end

function screen.revert()
    love.graphics.pop()
end





-- Export
leaf.screen = screen
