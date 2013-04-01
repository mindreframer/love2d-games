Control = {}
Control.__index = Control

function Control.new()
    local inst = {}

    setmetatable(inst, Control)

    inst.controlling = nil
    inst.controllingIndex = 1
    inst.moving = false
    inst.mouseDown = {}
    inst.selectBox = { exists = false, originX = 0, originY = 0 , finalX = 0, finalY = 0}
    inst.selectedEntities = {}

    return inst
end

function Control:moveCheck(dt)
    local entity = self.controlling
    if entity ~= nil and entity.class == 0x01 then
        dy = 0
        dx = 0

        local w = love.keyboard.isDown("w")
        local a = love.keyboard.isDown("a")
        local s = love.keyboard.isDown("s")
        local d = love.keyboard.isDown("d")

        if w then
            dy = entity.moveSpeed * -dt
        end
        if s then
            dy = entity.moveSpeed * dt
        end
        if d then
            dx = entity.moveSpeed * dt
        end
        if a then
            dx = entity.moveSpeed * -dt
        end

        local hasCmds = # entity.cmds > 0

        if w or a or s or d then
            if hasCmds then
                entity:clearCmds()
                entity:stop()
            end
            self.moving = true
        else
            self.moving = false
        end

        if dy ~= 0 or dx ~= 0 then
            entityMoveTo(entity, dt, {entity.cx + dx, entity.cy + dy, 2})
        end

        if dy == 0 and dx == 0 and not hasCmds then
            entity.stepFrac = 0
            entity.step = 1
        end
    end

    local screenDy = 0
    local screenDx = 0

    local multiplier

    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        multiplier = 2
    else
        multiplier = 1
    end

    if(love.keyboard.isDown("w")) then
        screenDy = 384 * dt * multiplier
    end
    if(love.keyboard.isDown("d")) then
        screenDx = 384 * -dt * multiplier
    end
    if(love.keyboard.isDown("s")) then
         screenDy = 384 * -dt * multiplier
    end
    if(love.keyboard.isDown("a")) then
        screenDx = 384 * dt * multiplier
    end

    world.cameraX = world.cameraX + screenDx
    world.cameraY = world.cameraY + screenDy
    if world ~= nil and world.audioMgr ~= nil then
        world.audioMgr:setListenerPos(-world.cameraX, -world.cameraY)
    end
end

function Control:clear()
    for a, entity in pairs(self.selectedEntities) do
        entity.isSelected = nil
    end
    self.selectedEntities = {}
    if self.controlling ~= nil then
        self.controlling.isControlled = false
        self.controlling = nil
    end
end

function Control:update(dt)
    if self.mouseDown["l"] then
        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()
        local mapX = width - gui.map:getWidth() + 56
        local mapY = 36
        local mapWidth = world.width
        local mapHeight = world.height
        local x = love.mouse.getX()
        local y = love.mouse.getY()

        self.selectBox.finalX = x - world.cameraX - width / 2
        self.selectBox.finalY = y - world.cameraY - height / 2

        if x > mapX and x < mapX + mapWidth and y > mapY and y < mapY + mapHeight then
            world.cameraX = (x - mapX) * -32
            world.cameraY = (y - mapY) * -32
        end
    end

    self:moveCheck(dt)

    if self.controlling ~= nil then
        local target = self.controlling

        world.cameraX = -target.cx
        world.cameraY = -target.cy
    end
end

function Control:onMouseUp(x, y, button)
    self.mouseDown[button] = false
    
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local mapX = width - gui.map:getWidth() + 56
    local mapY = 36
    local mapWidth = world.width
    local mapHeight = world.height

    if x > mapX and x < mapX + mapWidth and y > mapY and y < mapY + mapHeight then
        return
    end

    x = x - world.cameraX - width / 2
    y = y - world.cameraY - height / 2
    
    if button == "l" then
        if self.selectBox.exists == true then
            self.selectedEntities = {}
            self.controlling = nil
            self.selectBox.finalX = x
            self.selectBox.finalY = y
            self.selectBox.exists = false
            local x1 = math.min(self.selectBox.originX, self.selectBox.finalX)
            local y1 = math.min(self.selectBox.originY, self.selectBox.finalY)
            local x2 = math.max(self.selectBox.originX, self.selectBox.finalX)
            local y2 = math.max(self.selectBox.originY, self.selectBox.finalY)
            for i, entity in pairs(world.entities) do
                if entity.canBeControlled and entity:clientBoxCheck(x1, y1, x2, y2) then
                    entity.isSelected = true
                    entity:clearCmds()
                    entity:stop()
                    table.insert(self.selectedEntities, entity)
                end
            end
            
            if #(self.selectedEntities) == 1 then
                local entity = self.selectedEntities[1]
                self.controlling = entity
                entity.isControlled = true
            end
        end
    end
end

function Control:onMouseDown(x, y, button)
    self.mouseDown[button] = true

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local mapX = width - gui.map:getWidth() + 56
    local mapY = 36
    local mapWidth = world.width
    local mapHeight = world.height

    if x > mapX and x < mapX + mapWidth and y > mapY and y < mapY + mapHeight then
        self:clear()
        return
    end

    x = x - world.cameraX - width / 2
    y = y - world.cameraY - height / 2

    if button == "l" then
        self:clear()
        self.selectBox.exists = true
        self.selectBox.originX = x
        self.selectBox.originY = y
    end

    -- attempted selection movement --
    if button == "r" then
        for i, ent in pairs(self.selectedEntities) do
            ent:clearCmds()
            ent:stop()
            local path = getPath(ent.cx + 16, ent.cy + 16, x, y, {[ent.collision] = 1})
            if path == nil then
            elseif path == 0 then
                ent:pushCmd(entityMoveTo, {x, y, 2})
            elseif # path > 0 then
                for a, node in pairs(path) do
                    ent:pushCmd(entityMoveTo, {world.nodes[node].x, world.nodes[node].y, 4})
                end
                ent:pushCmd(entityMoveTo, {x, y, 2})
            end
        end
    end
end

return Control
