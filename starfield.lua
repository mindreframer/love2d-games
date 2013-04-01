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

starfield = Emitter:new{
    period = 0.05,
    emitCount = 1,

    onEmit = function(self)
        self.x = player.x
        self.y = player.y
    end
}

star = Fill:extend{
    MAX_SIZE = 3,
    MAX_SPEED = 40,
    MAX_BRIGHTNESS = 0.6,

    fill = {255, 255, 255},

    onEmit = function (self)
        local size = math.random()*self.MAX_SIZE + 1

        -- Make more particles offscreen on the right where they
        -- are floating in from to prevent the starfield from having
        -- big gaps on the right side.
        self.x = math.random(love.graphics.getWidth())*1.5
        self.y = math.random(love.graphics.getHeight())

        -- Star movement is based on brightness
        -- Brighter stars are closer and move faster
        self.width = size
        self.height = size
        self.alpha = math.random() * self.MAX_BRIGHTNESS
        self.velocity.x = -self.alpha * self.MAX_SPEED - 1
    end
}

starfield:loadParticles(star, 500)
