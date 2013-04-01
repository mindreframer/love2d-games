require 'PhysicalObject'
require 'UmbrellaObject'

HeartObject = PhysicalObject:subclass('HeartObject')

local HeartImage = love.graphics.newImage("heart.png")

function HeartObject:initialize(x, y)
    PhysicalObject.initialize(self, x, y, "dynamic")

    self.heartImage = HeartImage
    self:setImage(self.heartImage)

    self.setShapeFromSize = false
        
    self.health = 100
end

function HeartObject:addedToScene(scene)
    PhysicalObject.addedToScene(self, scene)
    
    local x0 = -self.width/2
    local y0 = self.height/2
    
    local circle = love.physics.newCircleShape(0, 0, (4.0/10)*(self.height/2))
    self:addShapeWithDensity(circle, 200)
    self.tint = {255,64,64,255}
    
    self.body:resetMassData()
    self.body:setAngularDamping(5)

end

function HeartObject:beginContact(object, contact, coef)
    if object.name == 'floor' then
        self:collidedWithFloor()
    elseif instanceOf(UmbrellaObject, object) then
        self:collidedWithUmbrella()
    end
end

function HeartObject:collidedWithUmbrella()
    if self.health <= 0 then
        self:deferredRemoval()
        return
    end
    
    self.health = self.health - 20
    local coef = (100.0 - self.health)/100.0
    self.tint = {255, 64 + coef*192, 64 + coef*192, 255}
    
    if self.health <= 0 then
        self:deferredRemoval()
    end    
end

function HeartObject:collidedWithFloor()
    --self:deferredRemoval()
end