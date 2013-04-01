World = require "world"
Control = require "control"
HC = require "collision"
ClassMgrMeta = require "classes"
GUI = require "gui"
require "navigation"
WaveMgr = require "waves"

tips = {
    "PROTIP: You're not a villain unless your minions die for you.",
    "PROTIP: Heroes are stronger than minions, so play strategically.",
    "PROTIP: Click and drag to select minions and then right click to direct them.",
    "PROTIP: Clicking on a minion allows you control them with the WASD keys.",
    "PROTIP: WASD will move the camera if you haven't selected anything.",
    "PROTIP: Skeletons are the strongest minion but are incredibly slow.",
    "PROTIP: Ghosts have a good balance of strength and speed.",
    "PROTIP: Bats are the fastest minion and also the weakest.",
    "PROTIP: Controlling minions directly buffs their strength and speed.",
    "PROTIP: The escape key will deselect and uncontrol all minions.",
    "PROTIP: The shift key makes the camera move faster."
}

function love.load()
    love.graphics.setBackgroundColor(89, 29, 71)

    artDir = "art"
    tileset = love.graphics.newImage(artDir .. "/images/tiles.png")
    font = love.graphics.newFont(artDir .. "/fonts/04b03.ttf", 17)
    bigFont = love.graphics.newFont(artDir .. "/fonts/04b03.ttf", 26)
    gui = GUI.new()
    collider = HC(100, onCollision, onCollisionStop)
    classMgr = ClassMgrMeta.new()
    world = World.new(math.ceil(math.random() * 123456789))
    control = Control.new()
end

function love.update(dt)
    gui:update(dt)
    world:update(dt)

    if gui.loaded then
        control:update(dt)
        collider:update(dt)
    end
end

function love.draw()
    if gui.over then
    elseif gui.loaded then
        if gui.ready then
            world:render()
            
            -- Print out selection box
            if control.selectBox.exists then
                love.graphics.setColor(255, 255, 255, 255)
                love.graphics.setLineWidth(2)
                local x0 = world.cameraX + love.graphics.getWidth() / 2
                local y0 = world.cameraY + love.graphics.getHeight() / 2
                local x1 = math.min(control.selectBox.originX, control.selectBox.finalX)
                local y1 = math.min(control.selectBox.originY, control.selectBox.finalY)
                local x2 = math.max(control.selectBox.originX, control.selectBox.finalX)
                local y2 = math.max(control.selectBox.originY, control.selectBox.finalY)
                love.graphics.rectangle("line", x1 + x0, y1 + y0, x2-x1, y2-y1)
            end

            love.graphics.setColor(255, 255, 255, 255)
        end
    else
        world:generate()
    end

    gui:render()
end

function love.keypressed(button)

    if button == " " then
        if control.controlling then
            control.controlling:attack()
        end
    end

    if button == "rctrl" then
        for i, entity in pairs(control.controlling) do
            entity:spawnEnemy()
        end
    end

    if gui.loaded and not gui.ready then
        gui.ready = true
    elseif gui.over then
        gui.ready = false
        gui.loaded = false
        gui.over = false
        world.waveMgr = nil

        world:clear()
        world:populate()
    end

    if button == "lctrl" then
        control.center = true
    end
end

function love.keyreleased(button)
    if button == "lctrl" then
        control.center = false
    elseif button == "escape" then
        control:clear()
    end
end

function love.mousepressed(x, y, button)
    if gui.loaded then
        control:onMouseDown(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if gui.loaded then
        control:onMouseUp(x, y, button)
    end
end