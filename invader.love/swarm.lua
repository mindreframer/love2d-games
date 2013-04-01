local __ = require 'underscore'
local meta = require 'luagravity.meta'

local C = require 'consts'

local Invader = require 'invader'

local function draw_list(invaders, x, y)
    return __(invaders):chain()
        :map(function(i)
            return i:_draw_list()
        end)
        :concat()
        :value()
end

local Swarm = function(...)
    local function constructor(ix, iy, bullet)
        _v = C.swarm.speed
        _x = ix + S(_v)
        _y = iy

        local invaders = __.range(1, C.swarm.number)
            :map(function(n)
                return Invader(n - 1, _x, _y, bullet)
            end)

        _bounced = __.reduce(invaders, false, function(c, i)
            return OR(c, i._bounced)
        end)

        local function bounce()
            _v = _v() * -1
            _y = _y() + C.invader.close
        end
	link(cond(_bounced), bounce)

        return {_draw_list=L(draw_list)(invaders, _x, _y)}
    end

    return meta.apply(constructor)(...)
end

return Swarm
