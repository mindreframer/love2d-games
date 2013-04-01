local C = {}

C.screen = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
}

C.bullet = {
    height = 25,
    width = 3,
    v = -200,
}

C.invader = {
    side = 25,
    spacing = {
        x = 2,
        y = 1.5,
    },
}
C.invader.close = C.invader.side / 4

C.swarm = {
    columns = 7,
    rows = 11,
    speed = 100,
}
C.swarm.initial = {
    x = (C.screen.width / 2) - ((C.invader.side * C.invader.spacing.x) * C.swarm.columns) / 2,
    y = C.invader.side,
}
C.swarm.number = C.swarm.rows * C.swarm.columns

C.player = {
    width = 25 * 1.5,
    height = 25,
    speed = 150,
}
C.player.initial = {
    x = C.screen.width / 2,
    y = C.screen.height - C.player.height - 1,
}

return C
