require 'PhysicalObject'
require 'UmbrellaObject'

BlockDudeObject = PhysicalObject:subclass('BlockDudeObject')

function BlockDudeObject:initialize(x, y)
    PhysicalObject.initialize(self, x, y, "dynamic")
    --self.setShapeFromSize = true
    self:setSize(50,50)
    self:setPlaceholderRectangle(255, 255, 255, 255)
    self.startingX = x
    self.startingY = y
    self.leftForce = 0
    self.rightForce = 0
    self.speed = 5000
    self.isJumping = false
    self.jumpStartTime = 0
    self.jumpResetTime = 0
    self.jumpStartDuration = 0.10
    self.jumpMaxDuration = 0.125
    self.jumpSpeed = 20000
    self.touchingJumpSurface = false
end

function BlockDudeObject:addedToScene(scene)
    PhysicalObject.addedToScene(self, scene)
    
    local x0 = -self.width/2
    local y0 = self.height/2
end

function BlockDudeObject:didLeaveWorldBoundaries(scene)
    self.body:setX(self.startingX)
    self.body:setY(self.startingY)
end

function BlockDudeObject:update(dt)
    PhysicalObject.update(self, dt)
    
    if self.rightForce or self.leftForce then
        local jumpCoef = 1
        if not self.touchingJumpSurface then
            jumpCoef = 0.25
        end 
        self.body:applyForce((self.rightForce - self.leftForce)*self.speed*jumpCoef, 0)
    end
    if self.isJumping and (love.timer.getTime() - self.jumpStartTime) < self.jumpMaxDuration then
        self.body:applyForce(0, self.jumpSpeed)
    end
end

function BlockDudeObject:goLeftStart()
    self.leftForce = 1
end


function BlockDudeObject:goLeftStop()
    self.leftForce = 0
end

function BlockDudeObject:goRightStart()
    self.rightForce = 1
end


function BlockDudeObject:goRightStop()
    self.rightForce = 0
end

function BlockDudeObject:jumpStart()
    if self.touchingJumpSurface or (love.timer.getTime() - self.jumpResetTime) < self.jumpStartDuration then
        self.isJumping = true
        self.touchingJumpSurface = false
        self.jumpStartTime = love.timer.getTime()
    end
end

function BlockDudeObject:jumpStop()
    self.isJumping = false
end

function BlockDudeObject:beginContact(object, contact, coef)
    if object.name == "floor" or instanceOf(UmbrellaObject, object) then
        
        local cx
        local cy 
        cx, cy = contact:getNormal()
        cy = cy * coef
        if cx < 0 then
            cx = cx * -1
        end
                
        if cy > cx then
            self:startedTouchingJumpSurface()
        end
    end
end

function BlockDudeObject:endContact(object, contact, coef)
    if object.name == "floor" or instanceOf(UmbrellaObject, object) then
        self:stoppedTouchingJumpSurface()
    end
end

function BlockDudeObject:startedTouchingJumpSurface()
    self.touchingJumpSurface = true
end


function BlockDudeObject:stoppedTouchingJumpSurface()
    self.touchingJumpSurface = false
    self.jumpResetTime = love.timer.getTime()
end