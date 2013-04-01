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

bonus1k = Text:extend{
    text = "",
    tint = { 1, 0, 0 },
    font = {"fnt/jupiter.ttf", 16},
    align = "center",
    width = 50,
    height = 10,
    alpha = 1,
    x = 0,
    y = 0,

    onEmit = function (self, emitter)
        self.x = player.x - player.radius * 2 - 5
        self.y = player.y - player.radius * 2 - 10

        self.alpha = 1
        self.velocity.y = -10
        self.text = emitter.text

        local t = 1
        the.view.tween
            :start(self, 'alpha', 0, t, 'quadIn')
            :andThen(function() self:die() end)
    end
}

bonusx10 = Text:extend{
    text = "x10",
    tint = { 1, 0, 0 },
    font = {"fnt/jupiter.ttf", 12},
    align = "center",
    width = 25,
    height = 10,
    alpha = 1,
    x = 0,
    y = 0,

    onEmit = function (self, emitter)
        self.x = player.x
        self.y = player.y

        self.alpha = 1
        self.velocity = { x = math.random(-50, 50), y = math.random(-50, 50) }
        self.tint = { math.random(), math.random(), 1 }

        local t = 2
        the.view.tween
            :start(self, 'alpha', 0, t, 'quadIn')
            :andThen(function() self:die() end)
    end
}

