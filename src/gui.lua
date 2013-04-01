GUI = {}
GUI.__index = GUI

function GUI.new()
    local inst = {}

    setmetatable(inst, GUI)

    inst.state = "Loading..."
    inst.loaded = false
    inst.ready = false
    inst.skull = love.graphics.newImage(artDir .. "/images/skull.png")
    inst.status = love.graphics.newImage(artDir .. "/images/status.png")
    inst.map = love.graphics.newImage(artDir .. "/images/map.png")
    inst.progress = love.graphics.newImage(artDir .. "/images/progress.png")
    inst.progressSep = love.graphics.newImage(artDir .. "/images/progress_sep.png")
    inst.logo = love.graphics.newImage(artDir .. "/images/centhra.png")
    inst.mapCanvas = nil
    inst.tip = nil
    inst.waveNotification = nil

    return inst
end

function GUI:renderMap()
    self.mapCanvas = love.graphics.newCanvas(world.width, world.height)
    self.mapCanvas:renderTo(function()
        love.graphics.setColor(0, 0, 0)

        for x = 0, world.width do
            for y = 0, world.height do
                if world:getTile(x, y) then
                    love.graphics.point(x, y)
                end
            end
        end
    end)
end

function GUI:notifyWave(x, y)
    self.waveNotification = {x = x, y = y, step = 0}
end

function GUI:renderLoading()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    if self.tip == nil then
        self.tip = tips[math.ceil(math.random() * #tips)]
    end
    local tip = self.tip
    local tipWidth = font:getWidth(tip)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.logo, 10, 10)
    love.graphics.draw(self.skull, width / 2 - self.skull:getWidth() / 2, height / 2 - self.skull:getHeight() / 2)
    love.graphics.print(tip, width / 2 - tipWidth / 2, height / 2 + self.skull:getHeight() * 7 / 6)

    if not self.loaded then
        love.graphics.print(self.state, 16, height - 32)
    else
        love.graphics.setColor(225, 225, 225)
        love.graphics.print("Press any key to continue", 16, height - 32)
    end
end

function GUI:renderHUD()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local target = control.controlling
    local notification = self.waveNotification

    if target then
        local class = target.entityClass
        local y = height - self.status:getHeight()

        love.graphics.draw(self.status, 0, y)
        love.graphics.setColor(255, 26, 26)
        love.graphics.rectangle("fill", 78, y + 48, math.ceil(184 * target.health / target.entityClass.health), 12)
        love.graphics.setColor(255, 255, 255) -- TODO: unhardcode for each portrait instead of just spiders
        love.graphics.draw(class.portrait, 7, y)
        love.graphics.setColor(89, 29, 71)
        love.graphics.print(class.name, 79, y + 28)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(class.name, 77, y + 27)
    end

    local x = width - self.map:getWidth()

    love.graphics.draw(self.map, x, 0)
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(self.mapCanvas, x + 56, 36)
    love.graphics.setColor(255, 0, 0)

    for i, entity in pairs(world.enemies) do
        love.graphics.point(math.floor(x + entity.cx / 32 + 56), math.floor(entity.cy / 32 + 36))
    end
    love.graphics.setColor(0, 255, 0)
    for i, entity in pairs(world.friendlies) do
        love.graphics.point(math.floor(x + entity.cx / 32 + 56), math.floor(entity.cy / 32 + 36))
    end

    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", math.floor(x + 56 + (-world.cameraX - width / 2) / 32), math.floor((-world.cameraY - height / 2) / 32 + 36), math.floor(width / 32), math.floor(height / 32))

    if notification then
        love.graphics.setColor(225, 0, 0)
        love.graphics.print("!", x + 56 + notification.x - 1, 32 + notification.y - 1)
    end

    if world.waveMgr then
        local enemies = world.waveMgr.total - world.waveMgr.dispatched + #world.enemies
        local total = enemies + #world.friendlies
        local heroWidth = math.ceil((enemies / total) * 184)
        local minionWidth = math.ceil((#world.friendlies / total) * 184)

        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.progress, 10, 5)
        love.graphics.setColor(255, 26, 26)
        love.graphics.rectangle("fill", 42, 21, minionWidth, 12)
        love.graphics.setColor(31, 133, 255)
        love.graphics.rectangle("fill", 42 + minionWidth, 21, heroWidth, 12)
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.progressSep, 42 + minionWidth - 5, 11)
    end
end

function GUI:renderOver()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local title
    local msg

    if not gui.won then
        title = "YOU LOST!"
        msg = "So long and thanks for all the decorative monster heads!"
    else
        title = "YOU WON!"
        msg = "There's no better way to thank a minion than pain and suffering!"
    end

    local titleWidth = bigFont:getWidth(title)
    local msgWidth = font:getWidth(msg)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.skull, width / 2 - self.skull:getWidth() / 2, height / 2 - self.skull:getHeight() / 2)
    love.graphics.setFont(bigFont)
    love.graphics.print(title, width / 2 - titleWidth / 2, height / 2 - self.skull:getHeight() * 7 / 6)
    love.graphics.setFont(font)
    love.graphics.print(msg, width / 2 - msgWidth / 2, height / 2 + self.skull:getHeight() * 7 / 6)
    love.graphics.print("Press any key to start a new game", 16, height - 32)
end

function GUI:render()
    love.graphics.push()
    love.graphics.setFont(font)

    if not self.loaded or not self.ready then
        self:renderLoading()
    elseif self.over then
        self:renderOver()
    else
        self:renderHUD()
    end

    love.graphics.pop()
end

function GUI:update(dt)
    if self.ready then
        local notification = self.waveNotification

        if notification then
            notification.step = notification.step + dt

            if notification.step >= 3 then
                self.waveNotification = nil
            end
        end
    end
end

return GUI
