--[[

#########################################################################
#                                                                       #
# time.lua                                                              #
#                                                                       #
# Timer objects for scheduled events                                    #
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
require 'leaf.containers'
require 'leaf.functional'

-- Timer class --
local Timer = leaf.Object:extend()

function Timer:init(duration, callback, loops, start)
    self.duration = duration
    self.callback = callback
    self.loops = loops or 1
    self.timeleft = self.duration
    self.running = false
    self.dead = false
    start = start or true
    if start then self:start() end
end

-- Start or restart the timer
function Timer:start()
    self.running = true
    self.timeleft = self.duration
end
Timer.restart = Timer.start

-- Stops timer and flags it for removal
function Timer:kill()
    self.running = false
    self.dead = true
end

-- Safe pause
function Timer:pause()
    self.running = false
end

-- Safe resume
function Timer:resume()
    self.running = true
end

-- Update the timer
function Timer:update(dt)
    if self.running then
        self.timeleft = self.timeleft - dt
        if self.timeleft < 0.0 then
            self.timeleft = self.timeleft + self.duration
            self.callback()
            -- Check how many loops remaining, loop infinitely if set to < 0
            self.loops = math.max(self.loops - 1, -1) -- Prevent overflow
            if self.loops == 0 then self:kill() end
            return true
        end
        return false
    end
    return false
end


-- Interpolator class --

-- Interpolators which execute every tick, passing
-- a 0-1 alpha argument to its bound callback

local Interpolator = Timer:extend()

function Interpolator:update(dt)
    if Timer.update(self) then
        -- Finished, call with max value
        self.callback(1)
    end
    -- Calculate alpha
    local alpha = 1.0 - self.timeleft / self.duration
    self.callback(alpha)
end


-- Time controller class
local Time = leaf.Object:extend()

function Time:init()
    self.timers = {}
end


-- Update time system -- this must be called from main loop
function Time:update(dt)
    -- Clean up dead timers
    leaf.remove_if(self.timers, function(t) return t.dead end)
    -- Update alive timers
    for i, timer in ipairs(self.timers) do
        timer:update(dt)
    end
end

-- Create, register and return a new timer
function Time:timer(duration, callback, loops, start)
    local timer = Timer(duration, callback, loops, start)
    table.insert(self.timers, timer)
    return timer
end

-- Create, register and return a new interpolator
function Time:interp(duration, callback, loops, start)
    local interp = Interpolator(duration, callback, loops, start)
    table.insert(self.timers, interp)
    return interp
end

-- Schedule `callback` after `duration` milliseconds
function Time:after(duration, callback, loops)
    return self:timer(duration, callback, 1, true)
end

-- Schedule `callback` every `duration` milliseconds
function Time:every(duration, callback, loops)
    return self:timer(duration, callback, loops or 0, true)
end


-- Namespace exports
leaf.Time = Time
