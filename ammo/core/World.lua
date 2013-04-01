World = class("World")
World._mt = {}

-- for speed
local storeColor = love.graphics.storeColor
local resetColor = love.graphics.resetColor

function World._mt:__index(key)
  if key == "count" then
    return self._updates._length
  elseif key == "camera" then
    return self._camera
  elseif key == "all" then
    return self._updates:getAll()
  else
    return self.class.__instanceDict[key]
  end
end

function World._mt:__newindex(key, value)
  if key == "camera" then
    if rawget(self, "_camera") then
      self._camera:stop()
      self._camera._world = nil
    end
    
    self._camera = value and value or Camera:new()
    self._camera._world = self
    self._camera:start()
  else
    rawset(self, key, value)
  end
end

World:enableAccessors()

function World:initialize()
  self.active = true
  self.visible = true
  
  -- lists
  self._updates = LinkedList:new("_updateNext", "_updatePrev")
  self._layers = { min = 0, max = 0 }
  self._add = {}
  self._remove = {}
  self._classCounts = {}
  self._names = setmetatable({}, { __newindex = function(s, k, v) rawset(s, k, v) end })
  
  -- interface to _names
  self.names = setmetatable({}, { __index = self._names, __newindex = function(_, name, entity)
    if self._names[name] then self._names[name]._name = nil end
    self._names[name] = entity
    if entity then entity._name = name end
  end })
  
  self:applyAccessors()
  self.camera = nil -- set off the default behaviour
end

function World:update(dt)
  -- update
  for v in self._updates:iterate() do
    if v.active then
      v:update(dt)
    end
  end
  
  self.camera:update(dt)
  self:_updateLists()
end

function World:draw()
  for i = self._layers.max, self._layers.min, -1 do
    local layer = self._layers[i]
    
    if layer then
      if layer.pre then layer.pre() end
      self.camera:set(layer.scale)
      
      for v in layer:iterate(true) do -- reverse
        storeColor()
        if v.visible then v:draw() end
        resetColor()
      end
      
      self.camera:unset()
      if layer.post then layer.post() end
    end
  end
end

function World:start() end
function World:stop() end

function World:add(...)
  for _, v in pairs{...} do
    if not v._world then
      self._add[#self._add + 1] = v
      self._additionQueued = true
    end
  end
end

function World:remove(...)
  for _, v in pairs{...} do
    if v._world == self and not v._removalQueued then
      self._remove[#self._remove + 1] = v
      v._removalQueued = true
    end
  end
end

function World:removeAll()
  for e in self._updates:iterate() do
    self._remove[#self._remove + 1] = v
    v._removeQueued = true
  end
end

function World:addLayer(index, scale, pre, post)
  local layer = LinkedList:new("_drawNext", "_drawPrev")
  
  if type(index) == "table" then
    scale = index[2] or index.scale
    pre = index.pre
    post = index.post
    index = index[1] or index.index
  end
  
  layer.scale = scale or 1
  layer.pre = pre
  layer.post = post
  self._layers[index] = layer
  self._layers.min = math.min(index, self._layers.min)
  self._layers.max = math.max(index, self._layers.max)
  return layer
end

function World:setupLayers(t)
  local func, last
  
  for k, v in pairs(t) do
    if type(v) == "function" then
      if last then
        last.pre = v
      else
        func = v
      end
    else
      if type(v) == "table" then
        last = self:addLayer(k, v[1] or v.scale, v.pre, v.post)
      else
        last = self:addLayer(k, v)
      end
      
      if func then
        last.post = func
        func = nil
      end
    end
  end
end

function World:classCount(cls)
  if type(cls) == "table" then cls = cls.name end
  return self._classCounts[cls]
end

function World:iterate()
  return self._updates:iterate()
end

function World:_updateLists()
  -- remove
  for _, v in pairs(self._remove) do
    if v.removed then v:removed() end
    self._updates:remove(v)
    v._removalQueued = false
    v._world = nil
    if v.class then self._classCounts[v.class.name] = self._classCounts[v.class.name] - 1 end
    if v._layer then self._layers[v._layer]:remove(v) end
    if v._name then self._names[v._name] = nil end 
  end
  
  -- add
  for _, v in pairs(self._add) do
    self._updates:push(v)
    v._additionQueued = false
    v._world = self
    if v.class then self._classCounts[v.class.name] = (self._classCounts[v.class.name] or 0) + 1 end
    if v._layer then self:_setLayer(v) end
    if v._name then self.names[v._name] = v end
    if v.added then v:added() end
  end
  
  -- empty tables
  self._add = {}
  self._remove = {}
end

function World:_setLayer(e, prev)
  if self._layers[prev] then self._layers[prev]:remove(e) end
  if not self._layers[e.layer] then self:addLayer(e.layer) end
  self._layers[e.layer]:unshift(e)
end
