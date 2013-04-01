require('actors/Module.lua')

local image = passion.graphics.getImage('images/image.png')

Thruster = class('Thruster', Module)

Thruster:getterSetter('thrust', 0)
Thruster:getterSetter('strafeThrust', 0)

function Thruster:initialize(thrust, strafeThrust, quad)
  super.initialize(self, 8,8, quad)
  self:setThrust(thrust)
  self:setStrafeThrust(strafeThrust)
end

Thruster1 = class('Thruster1', Thruster)
function Thruster1:initialize()
  super.initialize(self, 0.01, 0.003, passion.graphics.newQuad(image,  0,64, 16,16 ))
end

Thruster2 = class('Thruster2', Thruster)
function Thruster2:initialize()
  super.initialize(self, 0.02, 0.006, passion.graphics.newQuad(image, 17,64, 16,16 ))
end

Thruster3 = class('Thruster3', Thruster)
function Thruster3:initialize()
  super.initialize(self, 0.03, 0.009, passion.graphics.newQuad(image, 33,64, 16,16 ))
end
