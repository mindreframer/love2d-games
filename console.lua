--[[

#########################################################################
#                                                                       #
# console.lua                                                           #
#                                                                       #
# Love2D in-game console                                                #
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

require 'leaf.color'
require 'leaf.object'
require 'leaf.containers'
require 'leaf.context'

-- Default settings --
local HISTORY = 100
local PADDING = 10


-- Console message --
local Message = leaf.Object:extend()

function Message:init(data, level)
    self.data = data or ""
    self.level = level or 'info'
end


-- Console -- 
local Console = leaf.Context:extend()

function Console:init()
    self.font = love.graphics.newFont(10)
    self.queue = leaf.Queue(HISTORY)
    self.input = ""
    self.color = leaf.ColorPalette {
        info = {255, 255, 255},
        input = {255, 255, 255},
        error = {255, 0, 0},
        overlay = {0, 0, 0},
    }
end

function Console:write(...)
    local text = table.concat(arg, " ")
    self.queue:push(Message(text))
end

function Console:error(...)
    local text = table.concat(arg, " ")
    self.queue:push(Message(text, 'error'))
end

function Console:draw()
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()

    -- Draw log
    self:drawLog(width, height)

    -- Draw overlay
    self.color.overlay(100)
    love.graphics.rectangle('fill', 0, 0, width, height)

    -- Draw input
    self.color.input()
    love.graphics.print(self.input .. '|', PADDING, height - PADDING - self.font:getHeight())
end

function Console:drawLog(width, height)
    local width = width or love.graphics.getWidth()
    local height = height or love.graphics.getHeight()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(self.font)
    for i, message in self.queue:iter_reverse() do
        self.color[message.level]()
        love.graphics.printf(message.data, PADDING, 
                             height - PADDING - (i + 1) * self.font:getHeight(), 
                             width, 'left')
    end
end


-- Console input handling functions
local shift_map = {
    ['9'] = '(',
    ['0'] = ')',
    ['['] = '{',
    [']'] = '}',
    [';'] = ':',
}

local ignored_keys = leaf.Set {
    'lshift',
    'rshift',   
}

function charMap (key)
    if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
        if shift_map[key] then
            return shift_map[key]
        end
    end
    return key
end

function Console:keypressed(key, unicode)
    if key == 'escape' then
        self:clearInput()
    elseif key == 'return' then
        self:submitInput()
    elseif key == 'backspace' then
        self.input = string.sub(self.input, 1, -2)
    elseif not ignored_keys:contains(key) then
        self.input = self.input .. charMap(key)
    end
end

function Console:clearInput()
    self.input = ""
end

function Console:submitInput()
    -- Attempt to parse input as lua
    chunk, error = loadstring(self.input)
    if error then
        self:error(error)
    else
        chunk()
    end
    self:clearInput()
end

-- Namespace exports
leaf.Console = Console
