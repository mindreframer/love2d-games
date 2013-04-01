require("TSerial")

function loadSettings()
	if love.filesystem.exists("settings") then
		local data = love.filesystem.read("settings")
		local set = TSerial.unpack(data)
		setScale(set.scale)
		SCROLL_SPEED = set.scroll_speed
		music_volume = set.music_volume
		sound_volume = set.sound_volume
	else
		setScale(3)
		SCROLL_SPEED = 5 -- 3 to 8 = smooth, 9 = none
		music_volume = 0.6
		sound_volume = 1
	end
end

function loadData()
	if love.filesystem.exists("status") then
		local data = love.filesystem.read("status")
		local set = TSerial.unpack(data)

		unlocked = set.unlocked
		level_status = set.level_status

		deaths = set.deaths
		jumps = set.jumps
		coins = set.coins
	else
		unlocked = 1
		deaths = 0
		jumps = 0
		coins = 0

		level_status = {}
		for i=1,9 do
			level_status[i] = {}
			level_status[i].coins = 0
			level_status[i].deaths = nil
			level_status[i].time = nil
		end
	end
end

function saveData()
	local set = {}
	set.version = 1.0
	set.unlocked = unlocked
	set.deaths = deaths
	set.level_status = level_status
	set.jumps = jumps
	set.coins = coins

	local data = TSerial.pack(set)
	love.filesystem.write("status", data)
end

function saveSettings()
	local set = {}
	set.version = 1.0
	set.scale = SCALE
	set.scroll_speed = SCROLL_SPEED
	set.music_volume = music_volume
	set.sound_volume = sound_volume

	local data = TSerial.pack(set)
	love.filesystem.write("settings", data)
end

function levelCompleted()
	if current_map <= 8 then
		unlocked = math.max(unlocked, current_map+1)
	end

	level_status[current_map].coins = math.max(level_status[current_map].coins, map.numcoins)

	if level_status[current_map].deaths == nil then
		level_status[current_map].deaths = map.deaths
	else
		level_status[current_map].deaths = math.min(level_status[current_map].deaths, map.deaths)
	end

	if level_status[current_map].time == nil then
		level_status[current_map].time = map.time
	else
		level_status[current_map].time = math.min(level_status[current_map].time, map.time)
	end

	coins = 0
	for i = 1,9 do
		coins = coins + level_status[i].coins
	end

	saveData()
	gamestate = STATE_LEVEL_MENU
end
