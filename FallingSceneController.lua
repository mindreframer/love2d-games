require 'PhysicalSceneController'
require 'UmbrellaObject'
require 'HeartObject'
require 'BlockDudeObject'

require 'DebugUtils'

FallingSceneController = PhysicalSceneController:subclass('FallingSceneController')

function FallingSceneController:initialize()
    PhysicalSceneController.initialize(self, 1000, 1000)
    self.screenWidth = 1024
    self.screenHeight = 768
    love.graphics.setMode(1024, 768)
    
    self.unnamedObjectIndex = 0

    self.mouseInteract = true
    self.showFPS = true
    self.allowDebugConsole = true
    
    self.umbrellaJoint = nil
    
    self.world:setGravity(0, -1000)
    self.cameraScale = 1
    
    -- create floor
    floor = PhysicalObject:new(self.screenWidth/2, 0, "static")
    floor:setSize(self.screenWidth, 10)
    floor:setPlaceholderRectangle(183, 214, 133, 255)
    self:addObjectWithKey(floor, "floor")
    
    -- create umbrella
    self:createUmbrella()
    
    
    -- start creating hearts
    self.heartMaxInterval = 100
    self.heartMultiplier = 1
    self:createHeartsForever()
    
    
    -- create block dude
    self.blockDude = BlockDudeObject:new(100,100)
    self:addObjectWithKey(self.blockDude, "blockDude")
end

function FallingSceneController:start()
    love.graphics.setBackgroundColor(16, 56, 96)
end

function FallingSceneController:createUmbrella()
    self.umbrellaObject = UmbrellaObject:new(400, 600)
    self:addObjectWithKey(self.umbrellaObject, "umbrella")
end

function FallingSceneController:createHeartsForever()
    for i=1, self.heartMultiplier do
        self:createHeart()
    end
    self:timerWithDurationAndCallback(math.random(self.heartMaxInterval)/1000.0, function()
        self:createHeartsForever()
    end)
end

function FallingSceneController:createHeart()
    local obj = HeartObject:new(math.random(10, self.screenWidth-10), self.screenHeight + 10)
    self:addObjectWithKey(obj, string.format("heart%d", self.unnamedObjectIndex))

    self.unnamedObjectIndex = self.unnamedObjectIndex + 1
end

--[[
function FallingSceneController:mousepressed(x, y, button)
    PhysicalSceneController.mousepressed(self, x, y, button)
    
    if button == 'l' and self.umbrellaJoint then
        self.umbrellaJoint:destroy()
        self.umbrellaJoint = nil 
    elseif button == 'l' and not self.umbrellaJoint then
        self:log("Grabbed umbrella")
        self.umbrellaJoint = love.physics.newMouseJoint(self.umbrellaObject.body, self:getWorldPositionAtPosition(love.mouse.getPosition()))
    end
end
]]

--[[
function FallingSceneController:mousereleased(x, y, button)
    PhysicalSceneController.mousereleased(self, x, y, button)
end
]]

function FallingSceneController:update(dt)
    PhysicalSceneController.update(self, dt)
    
    if not self.umbrellaObject then
        self:createUmbrella()
    end

    if self.umbrellaJoint then
        self.umbrellaJoint:setTarget(self:getWorldPositionAtPosition(love.mouse.getPosition()))
    end
end

--[[
function FallingSceneController:didSelectObjectWithMouse(object)
    -- do nothing
end
]]

function FallingSceneController:keypressed(key, unicode)
    PhysicalSceneController.keypressed(self, key, unicode)
    if not self.showDebugConsole then
        if key == '=' then
            self.cameraScale = self.cameraScale * 1.111
        elseif key == '-' then
            self.cameraScale = self.cameraScale * 0.9
        elseif key == 'left' then
            self.cameraX = self.cameraX - 10/self.cameraScale
        elseif key == 'right' then
            self.cameraX = self.cameraX + 10/self.cameraScale
        elseif key == 'up' then
            self.cameraY = self.cameraY + 10/self.cameraScale
        elseif key == 'down' then
            self.cameraY = self.cameraY - 10/self.cameraScale
        end
    end
    
    if key == 'z' then
        self.blockDude:goLeftStart()
    end
    if key == 'x' then
        self.blockDude:goRightStart()
    end
    if key == ' ' then 
        self.blockDude:jumpStart()
    end
end

function FallingSceneController:keyreleased(key, unicode)
     PhysicalSceneController.keyreleased(self, key, unicode)
     
    if key == 'z' then
        self.blockDude:goLeftStop()
    end
    if key == 'x' then
        self.blockDude:goRightStop()
    end 
    if key == ' ' then 
        self.blockDude:jumpStop()
    end
end
