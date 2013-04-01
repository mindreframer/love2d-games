-- math

math.tau = math.pi * 2 -- the proper circle constant

function math.scale(x, min1, max1, min2, max2)
  return min2 + ((x - min1) / (max1 - min1)) * (max2 - min2)
end

function math.lerp(a, b, t)
  return a + (b - a) * t
end

function math.sign(x)
  return x > 0 and 1 or (x < 0 and -1 or 0)
end

function math.round(x)
  return math.floor(x + .5)
end

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

function math.angle(x1, y1, x2, y2)
  local a = math.atan2(y2 - y1, x2 - x1)
  return a < 0 and a + math.tau or a
end

function math.length(x, y)
  return math.sqrt(x ^ 2 + y ^ 2)
end

function math.distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function math.dot(x1, y1, x2, y2)
  return x1 * x2 + y1 * y2
end

-- love.graphics

local r, g, b, a = love.graphics.getColor()
local oldSetMode = love.graphics.setMode
love.graphics.width = love.graphics.getWidth()
love.graphics.height = love.graphics.getHeight()

function love.graphics.storeColor()
  r, g, b, a = love.graphics.getColor()
end

function love.graphics.resetColor()
  love.graphics.setColor(r, g, b, a)
end

function love.graphics.setMode(width, height, fullscreen, vsync, fsaa)
  local success, result = pcall(oldSetMode, width, height, fullscreen, vsync, fsaa)
  
  if success then
    if result then
      love.graphics.width = width
      love.graphics.height = height
    end
    
    return result
  else
    error(result, 2)
  end
end

-- love.mouse

love.mouse.getRawX = love.mouse.getX
love.mouse.getRawY = love.mouse.getY

function love.mouse.getRawPosition()
  return love.mouse.getRawX(), love.mouse.getRawY()
end

function love.mouse.getWorldX(camera)
  camera = camera or ammo.world.camera
  return love.mouse.getRawX() / camera.zoom + camera.x
end

function love.mouse.getWorldY(camera)
  camera = camera or ammo.world.camera
  return love.mouse.getRawY() / camera.zoom + camera.y
end

function love.mouse.getWorldPosition(camera)
  return love.mouse.getWorldX(camera), love.mouse.getWorldY(camera)
end

function love.mouse.getRotatedX(camera)
  camera = camera or ammo.world.camera
  local x = love.mouse.getRawX()
  local y = love.mouse.getRawY()
  return math.cos(-camera.angle) * (x / camera.zoom) - math.sin(-camera.angle) * (y / camera.zoom) + camera.x
end

function love.mouse.getRotatedY(camera)
  camera = camera or ammo.world.camera
  local x = love.mouse.getRawX()
  local y = love.mouse.getRawY()
  return math.sin(-camera.angle) * (x / camera.zoom) + math.cos(-camera.angle) * (y / camera.zoom) + camera.y
end

function love.mouse.getRotatedPosition(camera)
  return love.mouse.getRotatedX(camera), love.mouse.getRotatedY(camera)
end

function love.mouse.switchToWorld()
  love.mouse.getX = love.mouse.getWorldX
  love.mouse.getY = love.mouse.getWorldY
  love.mouse.getPosition = love.mouse.getWorldPosition
end

function love.mouse.switchToRotated()
  love.mouse.getX = love.mouse.getRotatedX
  love.mouse.getY = love.mouse.getRotatedY
  love.mouse.getPosition = love.mouse.getRotatedPosition
end

function love.mouse.switchToRaw()
  love.mouse.getX = love.mouse.getRawX
  love.mouse.getY = love.mouse.getRawY
  love.mouse.getPosition = love.mouse.getRawPosition
end

love.mouse.switchToWorld()

-- Object

function Object:enableAccessors()
  if not self._mt then self._mt = {} end
  
  for _, v in pairs(Object.__metamethods) do
    self._mt[v] = self.__instanceDict[v]
  end
  
  local super = self.super
  local done = 0
  if self._mt.__index then done = done + 1 end
  if self._mt.__newindex then done = done + 1 end
  
  while super and done ~= 2 do
    if super._mt then
      if not self._mt.__index then
        self._mt.__index = super._mt.__index
        done = done + 1
      end
      
      if not self._mt.__newindex then
        self._mt.__newindex = super._mt.__newindex
        done = done + 1
      end
    end
    
    super = super.super
  end
  
  return self
end

function Object:applyAccessors()
  if not self._mt then return end
  setmetatable(self, self._mt)
end
