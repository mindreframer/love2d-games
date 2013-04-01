AI = class('AI', passion.Actor)

local twoPi = 2.0*math.pi

function _sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

local _normalizeAngle = function(angle)
  angle = angle % twoPi
  return (angle < 0 and (angle + twoPi) or angle)
end

function AI:initialize()
  super.initialize(self)
end

function AI:setVehicle(vehicle)
  self.vehicle = vehicle
end

function AI:getVehicle(vehicle)
  return self.vehicle
end

function AI:orientateTowards(tx,ty)

  local vehicle = self:getVehicle()
  local x, y = vehicle:getPosition()
  local angle = vehicle:getAngle()
  local maxTorque = vehicle:getRotation()
  local inertia = vehicle:getInertia()
  local w = vehicle:getAngularVelocity()

  local targetAngle = math.atan2(ty-y,tx-x)
  -- Distance I have to cover
  local differenceAngle = _normalizeAngle(targetAngle - angle)
  -- Distance it will take me to stop
  local brakingAngle = _normalizeAngle(_sign(w)*2.0*w*w*inertia/maxTorque)

  -- two of these 3 conditions must be true
  local a,b,c = differenceAngle > math.pi, brakingAngle > differenceAngle, w > 0
  if( (a and b) or (a and c) or (b and c) ) then
    return 'counterclockwise'
  end

  return 'clockwise'
end

function AI:getAllWeapons()
  local slotNames = {}
  local vehicle = self:getVehicle()
  if(vehicle.slots) then
    for slotName,slot in pairs(vehicle.slots) do
      module = slot.module
      if(module~=nil and type(module.fire)=='function') then
        table.insert(slotNames, slotName)
      end
    end
  end
  return slotNames
end
