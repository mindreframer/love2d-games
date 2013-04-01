require 'SceneController'
require 'PhysicalObject'

PhysicalSceneController = SceneController:subclass('PhysicalSceneController')

function PSCLog(...)
    local controller = sceneControllers[sceneControllersCount]
    if instanceOf(PhysicalSceneController, controller) then
        controller:log(unpack(arg))
    end
end

function PhysicalSceneController:start()
end

function PhysicalSceneController:log(...)
    local s = string.format(unpack(arg))
    table.insert(self.debugTextLines, s)
    self.debugConsoleLines = self.debugConsoleLines + 1
    
    if self.debugConsoleLines > self.debugConsoleLinesMax then
        table.remove(self.debugTextLines, 1)
        self.debugConsoleLines = self.debugConsoleLines - 1
    end
end

function PhysicalSceneController:update(dt)    
    SceneController.update(self, dt)
    
    if self.mouseJoint then
        self.mouseJoint:setTarget(self:getWorldPositionAtPosition(love.mouse.getPosition()))
    end
    
    for key, object in pairs(self.objects) do
        object:update(dt)
        local x = object.body:getX()
        local y = object.body:getY()
        if x < -self.sceneBorder or y < -self.sceneBorder or x > (self.sceneWidth + self.sceneBorder) or y > (self.sceneHeight + self.sceneBorder) then
            object:didLeaveWorldBoundaries(self)
        end
        if object.shouldBeRemoved then
            self:removeObject(key)
        end
    end
    
    self.world:update(dt)
end

function PhysicalSceneController:getWorldPositionAtPosition(screenX, screenY)
    local worldX = (screenX - (self.screenWidth/2))/self.cameraScale + self.cameraX
    local worldY = -(screenY - (self.screenHeight/2))/self.cameraScale + self.cameraY
    return worldX, worldY
end

function PhysicalSceneController:worldStats()
    local w = self.world
    self:log("World stats: %d objects, %d bodies, %d contacts, %d joints, memory used: %d KB", self.objectCount, w:getBodyCount(), w:getContactCount(), w:getJointCount(), collectgarbage("count"))
end

function PhysicalSceneController:draw()
    love.graphics.push()
    love.graphics.translate(self.screenWidth/2, self.screenHeight/2)
    love.graphics.scale(self.cameraScale, -self.cameraScale)
    love.graphics.translate(-self.cameraX, -self.cameraY)
    
    for k,v in pairs(self.objects) do
        v:draw()
    end
    love.graphics.pop()
    
    if self.showFPS then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(string.format("%2d fps", love.timer.getFPS()), self.screenWidth-64, 12)
    end
    
    if self.showDebugConsole then
        local debugText = ""
        for i, line in ipairs(self.debugTextLines) do
            debugText = string.format("%s%s\n", debugText, line) 
        end
        
        debugText = debugText .. self.debugConsolePrompt .. self.debugConsoleScriptBuffer
        
        love.graphics.setColor(128, 128, 128, 128)
        love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.debugConsoleLinesMax * 15)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(debugText, 12, 5)
    end
end

function PhysicalSceneController:addObjectWithKey(object, key)
    assert(object) 
    assert(key)
    object:addedToScene(self)
    object.name = key
    self.objects[key] = object
    self.objectCount = self.objectCount +1
end

function PhysicalSceneController:getObject(key)
    return self.objects[key]
end

function PhysicalSceneController:removeObject(key)
    object = self.objects[key]
    if instanceOf(PhysicalObject, object) then
        object:removedFromScene(self)
        self.objectCount = self.objectCount -1
    end
        
    self.objects[key] = nil
end

function PhysicalSceneController:removeLastMouseObject()
    if self.lastMouseObject then
        self:removeObject(self.lastMouseObject.name)
    end
end

function PhysicalSceneController:mousepressed(x, y, button)
    if button == 'l' then
        wx, wy = self:getWorldPositionAtPosition(x, y)
        self:log("Clicked screen pos: (%d, %d), world pos: (%d, %d)", x, y, wx, wy)
    end
    if self.mouseInteract and button == 'l' then
        --find object at mouse position
        x, y = self:getWorldPositionAtPosition(x, y)
        self.lastMouseX = x
        self.lastMouseY = y
        self.mouseBody = love.physics.newBody(self.world, x, y, 0, 0)
        self.mouseShape = love.physics.newCircleShape(0, 0, 1)
        self.mouseFixture = love.physics.newFixture(self.mouseBody, self.mouseShape)

        local collisionData = setmetatable({}, {__mode="kv"})
        collisionData['object'] = nil
        collisionData['shape'] = self.mouseShape
        collisionData['fixture'] = fixture
        self.mouseFixture:setUserData(collisionData)
        
        self.mouseFixture:setSensor(true)
    end
end

function PhysicalSceneController:mousereleased(x, y, button)
    if self.mouseInteract and button == 'l' then
        if self.mouseJoint then
            self.mouseJoint:destroy()
            self.mouseJoint = nil
        end
        
        if instanceOf(PhysicalObject, self.mouseObject) then
            self.mouseObject:didDeselectWithMouse()
        end
        
        self.mouseFixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
        self.mouseShape = nil
        self.mouseBody = nil        
        self.mouseObject = nil
        self.mouseFixture = nil
    end
end

function PhysicalSceneController:runDebugScript(scriptText)
    self:log(self.debugConsolePrompt .. scriptText)
        
    local func, err
    func, err = loadstring(string.format("return function (self) %s end", scriptText))
    if not func then
        func, err = loadstring(string.format("return function (self) return %s end", scriptText))
        if not func then
            self:log("Error loading: %s", tostring(err))
            return
        end
    end
    
    local output = nil
    pcall(function () output = func()(self) end)
    if output then
        self:log(tostring(output))
    end
end

function PhysicalSceneController:keypressed(key, unicode)
    if key == "`" and self.allowDebugConsole then
        self.debugConsoleScriptBuffer = ""
        self.showDebugConsole = not self.showDebugConsole
        return
    end
    
    if self.showDebugConsole then
        if key == 'return' then
            self:runDebugScript(self.debugConsoleScriptBuffer)
            self.debugConsoleScriptBuffer = ""
        elseif key == "backspace" then
            self.debugConsoleScriptBuffer = self.debugConsoleScriptBuffer:sub(1, self.debugConsoleScriptBuffer:len()-1)
        elseif unicode > 31 and unicode < 127 then
            self.debugConsoleScriptBuffer = self.debugConsoleScriptBuffer .. string.char(unicode)
        end
    end
end

function PhysicalSceneController:keyreleased(key, unicode)
end

function PhysicalSceneController:setCamera(x, y, scale)
    self.cameraX = x
    self.cameraY = y
    self.cameraScale = scale
end

function PhysicalSceneController:grabObjectWithMouse(object)
    self:log("Grabbed Obj: %s", object.name)
    self:timerWithDurationAndCallback(0, function () 
        self.mouseJoint = love.physics.newMouseJoint(object.body, self:getWorldPositionAtPosition(love.mouse.getPosition()))
    end)
end

function PhysicalSceneController:didSelectObjectWithMouse(object)
    object:didSelectWithMouse()
    self:grabObjectWithMouse(object)
end
    

function PhysicalSceneController:beginContact()
    return function (a, b, coll)
        local aData = a:getUserData()
        local bData = b:getUserData()
        
        if aData and bData then
            local aObject = aData['object']
            local bObject = bData['object']
            local aShape = aData['shape']
            local bShape = bData['shape']
            
            -- special handling for mouse selection
            if not self.mouseObject then
                if aShape == self.mouseShape then
                    self.mouseObject = bObject
                    self.lastMouseObject = bObject
                    self:didSelectObjectWithMouse(bObject)
                elseif bShape == self.mouseShape then
                    self.mouseObject = aObject
                    self.lastMouseObject = aObject
                    self:didSelectObjectWithMouse(aObject)
                end
            end
            
            if aObject and bObject then
                aObject:beginContact(bObject, coll, -1)
                bObject:beginContact(aObject, coll, 1)
            end
        end
    end
end

function PhysicalSceneController:endContact()
    return function (a, b, coll)
        local aData = a:getUserData()
        local bData = b:getUserData()
        
        if aData and bData then
            local aObject = aData['object']
            local bObject = bData['object']
            
            if aObject and bObject then
                aObject:endContact(bObject, coll, -1)
                bObject:endContact(aObject, coll, 1)
            end
        end
    end
end

function PhysicalSceneController:preContactSolve()
    return function (a, b, coll)
        local aData = a:getUserData()
        local bData = b:getUserData()
        
        if aData and bData then
            local aObject = aData['object']
            local bObject = bData['object']
            
            if aObject and bObject then
                aObject:preContactSolve(bObject, coll, -1)
                bObject:preContactSolve(aObject, coll, 1)
            end
        end
    end
end

function PhysicalSceneController:postContactSolve()
    return function (a, b, coll)
        local aData = a:getUserData()
        local bData = b:getUserData()
        
        if aData and bData then
            local aObject = aData['object']
            local bObject = bData['object']
        
            if aObject and bObject then
                aObject:postContactSolve(bObject, coll, -1)
                bObject:postContactSolve(aObject, coll, 1)
            end
        end
    end
end

function PhysicalSceneController:stop()
end

function PhysicalSceneController:lastMousePos()
    return self.lastMouseX, self.lastMouseY
end

function PhysicalSceneController:typeCounts()
    local pair
    local sortedPairs = {}
    for k, v in pairs(DUTypeCount()) do
        pair = {}
        pair.key = k
        pair.value = v
        table.insert(sortedPairs, pair)
    end
    
    table.sort(sortedPairs, function (a, b) return a.value < b.value end)
    
    for i, v in ipairs(sortedPairs) do
        self:log("%s: %s", tostring(v.key), tostring(v.value))
    end
end

function PhysicalSceneController:initialize(sceneWidth, sceneHeight, sceneBorder)
    SceneController.initialize(self)
    self.sceneHeight = sceneHeight or 600
    self.sceneWidth = sceneWidth or 800
    self.sceneBorder = sceneBorder or 100
    self.world = love.physics.newWorld(-self.sceneBorder, -self.sceneBorder, self.sceneWidth+self.sceneBorder, self.sceneHeight+self.sceneBorder)
    self.objects = {}
    self.objectCount = 0
    self.cameraX = self.sceneWidth/2
    self.cameraY = self.sceneHeight/2
    self.cameraScale = 1
    self.cameraRotation = 0
    self.mouseInteract = false
    self.mouseBody = nil
    self.lastMouseX = 0
    self.lastMouseY = 0
    self.lastMouseObject = nil
    self.mouseObject = nil
    self.mouseJoint = nil
    self.mouseFixture = nil
    self.debugTextLines = {}
    self.showFPS = false
    self.showDebugConsole = false
    self.allowDebugConsole = false
    self.debugConsoleLines = 0
    self.debugConsoleLinesMax = 30
    self.debugConsolePrompt = "> "
    self.debugConsoleScriptBuffer = ""
    self.world:setCallbacks(self:beginContact(), self:endContact(), self:preContactSolve(), self:postContactSolve())
end


function SceneController:popped()
    self.world:destroy()
end