
HasGroupIndex = {}

-- Stores the group index so one can associate one to each new object that requires it
local _groupIndexesCounter = 0

-- Stores the group index of each newly created object
local _groupIndexes = setmetatable({}, {__mode = "k"})


function HasGroupIndex:getNewGroupIndex()
  _groupIndexesCounter = _groupIndexesCounter - 1
  self:setGroupIndex(_groupIndexesCounter)
end

function HasGroupIndex:setGroupIndex(groupIndex)
  _groupIndexes[self] = groupIndex
  self:applyToShapes('setGroupIndex', groupIndex)
end

function HasGroupIndex:getGroupIndex()
  return _groupIndexes[self]
end


