---
--- audio.lua - AudioMgr object
---
--- Usage:
---     Give the World object an "audio" field set to an AudioMgr.new().
---     Whenever you need to play a sound effect from e.g. an entity,
---     call something like self.world.audio:playSound("skeleton_hit") .
---     If SOUNDNAME does not exist it will just play a placeholder pop
---     sound effect.
---

AudioMgr = {}
AudioMgr.__index = AudioMgr

--- Creates a new audio controller. Only one of these is needed.
function AudioMgr.new()
    local inst = {}

    setmetatable(inst, AudioMgr)

    inst.globalSfxVolume = 1.0
    inst.sfxVolumes = {}
    inst.sfx = {}
    inst.listenerX = 0
    inst.listenerY = 0
    inst.DISTANCE_CONSTANT = 700
    inst:loadAllSfx()

    inst.nowPlaying = nil
    inst.globalMusicvolume = 1.0
    inst.musicVolumes = {}
    inst.allMusic = {}
    inst.themes = {}
    inst:loadAllSongs()

    return inst
end

--- Load all sound effects (not music) into this object.
function AudioMgr:loadAllSfx()
    self:loadEffect("pop", artDir .. "/sounds/pop.wav", 1.0)
    self:loadEffect("hit", artDir .. "/sounds/hitsound.wav", 1.0)
    self:loadEffect("die", artDir .. "/sounds/die.wav", 1.0)
end

--- Prepare all music for streaming from disk, but don't play any of it.
function AudioMgr:loadAllSongs()
    self:loadSong("derpy", "easy_dungeon", artDir .. "/sounds/derpybgm.ogg", 1.0)
    self:loadSong("quick", "easy_dungeon", artDir .. "/sounds/easy_quicksong.ogg", 1.0)
end

--- Load a sound effect NAME from location PATH with volume VOL.
function AudioMgr:loadEffect(name, path, vol)
    self.sfx[name] = love.audio.newSource(path, "static")
    self.sfxVolumes[name] = vol
end

--- Load a song SONGNAME into theme THEME from location PATH with volume VOL.
--  A theme represents a collection of similarly purposed music. For example,
--  all easy dungeons may play songs from the easy_dungeon theme while hard
--  ones play from the hard_dungeon theme.
function AudioMgr:loadSong(songName, theme, path, vol)
    self.allMusic[songName] = love.audio.newSource(path, "stream")
    self.musicVolumes[songName] = vol

    for group, tbl in pairs(self.themes) do
        if group == theme then
            local themeGrp = self.themes[theme]
            themeGrp[#themeGrp + 1] = songName

            return
        end
    end

    self.themes[theme] = {}
    themeGrp = self.themes[theme]
    themeGrp[#themeGrp + 1] = songName
end

--- Sets the global volume multiplier for sound effects to VOL. Must be
--  between 0 and 1 inclusive.
function AudioMgr:setSfxVolume(vol)
    if vol > 1.0 then
        vol = 1.0
    elseif vol < 0 then
        vol = 0
    end

    self.globalSfxVolume = vol
end

--- Sets the global volume multiplier for music to VOL. Must be
--  between 0 and 1 inclusive.
function AudioMgr:setMusicVolume(vol)
    if vol > 1.0 then
        vol = 1.0
    elseif vol < 0 then
        vol = 0
    end

    self.globalMusicVolume = vol
end

--- Sets the X and Y coordinates of the audio "listener", used for SFX.
function AudioMgr:setListenerPos(x, y)
    self.listenerX = x
    self.listenerY = y
end

--- Plays sound effect NAME once. If no such sound is found, plays a default sound
--  effect.
function AudioMgr:playSound(name)
    local sound = nil
    local volume = 1.0

    for soundName, soundObj in pairs(self.sfx) do
        if soundName == name then
            sound = soundObj
            volume = self.sfxVolumes[soundName]
            break
        end
    end

    if sound == nil then
        sound = self.sfx["pop"]
        volume = self.sfxVolumes["pop"]
    end

    sound:setVolume(self.globalSfxVolume * volume)
    love.audio.rewind(sound)
    love.audio.play(sound)
    return sound
end

--- Plays sound NAME as if it was coming from position (x, y).
function AudioMgr:playSoundFrom(name, x, y)
    local sound = self:playSound(name)
    local reduction = self:getVolumeReduction(x, y)
    sound:setVolume(sound:getVolume() * reduction)
    return sound
end


--- Get the volume reduction factor from (X, Y) to the listener position.
function AudioMgr:getVolumeReduction(x, y)
    local dx = x - self.listenerX
    local dy = y - self.listenerY
    local dist = math.sqrt(dx * dx + dy * dy)
    return math.exp( -dist / self.DISTANCE_CONSTANT)
end

--- Loops the song SONG. Stops any currently playing song. Does nothing if
--  SONG does not exist.
function AudioMgr:playSong(song)
    sound = nil
    volume = 1.0
    local songObj = self.allMusic[song]
    sound = songObj
    volume = self.musicVolumes[song]    

    if sound == nil then
        return
    end

    self:stopMusic()
    sound:setVolume(self.globalSfxVolume * volume)
    sound:setLooping(true)
    love.audio.rewind(sound)
    love.audio.play(sound)
    self.nowPlaying = sound
    return sound
end

--- Loops a random song from theme THEME.
function AudioMgr:playFromTheme(theme)
    group = self.themes[theme]

    if group == nil or #group == 0 then
        return
    end

    self:playSong(group[math.random(#group)])
end

--- Pauses BGM.
function AudioMgr:stopMusic()
    if self.nowPlaying ~= nil then
        self.nowPlaying:pause()
    end
end

--- Resumes BGM, hopefully.
function AudioMgr:resumeMusic()
    if self.nowPlaying ~= nil then
        self.nowPlaying:play()
    end
end

return AudioMgr
