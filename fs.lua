--[[

#########################################################################
#                                                                       #
# fs.lua                                                                #
#                                                                       #
# Love2D filesystem loading functions                                   #
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

require 'strong'          

local fs = {}

-- Generic loading function that does a deep search through `path`, calling
-- `file_callback` on each file and storing it in a map, and also calling
-- `interp_callback` with a percentage of completion arg, for easy hooking.
-- Finally, the function returns the constructed map
local function recursiveYieldingLoader(root, file_callback, interp_callback)
    local map = {}
    local count, total = 0, 0
    function iter(path, docount)
        for i, name in ipairs(love.filesystem.enumerate(path)) do
            count = count + 1
            fullpath = path .. '/' .. name
            if not docount and love.filesystem.isFile(fullpath) then
                -- Strip root dir and extension from key
                local key = string.sub(fullpath, fullpath:find('/') + 1, fullpath:len())
                key = key:gsub('%.[^.]*$', '')
                map[key] = file_callback(fullpath)
                if type(interp_callback) == 'function' then
                    interp_callback(count / total, fullpath)
                end
            elseif love.filesystem.isDirectory(fullpath) then
                iter(fullpath, docount)
            end
        end
    end

    -- Count number of files in tree and store total
    iter(root, true)
    total = count
    count = 0

    -- Run actual function
    iter(root)

    -- Return resulting map
    return map
end

-- Load directory tree into a map of lua chunks
function fs.loadChunks(path, callback)
    return recursiveYieldingLoader(path, love.filesystem.load, callback)
end

-- Load directory tree into a map of love.graphics.Image
function fs.loadImages(path, callback)
    return recursiveYieldingLoader(path, love.graphics.newImage, callback)
end

-- Load directory tree into a map of love.audio.Source
function fs.loadSounds(path, callback)
    return recursiveYieldingLoader(path, love.audio.newSource, callback)
end

-- Load directory tree into a map of love.graphics.PixelEffect
function fs.loadShaders(path, callback)
    -- Replace shaders keywords with the fake ones
    function subshader(file)
        local tmp = love.filesystem.read(file)
        tmp = tmp:gsub('float', 'number')
        tmp = tmp:gsub('sampler2D', 'Image')
        tmp = tmp:gsub('uniform', 'extern')
        tmp = tmp:gsub('texture2D', 'Texel')
        return love.graphics.newPixelEffect(tmp)
    end
    return recursiveYieldingLoader(path, subshader, callback)
end


-- Namespace exports
leaf.fs = fs
