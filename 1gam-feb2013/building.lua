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

building_img = {
    'img/apartment01.png',
    'img/apartment02.png',
    'img/apartment03.png',
    'img/apartment04.png',
    'img/club01.png',
    'img/park01.png',
    'img/policestation01.png',
    'img/restaurant01.png',
}

road_img = {
    'img/verticalroad01.png',
    'img/verticalroad01b.png',
    'img/verticalroad01c.png',
    'img/verticalroad01d.png'
}

building = Animation:extend{
    id = 'building',
    
    hp = 3,

    width = 100,
    height = 175,
    solid = true,

    onNew = function(self)
        self.image = building_img[math.random(#building_img)]
        self.y = love.graphics.getHeight() - self.height
    end,

    onUpdate = function(self, dt)
    end,

    onDraw = function(self)
        love.graphics.setColor(255,255,255,255)
    end,

    onCollide = function(self, other, x_overlap, y_overlap)
        if other.id == 'asteroid' then
            the.app.score.missed = the.app.score.missed + 1
        end

        if other.id == 'asteroid' and self.hp > 0 then
            if other.original_size == asteroid.EXTINCTION_ROCK then
                the.app:changeState(the.app.STATE_GAMEOVER)
                return
            end

            damage = math.min(self.hp, other.size / other.MIN_SIZE)

            self.hp = self.hp - damage

            if self.hp <= 0 then
                self.tint = { 0.5, 0.5, 0.5 }
            end

            for i = 1, damage do
                local offset = math.random() * 40 - 20
                if i == 1 then
                    offset = 0
                end
                local e = smokeEmitter:new()
                e.period = 1/the.app.beat.beats_per_second/4
                e.x = other.x + offset
                e.y = other.y + math.random() * 50
                e:loadParticles(smoke, 20)
                the.app:add(e)
            end
        end
    end,
}