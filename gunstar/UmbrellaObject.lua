require 'PhysicalObject'

UmbrellaObject = PhysicalObject:subclass('UmbrellaObject')

local UmbrellaImage = love.graphics.newImage("umbrella.png")

function UmbrellaObject:initialize(x, y)
    PhysicalObject.initialize(self, x, y, "dynamic")

    self.umbrellaImage = UmbrellaImage
    self:setImage(self.umbrellaImage)

    self.setShapeFromSize = false
end

function UmbrellaObject:addedToScene(scene)
    PhysicalObject.addedToScene(self, scene)
    
    x0 = -self.width/2
    y0 = self.height/2
    
    self.stem = love.physics.newRectangleShape(0, -15, 4, self.height-30, 0)
    self:addShapeWithDensity(self.stem, 1)
    
    self.handle = love.physics.newRectangleShape(0, -110, 20, 20, 0)
    self:addShapeWithDensity(self.handle, 90)

    self.hood = love.physics.newPolygonShape( 
        x0 + 5,     y0 - 105,
        x0 + 75,    y0 - 45,
        x0 + 135,   y0 - 35,
        x0 + 195,   y0 - 45,
        x0 + 265,   y0 - 105)
    
    fixture = love.physics.newFixture(self.body, self.hood, 1)
    fixture:setRestitution(0.60)
    self:addShapeWithFixture(self.hood, fixture)
    
    self.body:resetMassData()
    self.body:setAngularDamping(5)    
end

function UmbrellaObject:removedFromScene(scene)
    PhysicalObject.removedFromScene(self, scene)
    scene.umbrellaJoint = nil
    scene.umbrellaObject = nil
end