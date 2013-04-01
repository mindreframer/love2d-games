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

Fuel = Sprite:extend{
    STATE_FLOATING = 1,
    STATE_EVAPORATING = 2,
    FUEL_DRAIN_PER_SECOND = 60,
    FUEL_SIZE_RATIO = 0.35,
    TRACTOR_GRAVITY = 20,

    acceleration = { x = 0, y = 0 },
    alpha = 0,

    onNew = function(self)
        -- Stream to keep memory usage low
        -- This is in Fuel, like the rest of the tractor beam code, to
        -- make it easier to have multiple tractor sounds going at once.
        self.tractor_snd = love.audio.newSource("snd/tractor_beam.ogg", "static")
        self.tractor_snd:setVolume(0.25)
        self.ding_snd = love.audio.newSource("snd/ding.ogg", "static")
        self.ding_snd:setVolume(0.75)

        self.x = math.random(0, arena.width)
        self.y = math.random(0, arena.height)
        self.fuel = math.random(10,50)
        self.radius = self.fuel * self.FUEL_SIZE_RATIO
        self.width = self.radius
        self.height = self.radius
        self.velocity = { x = math.random(-25,25), y = math.random(-25,25), rotation = math.random(-math.pi, math.pi) * 8/self.radius }

        the.view.tween:start(self, 'alpha', 1, 0.75)

        self.state = self.STATE_FLOATING
    end,

    onDraw = function(self, x, y)
        love.graphics.push()

        love.graphics.setLineWidth(2)

        if self.state == self.STATE_EVAPORATING then
            love.graphics.setColor(255, 255, 255, 255 * math.random())
            love.graphics.line(x, y, player.x + the.view.translate.x, player.y + the.view.translate.y)
            love.graphics.setColor(100, 200, 255, 255 * self.alpha)
        else
            love.graphics.setColor(255, 255, 255, 255 * self.alpha)
        end

        love.graphics.translate(x, y)
        love.graphics.rotate(self.rotation)
        
        local radius = self.radius
        if radius < 2 then radius = 2 end
        love.graphics.circle("line", 0, 0, radius, 5)

        love.graphics.pop()
    end,

    collide = function(self, other)
        if self:distanceTo(other) <= other.radius * 4 then
            if self.onCollide then
                self:onCollide(other, 0, 0)
            end
            
            if other.onCollide then
                other:onCollide(self, 0, 0)
            end

            return true
        end
        return false
    end,

    onUpdate = function(self, dt)
        if self.demo == true then return end

        self.state = self.STATE_FLOATING

        if self:collide(player) then
            if player.state == player.STATE_ALIVE then
                self.state = self.STATE_EVAPORATING

                if self.tractor_snd:isStopped() then
                    love.audio.play(self.tractor_snd)
                end

                -- Calculate vector to player and pull him in
                local dx = self.x - player.x
                local dy = self.y - player.y
                local n = math.max(math.abs(dx), math.abs(dy))
                player.acceleration.x = dx/n * self.TRACTOR_GRAVITY
                player.acceleration.y = dy/n * self.TRACTOR_GRAVITY

                player:addFuel(self.FUEL_DRAIN_PER_SECOND * dt)
                self.fuel = self.fuel - self.FUEL_DRAIN_PER_SECOND * dt
                self.radius = self.fuel * self.FUEL_SIZE_RATIO

                if self.fuel <= 0 then
                    if not self.tractor_snd:isStopped() then
                        self.tractor_snd:stop()
                    end
                    if self.ding_snd:isStopped() then
                        love.audio.play(self.ding_snd)
                    end
                    score:addBonus(1000)
                    fuel:destroy(self)
                    fuel:create(1)
                end
            end
        else
            if not self.tractor_snd:isStopped() then
                self.tractor_snd:stop()
            end
        end

        if self.x < self.radius then
            self.x = self.radius
            self.velocity.x = -self.velocity.x
            arena:highlightWall(self, 0, self.y)
        end
        if self.x > arena.width - self.radius then
            self.x = arena.width - self.radius
            self.velocity.x = -self.velocity.x
            arena:highlightWall(self, arena.width, self.y)
        end
        if self.y < self.radius then
            self.y = self.radius
            self.velocity.y = -self.velocity.y
            arena:highlightWall(self, self.x, 0)
        end
        if self.y > arena.height - self.radius then
            self.y = arena.height - self.radius
            self.velocity.y = -self.velocity.y
            arena:highlightWall(self, self.x, arena.height)
        end
    end,
}

fuel = {
    list = {},

    create = function(self, n)
        if n == nil then n = 1 end

        for i = 1,n do
            local f = Fuel:new()
            table.insert(self.list, f)
            the.app:add(f)
        end
    end,

    destroy = function(self, object)
        for i = #self.list,1,-1 do
            if self.list[i] == object then
                table.remove(self.list, i)
                the.app:remove(object)
                object:die()
            end
        end
    end,

    destroyAll = function(self)
        for i = #self.list,1,-1 do
            the.app:remove(self.list[i])
            self.list[i]:die()
            table.remove(self.list, i)
        end
    end,

    attackingPlayer = function(self)
        for i = 1,#self.list do
            if self.list[i].state == Fuel.STATE_EVAPORATING then
                return true
            end
        end
        return false
    end
}
