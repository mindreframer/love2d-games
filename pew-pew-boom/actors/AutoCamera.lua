AutoCamera = class('AutoCamera', passion.graphics.Camera)

function AutoCamera:initialize(actor)
  local sWidth, sHeight = love.graphics.getWidth(), love.graphics.getHeight()
  local parent = passion.graphics.Camera:new()
  parent:setPosition(-sWidth/2, -sHeight/2)

  super.initialize(self,parent)
  self.subject = actor

  self:observe('mousepressed_wu', 'scale', 0.95, 0.95)
  self:observe('mousepressed_wd', 'scale', 1.05, 1.05)
end

function AutoCamera:scale(sx, sy)
  super.scale(self, sx, sy)
  self:update()
end

function AutoCamera:update()
  local x,y = self.subject:getPosition()
  self:setPosition(x,y)
end

