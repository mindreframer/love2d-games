require('actors/Field.lua')

FollowField = class('FollowField', Field)

function FollowField:initialize(subject, width, height, quadTree)
  local x,y = subject:getPosition()
  super.initialize(self,x,y,width,height,quadTree)
  self.subject = subject
end

function FollowField:update(dt)
  self:setPosition(self.subject:getPosition())
  super.update(self, dt)
end

function FollowField:draw()
  if(showDebugInfo) then
    super.draw(self)
    love.graphics.setLineWidth(2)
    for _,object in ipairs(self.objects) do
      love.graphics.line(self.x, self.y, object:getPosition())
    end
  end
end
