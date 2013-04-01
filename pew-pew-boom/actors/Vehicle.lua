require('actors/Slot.lua')
require('mixins/BodyBuilder.lua')
require('mixins/SlotBuilder.lua')
require('mixins/DebugDraw.lua')
require('mixins/HasGroupIndex.lua')
require('mixins/AutoCamerable.lua')


Vehicle = class('Vehicle', passion.physics.Actor)

Vehicle:includes(BodyBuilder)
Vehicle:includes(SlotBuilder)
Vehicle:includes(DebugDraw)
Vehicle:includes(HasGroupIndex)
Vehicle:includes(AutoCamerable)

function Vehicle:initialize(ai, x, y, cx, cy, shapes, slots, quad, quadTree)
  super.initialize(self)
  self.ai = ai
  if(ai~=nil) then ai:setVehicle(self) end
  self:buildBody(shapes)
  self:getNewGroupIndex()
  self:buildSlots(slots)
  self:setPosition(x,y)
  self:setCenter(cx,cy)
  self.quad = quad
  self.quadTree = quadTree
  self.quadTree:insert(self)
end

function Vehicle:getSlot(slotName)
  local slot = self.slots[slotName]
  assert(slot~=nil, "Slot " .. slotName .. " not found on ship. Available slots: " .. tostring(self.slots))
  return slot
end

function Vehicle:attach(slotName, module)
  self:getSlot(slotName):attach(module)
end

function Vehicle:destroy()
  self.quadTree:remove(self)
  super.destroy(self)
end



