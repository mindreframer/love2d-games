require('actors/Module.lua')

local image = passion.graphics.getImage('images/image.png')

Gyroscope = class('Gyroscope', Module)

Gyroscope:getterSetter('rotation')

function Gyroscope:initialize(quad, rotation)
  super.initialize(self, 8,8, quad)
  self:setRotation(rotation)
end

Gyroscope1 = class('Gyroscope1', Gyroscope)
function Gyroscope1:initialize()
  super.initialize(self, passion.graphics.newQuad( image, 48,32, 16,16 ), 0.6)
end

Gyroscope2 = class('Gyroscope2', Gyroscope)
function Gyroscope2:initialize()
  super.initialize(self, passion.graphics.newQuad( image, 64,32, 16,16 ), 1.2)
end

Gyroscope3 = class('Gyroscope3', Gyroscope)
function Gyroscope3:initialize()
  super.initialize(self, passion.graphics.newQuad( image, 80,32, 16,16 ), 1.8)
end
