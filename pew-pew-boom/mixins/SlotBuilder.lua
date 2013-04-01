require('actors/Slot.lua')

SlotBuilder = {}

-- An object that can create slots dynamically given a list of specifications
function SlotBuilder:buildSlots(slots)

  self.slots = {}
  for slotName,slotData in pairs(slots) do
    self.slots[slotName] = Slot:new(self, slotName, slotData)
  end
end



