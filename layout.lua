--[[

#########################################################################
#                                                                       #
# layout.lua                                                            #
#                                                                       #
# Position and layout helper functions                                  #
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


require 'leaf.rect'
require 'leaf.vector'

local vector = leaf.vector
local rect = leaf.rect

local layout = {}

-- Return the position for an element of a list
layout.list = function(rect, position, conf)
    local conf = conf or {}
    local margin = conf.margin or 1
    local spacing = conf.spacing or 1
    local x = margin
    local y = margin + (position - 1) * spacing
    return vector.translate(x, y, rect.left, rect.top)
end

-- Export
leaf.layout = layout
