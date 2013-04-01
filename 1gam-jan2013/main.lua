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

DEBUG = true
STRICT = true

require 'zoetrope'
require 'particles'
require 'arena'
require 'player'
require 'starfield'
require 'fuel'
require 'hud'
require 'enemy'
require 'score'
require 'levels'

the.app = App:new{
    STATE_START = 1,
    STATE_GAMEOVER = 2,
    STATE_PLAYING = 3,

    name = "eins eins funf (115) :: #onegameamonth jan/2013",
    shake = 0,
    level = 1,
    scanlines = false,

    onRun = function(self)
        self.small_font = love.graphics.newFont("fnt/jupiter.ttf", 16)
        self.big_font = love.graphics.newFont("fnt/jupiter.ttf", 30)
        self.huge_font = love.graphics.newFont("fnt/jupiter.ttf", 40)
        self.enemy_font = love.graphics.newFont("fnt/8thcargo.ttf", 16) -- No symbols

        self.levelup_snd = love.audio.newSource("snd/levelup.ogg", "static")
        self.levelup_snd:setLooping(false)
        self.levelup_snd:setVolume(0.75)

        self.songs = {
            love.audio.newSource("snd/song1.ogg", "stream"),
            love.audio.newSource("snd/song2.ogg", "stream"),
            love.audio.newSource("snd/song3.ogg", "stream"),
        }

        self.start_overlay = love.graphics.newImage("img/start.png")
        hud.bg = love.graphics.newImage("img/hud.png")

        -- Uncomment this line to bloom the sprites in the play area
        -- self.view:setEffect("vfx/bloom.shader", "screen")

        -- Uncomment this line to draw retro scanlines on the screen
        -- self.scanlines = true
        
        love.mouse.setVisible(false)

        -- Sprite for showing level information
        self.level_spr = Text:new{
            text = "",
            tint = { 1, 0, 0 },
            font = {"fnt/jupiter.ttf", 36},
            align = "center",
            width = arena.width,
            height = 50,
            alpha = 0,
            x = 0,
            y = 0,

            show = function(self, text, seconds)
                self.alpha = 1
                self.text = text
                the.view.tween:start(self, 'alpha', 0, seconds, "quadIn")
            end
        }
        self:add(self.level_spr)

        -- Instructions sprite
        self.instr_spr = Text:new{
            text = "",
            tint = { 1, 0, 0 },
            font = {"fnt/jupiter.ttf", 36},
            align = "center",
            width = arena.width,
            height = 50,
            alpha = 0,
            x = 0,
            y = 50,
            lines = {
                "W,A,S,D TO MOVE",
                "WATCH YOUR FUEL",
                "COLLECT FUEL FROM ASTEROIDS",
                "COLLECT EXTRA FUEL TO ADVANCE",
                "AVOID MINES"
            },

            show = function(self)
                self.beep = love.audio.newSource("snd/homing.ogg", "static")

                love.audio.play(self.beep)
                local s = 2
                self.alpha = 1
                self.text = self.lines[1]
                the.view.tween:start(self, 'alpha', 0, s, "quadIn")
                :andThen(
                    function()
                        love.audio.play(self.beep)
                        self.alpha = 1
                        self.text = self.lines[2]
                        the.view.tween:start(self, 'alpha', 0, s, "quadIn")
                        :andThen(
                            function()
                                love.audio.play(self.beep)
                                self.alpha = 1
                                self.text = self.lines[3]
                                the.view.tween:start(self, 'alpha', 0, s, "quadIn")
                                :andThen(
                                    function()
                                        love.audio.play(self.beep)
                                        self.alpha = 1
                                        self.text = self.lines[4]
                                        the.view.tween:start(self, 'alpha', 0, s, "quadIn")
                                        :andThen(
                                            function()
                                                love.audio.play(self.beep)
                                                self.alpha = 1
                                                self.text = self.lines[5]
                                                the.view.tween:start(self, 'alpha', 0, s, "quadIn")
                                            end)
                                        end)
                                    end)
                    end)
            end
        }
        self:add(self.instr_spr)

        self:add(starfield)
        starfield:explode()
        starfield.emitting = true

        self:add(player)
        self:add(arena)
        fuel:create(20)
        enemies:create(3)

        -- Enemy for the start screen
        self.enemy_start = Enemy:new{ demo = true }

        -- Enemy and asteroid for the HUD scanner
        hud.scanner_view = View:new()
        hud.scanner_enemy = Enemy:new{ demo = true }
        hud.scanner_view:add(hud.scanner_enemy)
        self:add(hud.scanner_view)

        -- Bonus emitters
        self.bonus1k_emitter = Emitter:new{
            x = 0,
            y = 0,
            width = 1,
            height = 1,
            text = "+1000",

            setText = function(self, text)
                self.text = text
            end,

            onEmit = function(self)
                self.x = player.x
                self.y = player.y
            end
        }
        self.bonus1k_emitter:loadParticles(bonus1k, 5)
        self:add(self.bonus1k_emitter)

        self.bonusx10_emitter = Emitter:new{
            x = 0,
            y = 0,
            width = 1,
            height = 1,

            onEmit = function(self)
                self.x = player.x
                self.y = player.y
            end
        }
        self.bonusx10_emitter:loadParticles(bonusx10, 100)
        self:add(self.bonusx10_emitter)

        -- Start music
        the.view.timer:every(10, function() self:changeMusic() end)
        self:changeMusic()

        -- Start game
        score:startGame()
        the.view.timer:every(1, function() score:update() end)

        self:changeState(self.STATE_START)
    end,

    changeMusic = function(self, n)
        local playing = false
        for i,song in pairs(self.songs) do
            if not song:isStopped() then
                playing = true
                break
            end
        end
        if not playing then
            if n == nil then
                -- Try to choose a random song different than the last one
                for i = 1,10 do
                    n = math.random(1,#self.songs)
                    if n ~= self.last_song then
                        break
                    end
                end
            end
            self.last_song = n
            self.songs[n]:setVolume(0.3)
            love.audio.play(self.songs[n])
        end
    end,

    changeState = function(self, state)
        if state == self.STATE_START then
            player.state = player.STATE_DEAD
            self:add(self.enemy_start)

            self.state = state
        end

        if state == self.STATE_PLAYING then
            self:remove(self.enemy_start)

            self.state = state
        end

        if state == self.STATE_GAMEOVER then
            self.fpm = score:getFuelPerMinute()
            player.state = player.STATE_DEAD

            self.state = state
        end
    end,

    onUpdate = function(self, dt)
        if self.state == self.STATE_START then
            self:updateStart()
        end

        if self.state == self.STATE_GAMEOVER then
            self:updateGameover()
        end

        if self.state == self.STATE_PLAYING then
            self:updatePlaying()
        end
    end,

    updateStart = function(self)
        -- Adapt an enemy for use on the start screen
        self.enemy_start.x = arena.width - 150
        self.enemy_start.y = arena.height - 100
        self.enemy_start.state = Enemy.STATE_HOMING
        self.enemy_start.scale = 8

        if the.keys:justPressed('escape') then
            love.event.push("quit")
        end

        if the.keys:justPressed(' ', '1', '2', '3', '4', '5', '6', '7', '8', '9') then
            self:changeState(self.STATE_PLAYING)
            
            score:startGame()

            fuel:destroyAll()
            enemies:destroyAll()

            player:reset()

            if the.keys.typed == ' ' then
                self.level = 1
            else
                self.level = string.byte(the.keys.typed) - string.byte('0')
            end

            self.level_spr:show("LEVEL " .. self.level, 4)
            if self.level == 1 then
                the.view.timer:after(2, function() self.instr_spr:show() end)
            end

            fuel:create(20)
            enemies:create(levels[self.level].enemies)

            -- self.view.focus = player
            -- self.view:clampTo(arena)
        end
    end,

    updateGameover = function(self)
        if the.keys:justPressed('escape') then
            love.event.push("quit")
        end

        if the.keys:justPressed(' ') then
            self:changeState(self.STATE_START)
        end
    end,

    updatePlaying = function(self)
        if the.keys:justPressed('escape') then
            self:changeState(self.STATE_START)
        end
        if the.keys:pressed('w') then
            player:thrust(nil, -player.THRUST)
        end
        if the.keys:pressed('s') then
            player:thrust(nil, player.THRUST)
        end
        if the.keys:pressed('a') then
            player:thrust(-player.THRUST, nil)
        end
        if the.keys:pressed('d') then
            player:thrust(player.THRUST, nil)
        end
        if the.keys:pressed('0') then
            player:selfDestruct()
        end

        -- Level advance
        local fuel_goal
        if levels[self.level] then
            fuel_goal = levels[self.level].fuel
        else
            fuel_goal = 1000
        end
        if score:getFuel() > fuel_goal then
            self.level = self.level + 1

            if self.levelup_snd:isStopped() then
                love.audio.play(self.levelup_snd)
            end

            score:startLevel()

            enemies:create(1)

            self.level_spr:show("LEVEL " .. self.level, 4)
        end
    end,

    onDraw = function(self)
        if self.state == self.STATE_START then
            self:drawStart()
        end

        if self.state == self.STATE_GAMEOVER then
            self:drawGameover()
        end

        if self.state == self.STATE_PLAYING then
            self:drawPlaying()
        end

        -- Scanlines
        if self.scanlines then
            love.graphics.setColor(0, 0, 0, 75)
            love.graphics.setLineWidth(1)
            for i = 1,love.graphics.getHeight(),3 do
                love.graphics.line(0, i, love.graphics.getWidth(), i)
            end
        end
    end,

    drawStart = function(self)
        hud:draw()

        local blink_factor = math.abs(math.sin(love.timer.getMicroTime()*1.2))

        -- love.graphics.setColor(0, 0, 0, 160)
        -- love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(self.start_overlay, 0, 0)

        love.graphics.setFont(self.big_font)
        local titles = "One Game A Month #1GAM\nJanuary 2013\n\"Eins Eins Funf (115)\"\n\nProgramming, art, music, sound, and design by John Watson\nflagrantdisregard.com\n\nSource + dev journal @ \ngithub.com/jotson/1gam-jan2013\n\n(c) 2013 John Watson\nLicensed under the MIT license"
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.printf(titles, 403, 43, 350, "right")
        love.graphics.setColor(100, 200, 255, 255)
        love.graphics.printf(titles, 400, 40, 350, "right")

        love.graphics.setFont(self.huge_font)
        love.graphics.setColor(255, 255, 255, blink_factor*200+55)
        love.graphics.printf("[SPACE] TO START", 0, arena.height+10, arena.width, "center")
        love.graphics.printf("[ESC] TO QUIT", 0, arena.height+40, arena.width, "center")
    end,

    drawGameover = function(self)
        hud:draw()

        local blink_factor = math.abs(math.sin(love.timer.getMicroTime()*1.2))

        love.graphics.setColor(0, 0, 0, 160)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setFont(self.huge_font)
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.printf("GAME OVER\nSCORE " .. formatNumber(score:getScore()) .. "\nFUEL/MINUTE " .. formatNumber(self.fpm) .. "\nLEVEL " .. self.level, 0, arena.height/2 - 100, arena.width, "center")
        love.graphics.setColor(255, 255, 255, blink_factor*200+55)
        love.graphics.printf("[SPACE] TO START OVER", 0, arena.height+10, arena.width, "center")
        love.graphics.printf("[ESC] TO QUIT", 0, arena.height+40, arena.width, "center")
    end,

    drawPlaying = function(self)
        hud:draw()

        -- Simple camera shake
        if self.shake ~= 0 then
            if the.view.focus then
                the.view.focusOffset = { x = math.random(-self.shake, self.shake), y = math.random(-self.shake, self.shake)}
            else
                the.view:panTo({ love.graphics.getWidth()/2 + math.random(-self.shake, self.shake), love.graphics.getHeight()/2 + math.random(-self.shake, self.shake)}, 0)
            end
        else
            the.view.focusOffset = { x = 0, y = 0 }
        end
        self.shake = 0
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