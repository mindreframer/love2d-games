require('actors/Module.lua')

Weapon = class('Weapon', Module)

function Weapon:initialize(centerX, centerY, coolDown, projectileClass, quad, source)
  super.initialize(self, centerX, centerY, quad)
  self.coolDown = coolDown
  self.projectileClass = projectileClass
  self.source = source
end

function Weapon:fire()
  local velX, velY = self:getLinearVelocity()
  local x,y=self:getPosition()
  local angle = self:getAngle()

  self.projectileClass:new(x,y,velX,velY,angle,self:getGroupIndex(),self.quadTree)
  passion.audio.play(self.source)

  self:pushState('CoolingDown')
end

-- The weapon enters this state after firing
CoolingDown = Weapon:addState('CoolingDown')

function CoolingDown:enterState()
  self:after(self.coolDown, 'popState')
end

function CoolingDown:fire() end -- do nothing
