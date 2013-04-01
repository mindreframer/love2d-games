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

swarm = Sprite:extend{
    MAX_MEMBERS = 50,

    id = 'swarm',
    members = {},
    width = 1,
    height = 1,
    solid = false,

    onNew = function(self)
        self:reset()
    end,

    onUpdate = function(self)
        self.x = love.mouse.getX()
        self.y = love.mouse.getY()
    end,

    addMember = function(self, count, x, y)
        count = count or 1

        if #self.members >= self.MAX_MEMBERS then
            return
        end

        for i = 1, count do
            local m = swarm_member:new()
            m:init(self)
            m.x = x or math.random(love.graphics.getWidth())
            m.y = y or math.random(love.graphics.getHeight())
            table.insert(self.members, m)
        end
    end,

    remove = function(self, object)
        for i = #self.members,1,-1 do
            if self.members[i] == object then
                table.remove(self.members, i)
                the.app:remove(object)
                object:die()
            end
        end
    end,

    reset = function(self)
        for i = #self.members,1,-1 do
            the.app:remove(self.members[i])
            self.members[i]:die()
            table.remove(self.members, i)
        end
    end,
}

swarm_member = Sprite:extend{
    ACCELERATION = 100,
    MAX_SPEED = 250,

    id = 'swarm_member',
    width = 10,
    height = 10,
    solid = true,
    dist = 0,
    t = 0,

    init = function(self, swarm)
        self.swarm = swarm
        self.x = math.random(love.graphics.getWidth())
        self.y = math.random(love.graphics.getHeight())
        self.minVelocity = { x = -self.MAX_SPEED, y = -self.MAX_SPEED }
        self.maxVelocity = { x = self.MAX_SPEED, y = self.MAX_SPEED }
        self.offset = 0
        -- self.offset = math.pi * math.random(0,1)
        -- self.offset = math.pi/4 * math.random(0,8)
        -- self.drag = { x = self.MAX_SPEED/5, y = self.MAX_SPEED/5 }
    end,

    onNew = function(self, swarm)
        the.app:add(self)
    end,

    onUpdate = function(self, dt)
        -- Update timer
        self.t = the.app.beat.timer_radians;

        -- Move towards swarm center
        local othervector = vector(self.swarm.x, self.swarm.y)
        local myvector = vector(self.x - self.width, self.y - self.height)
        self.dir = (othervector - myvector):normalized()
        self.dist = myvector:dist(othervector)

        local n = 1000/math.max(self.dist,10)
        local accel = self.ACCELERATION * n
        self.acceleration = { x = self.dir.x * accel, y = self.dir.y * accel }

        -- Collision detection to keep minimum distance from other members
        self:collide(the.app.playView)
    end,

    onCollide = function(self, other, x_overlap, y_overlap)
        if other.id == 'asteroid' then
            self.swarm:remove(self)
        end

        if other.id == 'swarm_member' then
            self:displace(other)
        end
    end,

    onDraw = function(self)
        local c = math.abs(math.sin(self.t * 2)) * 255 - 255 * self.dist/100
        local bounce = math.sin(self.t * 4 + self.offset)*self.width
        local sway = math.sin(self.t * 5 + self.offset)*self.width/5

        love.graphics.setColor(c, c, c)
        love.graphics.circle("fill", self.x + sway, self.y + bounce, self.width/2, 5)

        love.graphics.setColor(255,255,255,255)
    end,
}
