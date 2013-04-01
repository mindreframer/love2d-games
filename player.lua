local meta = require 'luagravity.meta'

local C = require 'consts'

local function draw_list(x, y)
    return {{
        'triangle', 'line',
        x, y,
        x + C.player.width, y + C.player.height,
        x - C.player.width, y + C.player.height,
    }}
end

local function v(dir, x)
    if x then
        if (x <= C.player.width and dir < 0) or
            (x >= C.screen.width - C.player.width and dir > 0) then
            return 0
        else
            return C.player.speed * dir
        end
    else
        return 0
    end
end

local Player = function(...)
    local function constructor(ix, iy)
        _dir = 0
        _x = ix
        _y = iy

        _v = L(v)(_dir, delay(_x))
        _x = ix + S(_v)

        local function move(d)
            return function()
                _dir = d
            end
        end

        return {
            _draw_list = L(draw_list)(_x, _y),
            _x = _x,
            _y = _y,
            left = move(-1),
            right = move(1),
        }
    end

    return meta.apply(constructor)(...)
end

return Player
