local __ = require 'underscore'
local math = math
local meta = require 'luagravity.meta'

local C = require 'consts'

local function draw_list(alive, x, y)
    if alive then
        return {{
            'rectangle', 'line',
            x, y,
            C.invader.side, C.invader.side,
        }}
    else
        return {}
    end
end

local function bounced(alive, x)
    if alive then
        return x <= 0 or (x + C.invader.side) >= C.screen.width
    else
        return false
    end
end

local function box(x, y)
    return {x=x, y=y, width=C.invader.side, height=C.invader.side}
end

local function colliding(abox, bbox)
    local ax2, ay2 = abox.x + abox.width, abox.y + abox.height
    local bx2, by2 = bbox.x + bbox.width, bbox.y + bbox.height
    return abox.x < bx2 and ax2 > bbox.x and abox.y < by2 and ay2 > bbox.y
end

local Invader = function(...)
    local function constructor(n, sx, sy, bullet)
        local col = n % C.swarm.columns
        local row = math.floor(n / C.swarm.columns)

        _x = (col * (C.invader.side * C.invader.spacing.x)) + sx
        _y = (row * (C.invader.side * C.invader.spacing.y)) + sy

        _box = L(box)(_x, _y)
        _hit = L(colliding)(_box, bullet._box)
        _alive = true

        local function die()
            _alive = false
        end
        link(cond(_hit), die)

        return {
            _draw_list=L(draw_list)(_alive, _x, _y),
            _bounced=L(bounced)(_alive, _x),
        }
    end

    return meta.apply(constructor)(...)
end

return Invader
