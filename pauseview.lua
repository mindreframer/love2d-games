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

pauseView = View:extend {
    id = 'pauseview',

    onNew = function(self)
    end,
    
    onUpdate = function(self, dt)
        if the.keys:justPressed('escape') then
            the.app:changeState(the.app.STATE_GAMEOVER)
        end

        if the.keys:justPressed(' ') then
            the.app:changeState(the.app.STATE_PLAYING)
        end
    end,

    onDraw = function(self)
        the.app.playView:draw()
        
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(the.app.font)
        
        love.graphics.print('Paused\n\nPress Space to continue, ESC to quit', 50, 50)
        
        love.graphics.setColor(255, 255, 255, 255)
    end
}
