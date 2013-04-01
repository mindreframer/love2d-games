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

asteroid = Sprite:extend{
    MAX_VELOCITY_X = 25,
    MAX_VELOCITY_Y = 30,

    BIG_ROCK = 25,
    GIANT_ROCK = 50,
    EXTINCTION_ROCK = 400,

    DAMAGE = 5,

    MIN_SIZE = 5,

    id = 'asteroid',
    alpha = 255,
    scale = 1,
    solid = true,

    onNew = function(self)
        self.explosion_snd = love.audio.newSource('snd/explosion.ogg', 'static')
        self.explosion_snd:setLooping(false)
        self.explosion_snd:setVolume(0.5)

        self.size = self.size or self.MIN_SIZE
        self.original_size = self.size
        self.kind = 'normal'
        self.width = self.size
        self.height = self.size
        self.velocity = {
            x = math.random() * self.MAX_VELOCITY_X*2 - self.MAX_VELOCITY_X,
            y = self.MAX_VELOCITY_Y,
            rotation = math.random() * 20 - 10
        }
        self.acceleration.y = 10

        self.y = 0 - self.size
        self.x = math.random(love.graphics.getWidth())

        -- Fire and smoke
        self.fireTrail = fireEmitter:new()
        self.fireTrail:setup(self)
        self.fireTrail:loadParticles(fire, 100)
        the.app:add(self.fireTrail)

        -- Changes for big asteroids        
        if self.size >= self.BIG_ROCK then
            self.velocity.x = self.velocity.x * 0.25
            self.velocity.rotation = self.velocity.rotation * 0.1
            self.fireTrail.emitCount = 2
        end

        if self.size == self.EXTINCTION_ROCK then
            self.x = love.graphics.getWidth()/2
            self.velocity = {
                x = 0,
                rotation = 1
            }
        end
    end,

    onUpdate = function(self, dt)
        if self.y > GROUND_HEIGHT then
            self:explodeAndDie()
        end
    end,

    onDraw = function(self)
        love.graphics.push()

        love.graphics.setColor(200, 0, 0, self.alpha)

        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.rotation)
        love.graphics.circle('fill', 0, 0, self.size * self.scale, 5)

        love.graphics.pop()

        love.graphics.setColor(255, 255, 255, 255)
    end,

    onCollide = function(self, other, x_overlap, y_overlap)
        if other.id == 'swarm_member' then
            self.size = self.size - self.DAMAGE
            self.width = self.size
            self.height = self.size
            if self.size <= 1 then
                the.app.score.hit = the.app.score.hit + 1
                self:explodeAndDie()
            else
                self:explode()
            end
        end
    end,

    explode = function(self)
        self.explosion_snd:play()

        if not the.app.playView.ending then
            the.app.playView:flash({255,255,255}, 0.25)
        end

        local explosion = explosionEmitter:new()
        explosion.x = self.x
        explosion.y = self.y
        explosion:loadParticles(explosionParticle, 25)
        explosion:explode()
        the.app:add(explosion)
        the.app.playView.timer:after(EXPLOSION_LIFE, function() the.app:remove(explosion) end)

    end,

    explodeAndDie = function(self)
        self:explode()
        
        self:collide(the.app.playView)

        self:die()
        the.app:remove(self)

        self.fireTrail.emitting = false
        the.app.playView.timer:after(FIRE_LIFE, function() the.app:remove(self.fireTrail) end)
    end,
}
