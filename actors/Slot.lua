Slot = class('Slot')

function Slot:initialize(vehicle, name, specs)
  self.vehicle = vehicle
  self.name = name
  self.x = specs.x or 0
  self.y = specs.y or 0
  self.angle = specs.angle or 0
end

function Slot:attach(module)

  if(self.module~=nil) then
    self.module:destroy()
  end

  self.module = module

  --This doesn't work ok if I move the vehicle abruptly (setPosition). So, simulating it with Lua
  --local x,y = self.vehicle:getWorldPoint(self.x, self.y)
  --module:setPosition(x,y)
  --self.joint = love.physics.newRevoluteJoint(self.vehicle:getBody(), module:getBody(), x, y)

  module:attach(self)
end



