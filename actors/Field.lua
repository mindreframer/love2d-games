require('mixins/AutoCamerable')

Field = class('Field', passion.Actor)
Field:includes(AutoCamerable)

function Field:initialize(x,y,width,height,quadTree)
  super.initialize(self)
  self:setPosition(x,y)
  self.width, self.height, self.quadTree = width,height,quadTree
  self.halfWidth = width/2.0
  self.halfHeight = height/2.0
  self.objects={}
end

function Field:getBoundingBox()
  return self.x-self.halfWidth,self.y-self.halfHeight,self.width,self.height
end

function Field:getObjects()
  self.objects = setmetatable({}, {__mode = "k"})
  local qtResults = self.quadTree:query(self:getBoundingBox())
  for _,object in ipairs(qtResults) do
    if(self:test(object)) then
      table.insert(self.objects, object)
    end
  end
end

function Field:update(dt)
  self:getObjects()
end

function Field:test(object)
  return true
end

function Field:draw()
  love.graphics.reset()
  love.graphics.setColor(unpack(passion.colors.red))
  if(showDebugInfo) then
    love.graphics.rectangle('line', self:getBoundingBox())
  end
end




