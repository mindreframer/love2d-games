-- January2013
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

player = Sprite:new{
    STATE_ALIVE = 1,
    STATE_DEAD = 2,
    THRUST = 60,
    STARTING_FUEL = 100,
    MAX_FUEL = 100,
    FUEL_BURN_PER_SECOND = 25,
    SEGMENTS = 8,
    acceleration = { x = 0, y = 0 },
    radius = 10,
    exhaust_period = 0.1,
    exhaust_elapsed = 0,
    is_thrusting = false,
    speed = 0,
    self_destruct = 0,

    onNew = function(self)
        self.thrust_snd = love.audio.newSource("snd/thrust.ogg", "static")
        self.thrust_snd:setLooping(true)
        self.out_of_fuel_snd = love.audio.newSource("snd/out_of_fuel.ogg", "static")
        self.explosion_snd = love.audio.newSource("snd/explosion.ogg", "static")
        self.bounce_snd = love.audio.newSource("snd/bounce.ogg", "static")
        self.surplus_snd = love.audio.newSource("snd/beep.ogg", "static")
        self.self_destruct_snd = love.audio.newSource("snd/self_destruct.ogg", "static")

        self.width = self.radius
        self.height = self.radius
        self.maxVelocity.x = 100
        self.maxVelocity.y = 100
        self.minVelocity.x = -100
        self.minVelocity.y = -100
        self.drag = { x = self.THRUST/10, y = self.THRUST/10 }

        self:reset()
        self.state = self.STATE_DEAD

        -- Setup explosion emitter
        self.explosion_emitter = Emitter:new{
            x = self.x,
            y = self.y,
            width = 1,
            height = 1,

            min = { velocity = { x = -75, y = -75 }},
            max = { velocity = { x = 75, y = 75 }},
        }

        self.explosion_emitter:loadParticles(Fill:extend{
            width = 2,
            height = 2,
            fill = {255, 255, 255},
            onEmit = function (self)
                self.width = math.random(2,6)
                self.height = 2
                self.alpha = 1
                self.velocity.x = self.velocity.x + player.velocity.x
                self.velocity.y = self.velocity.y + player.velocity.y
                local t = math.random() * 2
                -- It's subtle (maybe too subtle) but some of the ship pieces are
                -- different sizes and rotating
                the.view.tween
                    :start(self, 'alpha', 0, t)
                    :andThen(function() self:die() end)
                the.view.tween
                    :start(self, 'rotation', math.random(-4, 4)*math.pi, t)
            end
        },
        50)
    end,

    onDraw = function(self, x, y)
        love.graphics.push()

        if self.state == self.STATE_ALIVE then
            if self.fuel > 0 then
                love.graphics.setColor(255, 255, 255, 255)
            else
                love.graphics.setColor(255, 255, 255, math.abs(math.sin(love.timer.getMicroTime()*8))*255)
            end
            love.graphics.setLineWidth(1)
            love.graphics.circle("line", x, y, self.radius, self.SEGMENTS)

            -- Draw fuel gauge
            if self.fuel > 0 then
                a1 = -math.pi/2
                a2 = -math.pi/2 + 2 * math.pi * self.fuel / self.MAX_FUEL
                if self.fuel > self.MAX_FUEL * 0.5 then
                    love.graphics.setColor(0, 255, 0, 200)
                elseif self.fuel > self.MAX_FUEL * 0.25 then
                    love.graphics.setColor(255, 255, 0, 200)
                elseif self.fuel > self.MAX_FUEL * 0 then
                    love.graphics.setColor(255, 0, 0, 200)
                end
                love.graphics.arc("fill", x, y, self.radius-3, a1, a2, self.SEGMENTS)
            else
                -- love.graphics.setColor(255, 0, 0, 200)
                -- love.graphics.print("E", self.x-4, self.y-7)
                love.graphics.setColor(255, 0, 0, 200)
                love.graphics.arc("line", x, y, self.radius/3, 0, math.pi * 2, self.SEGMENTS)
            end

            -- Self destruct
            if self.self_destruct > 0 then
                love.graphics.setColor(255, 0, 0, math.abs(math.sin(love.timer.getMicroTime()*14)*255))
                love.graphics.setFont(the.app.small_font)
                love.graphics.print(math.ceil(self.self_destruct*100)/100, self.x + self.radius + 5, self.y - 10)
            end
        end

        if self.state == self.STATE_DEAD then
        end

        love.graphics.pop()
    end,

    explode = function(self)
        if self.state == self.STATE_DEAD then
            return false
        end

        if not the.view:contains(self.explosion_emitter) then
            the.app:add(self.explosion_emitter)
        end

        self.explosion_emitter.x = self.x
        self.explosion_emitter.y = self.y
        self.explosion_emitter:explode()

        love.audio.play(self.explosion_snd)
        if not self.self_destruct_snd:isStopped() then
            self.self_destruct_snd:stop()
        end
        if not self.thrust_snd:isStopped() then
            self.thrust_snd:stop()
        end

        the.app:changeState(the.app.STATE_GAMEOVER)
    end,

    selfDestruct = function(self)
        if self.self_destruct == 0 then
            self.self_destruct = 3
        end
    end,

    thrust = function(self, x, y)
        if self.state == self.STATE_DEAD then return end

        if self.fuel <= 0 then
            return
        end

        if x ~= nil then self.acceleration.x = x end
        if y ~= nil then self.acceleration.y = y end

        if self.thrust_snd:isStopped() then
            love.audio.play(self.thrust_snd)
        end

        -- This basically says, if we're thrusting in the opposite direction that we're moving,
        -- then shake the camera an amount proportional to the player's current speed.
        if (self.acceleration.x ~= 0 and self.acceleration.x/math.abs(self.acceleration.x) ~= self.velocity.x/math.abs(self.velocity.x)) then
            the.app.shake = self.speed * 0.01
        end
        if (self.acceleration.y ~= 0 and self.acceleration.y/math.abs(self.acceleration.y) ~= self.velocity.y/math.abs(self.velocity.y)) then
            the.app.shake = self.speed * 0.01
        end

        self.is_thrusting = true
    end,

    reset = function(self)
        self.x = arena.width/2
        self.y = arena.height/2
        self.fuel = self.STARTING_FUEL
        self.state = self.STATE_ALIVE
        self.velocity.x = 0
        self.velocity.y = 0
        self.acceleration.x = 0
        self.acceleration.y = 0
        self.self_destruct = 0
    end,

    addFuel = function(self, fuel)
        if self.state == self.STATE_DEAD then return end

        if fuel > 0 and self.fuel >= self.MAX_FUEL then
            score:add(fuel)
            if self.surplus_snd:isStopped() then
                love.audio.play(self.surplus_snd)
            end
        else
            self.fuel = self.fuel + fuel
        end
        if self.fuel <= 0 then
            self.fuel = 0
            if self.out_of_fuel_snd:isStopped() then
                love.audio.play(self.out_of_fuel_snd)
            end
        end
    end,

    onUpdate = function(self, dt)
        if self.x < self.radius then
            self.x = self.radius
            self.velocity.x = -self.velocity.x
            self.bounce_snd:stop()
            love.audio.play(self.bounce_snd)
            arena:highlightWall(self, 0, self.y)
        end
        if self.x > arena.width - self.radius then
            self.x = arena.width - self.radius
            self.velocity.x = -self.velocity.x
            self.bounce_snd:stop()
            love.audio.play(self.bounce_snd)
            arena:highlightWall(self, arena.width, self.y)
        end
        if self.y < self.radius then
            self.y = self.radius
            self.velocity.y = -self.velocity.y
            self.bounce_snd:stop()
            love.audio.play(self.bounce_snd)
            arena:highlightWall(self, self.x, 0)
        end
        if self.y > arena.height - self.radius then
            self.y = arena.height - self.radius
            self.velocity.y = -self.velocity.y
            self.bounce_snd:stop()
            love.audio.play(self.bounce_snd)
            arena:highlightWall(self, self.x, arena.height)
        end

        if self.is_thrusting then
            self:addFuel(-self.FUEL_BURN_PER_SECOND * dt)

            if self.exhaust_elapsed > self.exhaust_period then
                the.view.factory:create(Exhaust)
                self.exhaust_elapsed = 0
            end
        else
            if not self.thrust_snd:isStopped() then
                self.thrust_snd:stop()
            end
        end

        if self.self_destruct > 0 then
            if self.self_destruct_snd:isStopped() then
                love.audio.play(self.self_destruct_snd)
            end
            self.self_destruct = self.self_destruct - dt
            if self.self_destruct <= 0 then
                self.self_destruct = 0
                self:explode()
            end
        end

        -- Calculate speed (velocity magnitude)
        self.speed = math.sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y)

        self.exhaust_elapsed = self.exhaust_elapsed + dt

        self.acceleration.x = 0
        self.acceleration.y = 0
        self.is_thrusting = false
    end
}

Exhaust = Sprite:extend{
    MAX_RADIUS = 3,
    lifetime = 0.5,
    elapsed = 0,
    alpha = 255,
    width = 1,
    height = 1,

    onNew = function(self)
        the.app:add(self)
    end,

    onReset = function(self)
        self.elapsed = 0
        local a = math.max(math.abs(player.acceleration.x), math.abs(player.acceleration.y))
        self.x = player.x - player.radius * player.acceleration.x/a
        self.y = player.y - player.radius * player.acceleration.y/a
        self.velocity.x = -player.acceleration.x*1.5 + player.velocity.x + math.random(-player.THRUST/10,player.THRUST/10)
        self.velocity.y = -player.acceleration.y*1.5 + player.velocity.y + math.random(-player.THRUST/10,player.THRUST/10)
        self.starting_alpha = math.random(255,255)
        self.radius = 1
    end,

    onUpdate = function(self, dt)
        self.elapsed = self.elapsed + dt
        if self.elapsed >= self.lifetime then
            the.view.factory:recycle(self)
        end

        self.radius = 1 + self.MAX_RADIUS * self.elapsed/self.lifetime
        self.alpha = self.starting_alpha * (1 - self.elapsed/self.lifetime)
    end,

    onDraw = function(self, x, y)
        love.graphics.push()

        love.graphics.setColor(255, 255, 255, self.alpha)
        love.graphics.circle("line", x, y, self.radius, 10)

        love.graphics.pop()
    end
}
