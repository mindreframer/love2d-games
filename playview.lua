-- February2013
-- Copyright © 2013 John Watson <john@watson-net.com>

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
-- the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

require 'pointer'
require 'swarm'
require 'asteroid'
require 'building'

GROUND_HEIGHT = 500

playView = View:extend {
    id = 'playview',
    gametime = 0,
    ending = false,

    init = function(self)
        -- Stop running timers so they don't accumulate
        self.timer:stop()

        -- Day/night cycle
        self.sky_day = Animation:new{
            id = 'sky',
            image = 'img/sky-day.png',
            alpha = 1,
            width = love.graphics.getWidth(),
            height = love.graphics.getHeight(),

            start = function(self)
                the.app.score.days = the.app.score.days + 1
                self.alpha = 0
                the.app.playView.tween:start(self, 'alpha', 1, 10, 'linear')
                the.app.playView.tween:start(the.app.playView.sky_dawn, 'alpha', 0, 10, 'linear')
                the.app.playView.timer:after(25, function() the.app.playView.sky_dusk:start() end)
            end,
        }
        self.sky_dusk = Animation:new{
            id = 'sky',
            image = 'img/sky-dusk.png',
            alpha = 0,
            width = love.graphics.getWidth(),
            height = love.graphics.getHeight(),

            start = function(self)
                self.alpha = 0
                the.app.playView.tween:start(self, 'alpha', 1, 5, 'linear')
                the.app.playView.tween:start(the.app.playView.sky_day, 'alpha', 0, 5, 'linear')
                the.app.playView.timer:after(5, function() the.app.playView.sky_night:start() end)
            end,
        }
        self.sky_night = Animation:new{
            id = 'sky',
            image = 'img/sky-night.png',
            alpha = 0,
            width = love.graphics.getWidth(),
            height = love.graphics.getHeight(),
            stars = {},

            onNew = function(self)
                for i = 1, 2000 do
                    table.insert(self.stars,
                        {
                            x = math.random(love.graphics.getWidth()*4)-love.graphics.getWidth()*2,
                            y = math.random(love.graphics.getHeight()*4)-love.graphics.getHeight()*2,
                            r = math.random(2)
                        }
                    )
                end
            end,

            start = function(self)
                self.alpha = 0
                the.app.playView.tween:start(self, 'alpha', 1, 10, 'linear')
                the.app.playView.tween:start(the.app.playView.sky_dusk, 'alpha', 0, 10, 'linear')
                the.app.playView.timer:after(25, function() the.app.playView.sky_dawn:start() end)
            end,

            onDraw = function(self)
                love.graphics.push()

                love.graphics.translate(love.graphics.getWidth()*1.5, love.graphics.getHeight())
                love.graphics.rotate(the.app.playView.gametime * math.pi * 2 / 25)
                for i = 1, #self.stars do
                    love.graphics.setColor(255, 255, 255, math.random() * self.alpha * 255)
                    local x = self.stars[i].x
                    local y = self.stars[i].y
                    local r = self.stars[i].r
                    love.graphics.circle('fill', x, y, r)
                end

                love.graphics.pop()

                love.graphics.setColor(255, 255, 255, 255)
            end
        }
        self.sky_dawn = Animation:new{
            id = 'sky',
            image = 'img/sky-dawn.png',
            alpha = 0,
            width = love.graphics.getWidth(),
            height = love.graphics.getHeight(),

            start = function(self)
                self.alpha = 0
                the.app.playView.tween:start(self, 'alpha', 1, 5, 'linear')
                the.app.playView.tween:start(the.app.playView.sky_night, 'alpha', 0, 5, 'linear')
                the.app.playView.timer:after(5, function() the.app.playView.sky_day:start() end)
            end,
        }
        the.app:add(self.sky_day)
        the.app:add(self.sky_dusk)
        the.app:add(self.sky_night)
        the.app:add(self.sky_dawn)
        self.timer:after(5, function() self.sky_dusk:start() end)

        -- Build city
        for i = 1, math.ceil(love.graphics.getWidth()/building.width) do
            local b = building:new({ x = building.width * (i-1) })
            the.app:add(b)
        end

        -- Message
        self:add(Text:new{
            x = 0,
            y = 10,
            align="center",
            width = love.graphics.getWidth(),
            font = { "fnt/visitor1.ttf", 24 },
            text = "Protect " .. the.app.city .. "!",
            tint = { 1, 0, 0 }
        })

        -- Create swarm
        self.swarm = swarm:new()
        the.app:add(self.swarm)
        self.swarm:addMember(10)

        -- Add pointer
        self.pointer = pointer:new()
        the.app:add(self.pointer)

        -- Setup timers
        self.timer:every(1/the.app.beat.beats_per_second, function() self.swarm:addMember(1, love.graphics.getWidth()/2, GROUND_HEIGHT) end)
        self.timer:every(1/the.app.beat.beats_per_second, function() self:launchAsteroid() end)
    end,

    startDay = function(self)
        the.app.score.days = the.app.score.days + 1
    end,

    launchAsteroid = function(self)
        local r = math.random(1000)
        local size = asteroid.MIN_SIZE

        local difficulty = self.gametime/1
        if r > 990 - difficulty then
            size = asteroid.BIG_ROCK
        end
        if r > 1000 - difficulty then
            size = asteroid.GIANT_ROCK
        end
        -- if self.gametime > 5 then
        --     size = asteroid.EXTINCTION_ROCK
        --     self.timer:stop()
        -- end
        local m = asteroid:new({ size = size })
        the.app:add(m)
    end,

    onNew = function(self)
    end,
    
    onUpdate = function(self, dt)
        if the.keys:justPressed('escape') then
            the.app:changeState(the.app.STATE_PAUSED)
        end

        -- Game over condition
        if not self.ending then
            local buildings = 0
            for i, s in ipairs(self.sprites) do
                if s.id and s.id == 'building' and s.hp > 0 then
                    buildings = buildings + 1
                end
            end
            if buildings <= 0 then
                self.ending = true
                self:fade({ 255, 255, 255 }, 5)
                    :andThen(function() the.app:changeState(the.app.STATE_GAMEOVER) end)
            end
        end

        self.gametime = self.gametime + dt
    end,

    onDraw = function(self)
        love.graphics.setColor(255, 255, 255, 255)
    end
}
