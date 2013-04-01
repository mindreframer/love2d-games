local meta = require 'luagravity.meta'

local C = require 'consts'

local function draw_list(x, y)
    return {
        {'setLineWidth', C.bullet.width},
        {'line', x, y, x, y + C.bullet.height},
        {'setLineWidth', 1},
    }
end

local function box(x, y)
    return {x=x, y=y, width=C.bullet.width, height=C.bullet.height}
end

local Bullet = function(...)
    local function constructor(ix, iy, v)
        _x = ix
        _y = iy + S(v)

        local function shoot(x, y)
            _x = x
            _y = y + S(v)
        end

        return {
            _box = L(box)(_x, _y),
            _draw_list = L(draw_list)(_x, _y),
            shoot = shoot,
        }
    end

    return meta.apply(constructor)(...)
end

return Bullet
