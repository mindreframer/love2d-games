DebugDraw = {}


-- An passion.physics.Actor with center and 'quad' defined.
-- Draws the actor's quad, shape and bbox if the global variable 'debug' is defined
function DebugDraw:draw()
  love.graphics.setColor(unpack(self.color or passion.colors.white))
  local x, y = self:getPosition()
  local cx, cy = self:getCenter()
  passion.graphics.drawq(self.quad, x, y, self:getAngle(), 1, 1, cx, cy)
  if(showDebugInfo==true) then
    love.graphics.setColor(unpack(passion.colors.lightGreen))
    self:drawShapes()
    love.graphics.rectangle('line', self:getBoundingBox())
  end
end
