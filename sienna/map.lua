OBJ_ROTSPIKE = 1281
OBJ_CHECKPOINT = 1284
OBJ_JUMPPAD_S = 1297
OBJ_JUMPPAD_E = 1300
OBJ_COIN = 1305

TILE_SPIKE_S = 129
TILE_SPIKE_E = TILE_SPIKE_S+3
TILE_WATER_TOP = 135
TILE_WATER = 151
TILE_LAVA_TOP = 137
TILE_LAVA = 153

local floor = math.floor
local loader = require("AdvTiledLoader.Loader")
loader.path = "maps/"

map_files = {"mine1.tmx","mine2.tmx","mine3.tmx","mine4.tmx",
		"temple1.tmx","temple2.tmx","temple3.tmx","temple4.tmx","temple5.tmx"}

function loadMap(level)
	current_map = level
	gamestate = STATE_INGAME

	map = loader.load(map_files[level])
	map.drawObjects = false
	fgtiles = map.tileLayers.fg.tileData

	map.enemies = {}
	map.particles = {}
	map.entities = {}
	map.coins = {}

	map.deaths = 0
	map.numcoins = 0
	map.time = 0

	MAPW = map.width*TILEW
	MAPH = map.height*TILEW
	map.startx = 16
	map.starty = 192

	for i,v in ipairs(map.objectLayers.obj.objects) do
		if v.gid == OBJ_ROTSPIKE or v.gid == OBJ_ROTSPIKE+1 then
			table.insert(map.enemies, Spike.create(v.x, v.y-16))

		elseif v.gid == OBJ_CHECKPOINT then
			table.insert(map.entities, Checkpoint.create(v.x, v.y-20, v.properties))
		
		elseif v.gid == OBJ_COIN then
			table.insert(map.coins, Coin.create(v.x, v.y-16))

		elseif v.type == "start" then
			map.startx = v.x+8
			map.starty = v.y-4.01

		elseif v.gid and v.gid >= OBJ_JUMPPAD_S and v.gid <= OBJ_JUMPPAD_E then
			table.insert(map.entities, Jumppad.create(v.x, v.y-16, v.properties))

		elseif v.type == "bee" then
			table.insert(map.enemies, Bee.create(v.x+8, v.y-18, v.properties))
		elseif v.type == "dog" then
			table.insert(map.enemies, Dog.create(v.x+8, v.y, v.properties))
		elseif v.type == "mole" then
			table.insert(map.enemies, Mole.create(v.x+8, v.y, v.properties))
		elseif v.type == "spider" then
			table.insert(map.enemies, Spider.create(v.x, v.y, v.properties))
		elseif v.type == "snake" then
			table.insert(map.enemies, Snake.create(v.x+8, v.y, v.properties))
		elseif v.type == "trigger" then
			table.insert(map.enemies, Trigger.create(v.x, v.y-16, v.width, v.height, v.properties))
		elseif v.type == "turret" then
			table.insert(map.enemies, Turret.create(v.x, v.y, v.properties))
		end
	end

	tx = map.startx - WIDTH/2
	ty = map.starty - HEIGHT/2

	player:respawn()
end

function reloadMap()
	loadMap(current_map)
end

function collidePoint(x,y)
	return isSolid(floor(x/TILEW), floor(y/TILEW))
end

function collideSpike(x,y, pl)
	x = x*TILEW
	y = y*TILEW
	if pl.x-5.5 > x+10 or pl.x+5.5 < x+3
	or pl.y+2 > y+10 or pl.y+20 < y+3 then
		return false
	else
		return true
	end
end

function collideLava(x,y, pl)
	x = x*TILEW
	y = y*TILEW
	if pl.x-5.5 > x+16 or pl.x+5.5 < x
	or pl.y+2 > y+16 or pl.y+20 < y+8 then
		return false
	else
		return true
	end
end

function isSolid(x,y)
	local tile = fgtiles(x,y)
	if tile ~= nil and tile.id <= 128 then
		return true
	else
		return false
	end
end

function commitCoins()
	for i,v in ipairs(map.coins) do
		if v.taken then
			v:commit()
		end
	end
end

function untakeCoins()
	for i,v in ipairs(map.coins) do
		if v.taken == true and v.committed == false then
			v:untake()
		end
	end
end
