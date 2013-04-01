--[[

#########################################################################
#                                                                       #
# functional.lua                                                        #
#                                                                       #
# Functional programming constructs                                     #
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

-- Remove objects from a lua table, defragmenting the table in the process.
function leaf.remove_if(t, cull)
    -- Defrag
    local size = #t
    local free = 1
    for i = 1, #t do
        if not cull(t[i]) then
            t[free] = t[i]
            free = free + 1
        end
    end
    -- Nil remainder
    for i = free, size do
        t[i] = nil
    end
end


--- Map for 2D arrays
function leaf.map2d(array, callback)
    for i=1, #array do
        for j=1, #array[i] do
            callback(array[i][j])
        end
    end
end


--- Like underscore pick
function leaf.pick(table, keys)
    result = {}
    for i, key in ipairs(keys) do
        if table[key] ~= nil then
            result[key] = table[key]
        end
    end
    return result
end

