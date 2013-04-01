Player = {}
Player.__index = Player

local PLAYER_SPEED = 150
local MAX_SPEED = 200
local GRAVITY = 1000
local JUMP_POWER = 200
local MAX_JUMP = 32
local INVUL_TIME = 1
local BRAKE_POWER = 1
local COL_OFFSETS = {{-5.5,  2}, {5.5,  2},
					 {-5.5, 10}, {5.5, 10},
					 {-5.5, 20}, {5.5, 20}}
local STATE_WAIT = 0
local STATE_RUNNING = 1
local STATE_BURNING = 2
local STATE_WON = 3

local floor = math.floor
local min = math.min
local lk = love.keyboard

function Player.create(x,y,dir,player)
	local self = {}
	setmetatable(self,Player)

	self.player = player or 1
	if self.player == 1 then
		self.img = imgPlayer
	else
		self.img = imgPlayer2
	end

	return self
end

function Player:respawn(x,y,dir)
	self.x = x or map.startx
	self.y = y or map.starty
	self.dir = dir or map.startdir or 1 -- -1 = left, 1 = right

	self.frame = 0
	self.state = STATE_WAIT

	self.xspeed = 0
	self.yspeed = 0
	self.onGround = false
	self.jump = 0
	self.invul = INVUL_TIME
	self.onWall = false
	
	self.hasGhosts = false
	self.ghosts = {}
end

function Player:update(dt)
	self.frame = self.frame + dt*13
	if self.invul > 0 then
		self.invul = self.invul - dt
	end

	if self.state == STATE_RUNNING then
		-- Set horizontal speed according to direction
		self.xspeed = self.dir*PLAYER_SPEED

		self.yspeed = self.yspeed + GRAVITY*dt
		self.yspeed = min(self.yspeed, MAX_SPEED)

		-- Keep vertical speed if still jumping
		if self.jump > 0 then
			self.yspeed = -JUMP_POWER
		end

		-- move in X and Y direction
		self.onGround = false
		self:moveX(self.xspeed*dt)
		self:moveY(self.yspeed*dt)

		-- check wall jump
		self.onWall = false
		if self.onGround == false then
			if self.dir == -1 and collidePoint(self.x-6, self.y+5)
			or collidePoint(self.x-6, self.y+15) then
				self.onWall = true
			elseif self.dir == 1 and collidePoint(self.x+6, self.y+5)
			or collidePoint(self.x+6, self.y+15) then
				self.onWall = true
			end
		end

		for i,v in ipairs(map.enemies) do
			if v.collidePlayer then
				if v:collidePlayer(self) and self.invul <= 0 then
					love.audio.play(snd.Hurt)
					self:kill()
				end
			end
		end

		for i,v in ipairs(map.entities) do
			if v.collidePlayer then
				v:collidePlayer(self)
			end
		end

		for i,v in ipairs(map.coins) do
			if v.taken == false then
				v:collidePlayer(self)
			end
		end

		self:checkTiles()

		if self.y > MAPH then
			self:kill() end
	
	elseif self.state == STATE_WAIT then
		self.frame = self.frame + dt
		if self.frame > 8 then
			self.state = STATE_RUNNING
			self.frame = 0
		end

	elseif self.state == STATE_BURNING then
		if self.frame >= 8 then
			self:kill()
		end
	end
end

function Player:kill(...)
	deaths = deaths + 1
	map.deaths = map.deaths + 1
	untakeCoins()
	self:respawn(...)
end

function Player:checkTiles()
	local bx, by, tile
	for i=1, #COL_OFFSETS do
		bx = floor((self.x+COL_OFFSETS[i][1]) / TILEW)
		by = floor((self.y+COL_OFFSETS[i][2]) / TILEW)
		tile = fgtiles(bx,by)
		if tile ~= nil then
			-- Check collision with spikes
			if tile.id >= TILE_SPIKE_S and tile.id <= TILE_SPIKE_E then
				if collideSpike(bx,by,self) then
					addSparkle(self.x,self.y+20,32,COLORS.red)
					love.audio.play(snd.Hurt)
					self:kill()
					return
				end
			-- Check collision with lava
			elseif tile.id == TILE_LAVA_TOP then -- Don't check for TILE_LAVA, shouldn't be necessary
				if collideLava(bx,by,self) then
					self.frame = 0
					self.state = STATE_BURNING
					addSparkle(self.x,self.y+20,32,COLORS.red,1,-50)
					love.audio.play(snd.Burn)
					return
				end
			end
		end
	end
end

function Player:keypressed(k, uni)
	if self.state == STATE_RUNNING then
		if self.onGround == true then
			self.jump = MAX_JUMP
			self:addGhost()
			love.audio.play(snd.Jump)
			jumps = jumps + 1

		elseif self.onWall == true then
			self.jump = MAX_JUMP
			self:addGhost()
			if self.dir == 1 then
				self.dir = -1
			else
				self.dir = 1
			end
			love.audio.play(snd.Jump)
			jumps = jumps + 1
		end
	elseif self.state == STATE_WAIT then
		self.state = STATE_RUNNING
		self.frame = 0
	end
end

function Player:keyreleased(k, uni)
	if self.state == STATE_RUNNING then
		if self.jump > 0 then
			self.jump = 0
		end
	end
end

function Player:moveY(dist)
	local bx, by
	local newy = self.y + dist
	local col = false

	-- Check the maximum y offset for each colliding tile
	for i=1, #COL_OFFSETS do
		bx = floor((self.x+COL_OFFSETS[i][1]) / TILEW)
		by = floor((newy+COL_OFFSETS[i][2]) / TILEW)

		if isSolid(bx, by) == true then
			col = true
			if dist > 0 and by*TILEW-20 < newy then
				newy = by*TILEW-20.0001
			elseif dist < 0 and (by+1)*TILEW-2 > newy then
				newy = (by+1)*TILEW-1.9999
			end
		end
	end
	-- Move allowed distance
	self.y = newy
	-- Set new state if colliding with ground
	if col == true then
		self.yspeed = 0

		if dist > 0 then
			self.onGround = true
			-- remove ghosts if any
			if self.hasGhosts then
				self:removeGhosts()
			end
		elseif dist < 0 then
			self.jump = 0
		end
	end
	-- Remove dist from jumping power
	if dist < 0 then
		self.jump = self.jump + dist
	end
end

function Player:moveX(dist)
	local newx = self.x + dist
	local col = false

	for i=1, #COL_OFFSETS do
		local bx = floor((newx+COL_OFFSETS[i][1]) / TILEW)
		local by = floor((self.y+COL_OFFSETS[i][2]) / TILEW)

		if isSolid(bx, by) == true then
			col = true
			if dist > 0 and bx*TILEW-5.5 < newx then
				newx = bx*TILEW-5.5001
			elseif dist < 0 and (bx+1)*TILEW+5.5 > newx then
				newx = (bx+1)*TILEW+5.5001
			end
		end
	end
	self.x = newx
end

function Player:addGhost()
	if self.onWall == true then
		table.insert(self.ghosts, {self.x,self.y,quads.player_wall,self.dir})
	else
		local frame = floor(self.frame % 6)
		table.insert(self.ghosts, {self.x,self.y,quads.player_run[frame],self.dir})
	end
	self.hasGhosts = true
end

function Player:removeGhosts()
	for i,v in ipairs(self.ghosts) do
		addSparkle(v[1],v[2]+10,8,COLORS.yellow)
	end
	self.hasGhosts = false
	self.ghosts = {}
end

function Player:draw()
	local blink = false

	if self.state == STATE_RUNNING then
		-- Blink
		if self.invul > 0 then
			if floor(self.invul*INVUL_TIME*20) % 2 == 1 then
				blink = true
			end
		end
	
		-- draw ghosts
		if self.hasGhosts == true then
			love.graphics.setColor(COLORS.yellow)
			for i,v in ipairs(self.ghosts) do
				love.graphics.drawq(imgPlayerW, v[3], v[1], v[2], 0,v[4],1,6.5)
			end
			love.graphics.setColor(255,255,255,255)
		end
		-- Draw player
		if blink == false then
			if self.onGround == true then
				if self.xspeed == 0 then
					love.graphics.drawq(self.img, quads.player, self.x, self.y, 0,self.dir,1, 6.5)
				else
					local frame = floor(self.frame % 6)
					love.graphics.drawq(self.img, quads.player_run[frame], self.x, self.y, 0,self.dir,1, 6.5)
				end
			else
				if self.onWall == true then
					love.graphics.drawq(self.img, quads.player_wall, self.x, self.y, 0,self.dir,1, 6.5)
				else
					love.graphics.drawq(self.img, quads.player_run[5], self.x, self.y, 0,self.dir,1, 6.5)
				end
			end
		end
	
	elseif self.state == STATE_WAIT then
			love.graphics.drawq(self.img, quads.player_wait1, self.x, self.y, 0, self.dir, 1, 6.5)

	elseif self.state == STATE_BURNING then
		local frame = floor(self.frame)
		love.graphics.drawq(self.img, quads.player_burn[frame], self.x, self.y, 0, self.dir, 1, 6.5)
	end
end
