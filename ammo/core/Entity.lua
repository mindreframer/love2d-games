Entity = class("Entity")
Entity._mt = {}

function Entity._mt:__index(key)
  if key == "x" or key == "y" then
    return self._pos[key]
  else
    return rawget(self, "_" .. key) or self.class.__instanceDict[key]
  end
end

function Entity._mt:__newindex(key, value)
  if key == "x" or key == "y" then
    self._pos[key] = value
  elseif key == "layer" then
    if self._layer == value then return end
    
    if self._world then
      local prev = self._layer
      self._layer = value
      self._world:_setLayer(self, prev)
    else
      self._layer = value
    end
  elseif key == "name" then
    if self._name == value then return end
    
    if self._world then
      if self._name then self._world.names[self._name] = nil end
      self._world.names[value] = self
    else
      self._name = value
    end
  elseif key == "world" then
    if self._world == value then return end
    if self._world then self._world:remove(self) end
    if value then value:add(self) end
  else
    rawset(self, key, value)
  end
end

Entity:enableAccessors()

function Entity:initialize(x, y)
  self._pos = Vector(x or 0, y or 0)
  self.collidable = true
  self.active = true
  self.visible = true
  self._layer = 1
  self:applyAccessors()
end

function Entity:added() end
function Entity:update(dt) end
function Entity:draw() end
function Entity:removed() end
