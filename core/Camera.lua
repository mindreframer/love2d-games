Camera = class("Camera")
Camera._mt = {}

function Camera._mt:__index(key)
  if key == "x" or key == "y" then
    return self._pos[key]
  else
    return rawget(self, "_" .. key) or self.class.__instanceDict[key]
  end
end

function Camera._mt:__newindex(key, value)
  if key == "x" or key == "y" then
    self._pos[key] = self:processCoordinate(key, value)
  elseif key == "pos" then
    self._pos = value
    value.x = self:processCoordinate("x", value.x)
    value.y = self:processCoordinate("y", value.y)
  else
    rawset(self, key, value)
  end
end

Camera:enableAccessors()

function Camera:initialize(x, y, zoom, angle)
  self._pos = Vector(x or 0, y or 0)
  self.zoom = zoom or 1
  self.angle = angle or 0
  self:applyAccessors()
end

function Camera:update(dt) end
function Camera:start() end
function Camera:stop() end

function Camera:set(scale)
  local width = love.graphics.width / self.zoom / 2
  local height = love.graphics.height / self.zoom / 2
  scale = scale or 1
  
  love.graphics.push()
  love.graphics.scale(self.zoom)
  love.graphics.translate(width, height)
  love.graphics.rotate(self.angle)
  love.graphics.translate(-self.x * scale - width, -self.y * scale - height)
end

function Camera:unset()
  love.graphics.pop()
end

function Camera:move(dx, dy)
  self.x = self._pos.x + dx -- the _pos shortcut can be used when getting, but not setting
  self.y = self._pos.y + dy
end

function Camera:rotate(dr)
  self.angle = self.angle + dr
end

function Camera:getPosition()
  return self._pos.x, self._pos.y
end

function Camera:setPosition(x, y)
  self.x = x
  self.y = y
end

function Camera:setBounds(x1, y1, x2, y2)
  self.bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end

function Camera:processCoordinate(axis, value)
  return self.bounds and math.clamp(value, self.bounds[axis .. "1"], self.bounds[axis .. "2"]) or value
end
