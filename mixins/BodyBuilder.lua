
BodyBuilder = {}

-- An passion.physics.Actor that can create shapes dynamically depending on a list of shape specs
function BodyBuilder:buildBody(shapes)
  self:newBody()
  for shapeType,shapeData in pairs(shapes) do
    if(shapeType=='circle') then
      self:newCircleShape(unpack(shapeData))
    elseif(shapeType=='polygon') then
      self:newPolygonShape(unpack(shapeData))
    elseif(shapeType=='rectangle') then
      self:newRectangleShape(unpack(shapeData))
    else
      error('Unknown shape type: ' .. shapeType)
    end
  end
  self:setMassFromShapes()
end



