require('actors/Module.lua')
require('actors/Slot.lua')
require('actors/Vehicle.lua')
require('mixins/PacManLike.lua')

local _getTotalAttribute = function(self, baseValue, moduleMethod)
  local result = baseValue
  for _,slot in pairs(self.slots) do
    module = slot.module
    if(module~=nil and type(module[moduleMethod]) == "function") then
      result = result + module[moduleMethod](module)
    end
  end
  return result
end

local _getSinCosAngle = function(self)
  local angle = self:getAngle()
  return math.sin(angle), math.cos(angle)
end

Ship = class('Ship', Vehicle)
Ship:includes(PacManLike)

function Ship:initialize(ai,x,y, cx,cy, shapes, slots, quad, quadTree, options)
  super.initialize(self,ai, x,y, cx,cy, shapes, slots, quad, quadTree)
  self:setAngle(math.pi/2.0)

  options = options or {}

  -- The ship impulse, without thrusters
  self.baseThrust = options.baseThrust or 0.05

  -- The ship lateral impulse, without lateral thrusters
  self.baseStrafeThrust = options.baseStrafeThrust or 0.02

  -- The ship rotation torque, without rotational thrusters / gyroscopes
  self.baseRotation = options.baseRotation or 0.1

  -- The max angular speed that the ship can get, even with rotational thrusters / gyroscopes
  self.maxAngularVelocity = options.maxAngularVelocity or 0.6

end

function Ship:getThrust()
  return _getTotalAttribute(self, self.baseThrust, 'getThrust')
end

function Ship:getStrafeThrust()
  return _getTotalAttribute(self, self.baseStrafeThrust, 'getThrust')
end

function Ship:getRotation()
  return _getTotalAttribute(self, self.baseRotation, 'getRotation')
end

function Ship:getObjective()
  return 0,0
end

function Ship:thrust()
  local s,c = _getSinCosAngle(self)
  local thrust = self:getThrust()
  self:applyImpulse( c*thrust, s*thrust )
end

function Ship:strafe(strafeDir)
  local s,c = _getSinCosAngle(self)
  local strafeThrust = self:getStrafeThrust()
  if(strafeDir=='left') then
    self:applyImpulse( s*strafeThrust, -c*strafeThrust )
  elseif(strafeDir=='right') then
    self:applyImpulse( -s*strafeThrust, c*strafeThrust )
  end
end

function Ship:rotate(rotationDir)
  local rotation = self:getRotation()
  if(rotationDir == 'clockwise') then
    self:applyTorque(rotation)
  elseif(rotationDir == 'counterclockwise') then
    self:applyTorque(-rotation)
  end
end

function Ship:fire(slotNames)
  local module

  for _,slotName in pairs(slotNames) do
    slot = self.slots[slotName]
    if(slot~=nil) then
      module = slot.module
      if(module~=nil and type(module.fire)=='function') then
        module:fire()
      end
    end
  end
end

function Ship:draw()
  love.graphics.setColor(unpack(passion.colors.white))
  super.draw(self)
end

function Ship:update(dt)

  if(self.ai~=nil) then
    if(self.ai:wantsThrust()) then self:thrust() end

    local strafeDir = self.ai:getStrafeDirection()
    if(strafeDir~=nil) then self:strafe(strafeDir) end

    local rotationDir = self.ai:getRotationDirection()
    if(rotationDir~=nil) then self:rotate(rotationDir) end

    local weaponsFired = self.ai:getWeaponsFired()
    if(weaponsFired~=nil) then self:fire(weaponsFired) end
  end

  self:pacManCheck()
end
