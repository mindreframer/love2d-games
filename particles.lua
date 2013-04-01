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

FIRE_LIFE = 1

fireEmitter = Emitter:extend{
    id = 'fire_emitter',

    period = 0.1,
    emitCount = 1,

    setup = function(self, parent)
        self.parent = parent
    end,

    onEmit = function(self)
        self.width = self.parent.width
        self.height = self.parent.height
        self.x = self.parent.x - self.width/2
        self.y = self.parent.y - self.height/2
    end
}

fire = Fill:extend{
    id = 'fire',

    fill = {255, 255, 255},
    alpha = 1,
    width = 3,
    height = 3,
    solid = false,

    onEmit = function(self)
        self.alpha = 1
        self.tint = { 1, 0.75, 0 }
        self.width = 3
        self.height = 3
        self.velocity.y = -5

        the.view.tween:start(self, 'alpha', 0, FIRE_LIFE, 'quadIn')
        the.view.tween:start(self, 'width', 10, FIRE_LIFE, 'quadIn')
        the.view.tween:start(self, 'height', 10, FIRE_LIFE, 'quadIn')
        the.view.tween:start(self, 'tint', { 1, 0, 0 }, FIRE_LIFE, 'quadIn')
            :andThen(function() self:die() end)
    end
}

EXPLOSION_LIFE = 2

explosionEmitter = Emitter:extend{
    id = 'explosion_emitter',

    width = 1,
    height = 1,

    min = { velocity = { x = -150, y = -150 }},
    max = { velocity = { x = 150, y = 150 }}
}

explosionParticle = Fill:extend{
    id = 'explosion_particle',

    width = 2,
    height = 2,
    fill = {255, 255, 255},
    onEmit = function (self)
        self.tint = { 1, 1, 1 }
        self.width = math.random(2,6)
        self.height = 2
        self.alpha = 1
        self.acceleration.y = 50

        local t = math.random() * EXPLOSION_LIFE
        the.view.tween:start(self, 'rotation', math.random(-4, 4)*math.pi, t)
        the.view.tween
            :start(self, 'alpha', 0, t)
            :andThen(function() self:die() end)
    end
}

SMOKE_LIFE = 3

smokeEmitter = Emitter:extend{
    id = 'smoke_emitter',

    width = 10,
    height = 10,

    period = 1,
    emitCount = 1,
}

-- smoke = Fill:extend{
smoke = Animation:extend{
    id = 'smoke_particle',

    image = 'img/smoke.png',
    solid = false,
    fill = {255, 255, 255},

    onEmit = function (self)
        local v = math.random()
        self.tint = { v, v, v }
        self.width = 10
        self.height = self.width
        self.alpha = 0.8
        self.scale = 2
        self.velocity.y = -30
        self.velocity.x = 0
        self.acceleration.x = 4

        local t = SMOKE_LIFE
        the.view.tween:start(self, 'scale', self.scale*3, t)
        the.view.tween
            :start(self, 'alpha', 0, t)
            :andThen(function() self:die() end)
    end
}
