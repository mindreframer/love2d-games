
PacManLike = {}

function PacManLike:pacManCheck()
  local x,y = self:getPosition()
  
  if(x < -16) then x = 3000 end
  if(x > 3016) then x = 0 end
  if(y < -16) then y = 3000 end
  if(y > 3016) then y = 0 end
  
  self:setPosition(x,y)

end



