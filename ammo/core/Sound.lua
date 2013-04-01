Sound = class("Sound")
Sound._mt = {}

function Sound._mt:__index(key)
  local result = rawget(self, "_" .. key) or self.class.__instanceDict[key]
  
  if result then
    return result
  elseif key == "count" then
    return #self._sources
  end
end

Sound:enableAccessors()

function Sound:initialize(file, long, volume, pan)
  self._file = file
  self._long = long or false
  self.defaultVolume = volume or 1
  self.defaultPan = pan or 0
  self._sources = {}

  if self._long then
    self._data = file
  else
    self._data = type(file) == "string" and love.sound.newSoundData(file) or file
  end
  
  self:applyAccessors()
end

function Sound:play(volume, pan)
  local source
  
  for i, v in ipairs(self._sources) do
    if v:isStopped() then
      table.remove(self._sources, i)
      source = v
      break
    end
  end
  
  if not source then source = love.audio.newSource(self._data, "stream") end
  source:rewind()
  source:setVolume(volume or self.defaultVolume)
  source:setPosition(pan or self.defaultPan, 0, 0)
  source:play()
  self._sources[#self._sources + 1] = source -- put playing sources at the back; speeds up finding a stopped source to use
  return source
end

function Sound:loop(volume, pan)
  local source = self:play(volume, pan)
  source:setLooping(true)
  return source
end

function Sound:clearStopped()
  local i = 1
  
  while i <= #self._sources do        
    if self._sources[i]:isStopped() then
      table.remove(self._sources, i)
    else
      i = i + 1
    end
  end
end

function Sound:clearAll()
  self._sources = {}
end

for _, v in pairs{"pause", "resume", "rewind", "stop"} do
  Sound[v] = function(self, last)    
    if last and self._sources[#self._sources] then
      local source = self._sources[#self._sources]
      if source and not source:isStopped() then source[v](source) end
    else
      for _, s in pairs(self._sources) do
        if not s:isStopped() then s[v](s) end
      end
    end
  end
end
