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

startView = View:extend {
    id = 'startview',
    
    onNew = function(self)
        self:add(Animation:new{width = love.graphics.getWidth(), height = love.graphics.getHeight(), image = 'img/title-screen.png'})

        self.city = TextInput:new{
            width = 150,
            x = 325,
            y = 240,
            text = '',
            font = { 'fnt/visitor1.ttf', 24 },
            tint = { 0, 0.8, 0 },
            wordWrap = false,
            align = 'left'
        }

        self:add(self.city)

        self:add(
            Button:new{
                label = nil,
                background = Animation:new{ width = 100, height = 50, image = 'img/play-button.png', tint = { 0.75, 0.75, 0.75 } },
                x = 275,
                y = 300,

                onMouseEnter = function(self)
                    self.background.tint = { 1, 1, 1 }
                end,

                onMouseExit = function(self)
                    self.background.tint = { 0.75, 0.75, 0.75 }
                end,

                onMouseUp = function(self)
                    if string.len(the.app.startView.city.text) > 0 then
                        the.app.city = the.app.startView.city.text
                    else
                        the.app.city = 'your home town'
                    end
                    the.app:changeState(the.app.STATE_PLAYING)
                end
            }
        )

        self:add(
            Button:new{
                label = nil,
                background = Animation:new{ width = 100, height = 50, image = 'img/quit-button.png', tint = { 0.75, 0.75, 0.75 } },
                x = 425,
                y = 300,

                onMouseEnter = function(self)
                    self.background.tint = { 1, 1, 1 }
                end,

                onMouseExit = function(self)
                    self.background.tint = { 0.75, 0.75, 0.75 }
                end,

                onMouseUp = function(self)
                    love.event.push("quit")
                end
            }
        )
    end,
    
    onUpdate = function(self, dt)
    end,

    onDraw = function(self)
        love.graphics.setFont(the.app.font)
        love.graphics.setColor(255, 255, 255, 255)

        love.graphics.printf('--' .. the.app.name .. "--\nby John Watson February 2013", 0, 50, love.graphics.getWidth(), "center")

        love.graphics.setFont(the.app.font_small)
        love.graphics.printf("Art: David Baumgart (cc-by)  /  Music: Nine Inch Nails (cc-by-nc-sa)", 0, 100, love.graphics.getWidth(), "center")
        love.graphics.setFont(the.app.font)

        love.graphics.printf("The sky is falling!\nQuick! Use the meteor shield!\nWhat is the name of your city?", 0, 150, love.graphics.getWidth(), "center")

        love.graphics.setColor(255, 255, 255, 255)
    end
}
