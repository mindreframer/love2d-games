local __ = require 'underscore'

local C = require 'consts'

local Bullet = require 'bullet'
local Player = require 'player'
local Swarm = require 'swarm'

return function()
    local bullet = Bullet(-1, -1, C.bullet.v)

    local swarm = Swarm(C.swarm.initial.x,
                        C.swarm.initial.y,
                        bullet)

    local player = Player(C.player.initial.x,
                          C.player.initial.y)
    link('key.left', player.left)
    link('key.right', player.right)

    local function shoot()
        bullet.shoot(player._x(),
                     player._y() - C.bullet.height / 2)
    end
    link('key. ', shoot)
    link('key.up', shoot)

    __.extend(Screen, {bullet, swarm, player})

    await('key.escape')
end
