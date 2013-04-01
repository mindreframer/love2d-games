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

arena = Fill:extend{
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight() - 100,
    fill = { 0, 0, 0, 0 },
    border = { 255, 255, 255, 0 },

    highlightWall = function(self, object, x, y)
        if object == player then
            the.app.shake = 1
            the.view.tween:start(the.app, 'shake', 0, 0.25)
        end

        local o = the.view.factory:create(arenaBounceHighlight)
        if x == 0 then
            o.x = 1
            o.y = y - o.MAX_SIZE/2
            o.width = 1
            o.height = o.MAX_SIZE
        elseif x == arena.width then
            o.x = arena.width - 1
            o.y = y - o.MAX_SIZE/2
            o.width = 1
            o.height = o.MAX_SIZE
        elseif y == 0 then
            o.x = x - o.MAX_SIZE/2
            o.y = 1
            o.width = o.MAX_SIZE
            o.height = 1
        elseif y == arena.height then
            o.x = x - o.MAX_SIZE/2
            o.y = arena.height - 1
            o.width = o.MAX_SIZE
            o.height = 1
        end
        o:shrink()
    end,
}

arenaBounceHighlight = Fill:extend{
    MAX_SIZE = 50,
    TIMER = 0.25,
    width = 1,
    height = 1,
    fill = { 100, 200, 255, 255 },
    border = { 0, 0, 0, 0 },

    onNew = function(self)
        the.app:add(self)
    end,

    onReset = function(self)
        self.alpha = 1

        the.view.tween
            :start(self, 'alpha', 0, self.TIMER)
            :andThen(function() the.view.factory:recycle(self) end)
    end,

    shrink = function(self)
        self.center = {}
        self.center.x = self.x + self.width/2
        self.center.y = self.y + self.height/2
        if self.height > self.width then
            the.view.tween:start(self, 'height', 1, self.TIMER)
            the.view.tween:start(self, 'y', self.center.y, self.TIMER)
        else
            the.view.tween:start(self, 'width', 1, self.TIMER)
            the.view.tween:start(self, 'x', self.center.x, self.TIMER)
        end
    end
}
