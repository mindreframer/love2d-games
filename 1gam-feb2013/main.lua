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

DEBUG = false
STRICT = false

require 'zoetrope'
require 'startview'
require 'playview'
require 'pauseview'
require 'gameoverview'
require 'particles'
vector = require 'vector'


the.app = App:new{
    STATE_START = 1,
    STATE_PLAYING = 2,
    STATE_PAUSED = 3,
    STATE_GAMEOVER = 4,
    elapsed = 0,
    BPM = 61, -- Beats/minute
    beat = {},

    name = "Meteor Defense",

    timer = 0,
    timer_radians = 0,

    score = { hit = 0, missed = 0, days = 0 },

    onRun = function(self)
        -- Load audio, font, graphics
        self.music = love.audio.newSource('snd/music.mp3', 'stream')
        self.music:setLooping(true)
        self.music:play()

        the.app.font = love.graphics.newFont('fnt/visitor1.ttf', 24)
        the.app.font_small = love.graphics.newFont('fnt/visitor1.ttf', 18)

        self:changeState(self.STATE_START)
    end,

    changeState = function(self, state)
        if state == self.STATE_START then
            if not self.startView then
                self.startView = startView:new()
            end
            love.mouse.setVisible(true)
            self.view = self.startView
        end

        if state == self.STATE_PAUSED then
            if not self.pauseView then
                self.pauseView = pauseView:new()
            end
            love.mouse.setVisible(true)
            self.view = self.pauseView
        end

        if state == self.STATE_PLAYING then
            love.mouse.setVisible(false)
            if self.state == self.STATE_START then
                self.playView = playView:new()
            end
            self.view = self.playView
            if self.state == self.STATE_START then
                self.playView:init()
            end
        end

        if state == self.STATE_GAMEOVER then
            if not self.gameoverView then
                self.gameoverView = gameoverView:new()
            end
            love.mouse.setVisible(true)
            self.view = self.gameoverView
        end

        self.state = state
    end,

    onUpdate = function(self, dt)
        self.elapsed = self.elapsed + dt

        self.beat.beats_per_minute = self.BPM
        self.beat.beats_per_second = self.BPM/60
        self.beat.radians_per_beat = math.pi
        self.beat.radians_per_second = self.beat.beats_per_second * self.beat.radians_per_beat
        self.beat.timer = self.beat.beats_per_second * self.elapsed
        self.beat.timer_radians = self.beat.radians_per_second * self.elapsed
    end,
}

function formatNumber(n)
    local retval = ""
    for i = 1,string.len(n) do
        retval = string.sub(n, -i, -i) .. retval
        if i % 3 == 0 and i < string.len(n) then
            retval = ',' .. retval
        end
    end
    return retval
end