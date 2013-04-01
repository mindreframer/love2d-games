require('actors/AI')

PlayerAI = class('PlayerAI', AI)
PlayerAI:includes(Beholder)

function PlayerAI:initialize()
  super.initialize(self)
  self._thrust = false
  self._strafeLeft = false
  self._strafeRight = false
  self._fire = false

  self:observe('keypressed_w', function(self) self._thrust = true end)
  self:observe('keypressed_a', function(self) self._strafeLeft = true end)
  self:observe('keypressed_d', function(self) self._strafeRight = true end)
  self:observe('mousepressed_l', function(self) self._fire = true end)
  self:observe('keyreleased_w', function(self) self._thrust = false end)
  self:observe('keyreleased_a', function(self) self._strafeLeft = false end)
  self:observe('keyreleased_d', function(self) self._strafeRight = false end)
  self:observe('mousereleased_l', function(self) self._fire = false end)
end

function PlayerAI:wantsThrust()
  return self._thrust
end

function PlayerAI:getStrafeDirection()
  if(self._strafeLeft) then return 'left' end
  if(self._strafeRight) then return 'right' end
  return nil
end

function PlayerAI:getRotationDirection()
  return self:orientateTowards(autoCamera:invert(love.mouse.getPosition()))
end

function PlayerAI:getWeaponsFired()
  if(self._fire) then return self:getAllWeapons() end
  return {}
end
