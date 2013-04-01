--[[

#########################################################################
#                                                                       #
# utils.lua                                                             #
#                                                                       #
# Utility functions                                                     #
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

function leaf.snap_floor(value, step)
    return math.floor(value / step) * step
end

function leaf.snap_ceil(value, step)
    return math.ceil(value / step) * step
end

function leaf.constrain(value, min, max)
    return math.max(math.min(value, max), min)
end

-- Check if an object is an instance of its prototype
function leaf.isinstance(obj, class)
    return getmetatable(obj) == class
end


-- Return a list of quads for each frame of an image
function leaf.build_quads(image, framewidth, frameheight)
    local quads = {}
    for j=0, math.floor(image:getHeight() / frameheight) - 1 do
        for i=0, math.floor(image:getWidth() / framewidth) - 1 do
            table.insert(quads, love.graphics.newQuad(i * framewidth, j * frameheight, framewidth, frameheight, image:getWidth(), image:getHeight()))
        end
    end
    return quads
end
