---------------------------------------------------
-- Bee : Enemy
---------------------------------------------------
Bee = {}
Bee.__index = Bee

function Bee.create(x,y,prop)
	local self = {}
	setmetatable(self, Bee)

	self.alive = true
	self.x = x
	self.inity = y
	self.y = y
	self.time = prop.time or 0
	self.dir = prop.dir or -1
	self.yint = prop.yint or 32

	return self
end

function Bee:update(dt)
	self.time = (self.time + dt*4)%(2*math.pi)
	self.y = self.inity + math.cos(self.time)*self.yint
end

function Bee:draw()
	local frame = math.floor(self.time*4) % 2
	love.graphics.drawq(imgEnemies, quads.bee[frame], self.x, self.y, 0,self.dir,1, 7.5)
end

function Bee:collidePlayer(pl)
	if pl.x-5.5 > self.x+3.5 or pl.x+5.5 < self.x-3.5
	or pl.y+2 > self.y+17 or pl.y+20 < self.y+2 then
		return false
	else
		return true
	end
end

---------------------------------------------------
-- Dog : Enemy
---------------------------------------------------
Dog = {}
Dog.__index = Dog

function Dog.create(x,y,prop)
	local self = {}
	setmetatable(self, Dog)

	self.alive = true
	self.x = x
	self.inity = y
	self.y = y
	self.time = 0
	self.dir = prop.dir or -1
	self.jump = prop.jump or 40
	self.state = 0 -- 0 = idle, 1 = jumping

	return self
end

function Dog:update(dt)
	self.time = self.time + dt*4

	if self.state == 1 then
		self.y = self.inity - self.jump*math.sin(self.time)
		if self.time >= math.pi then
			self.state = 0
			self.y = self.inity
		end
	end
end

function Dog:draw()
	if self.state == 0 then
		love.graphics.drawq(imgEnemies, quads.dog, self.x, self.y, 0, self.dir, 1, 8)
	elseif self.state == 1 then
		love.graphics.drawq(imgEnemies, quads.dog_jump, self.x, self.y, 0, self.dir, 1, 8)
	end
end

function Dog:collidePlayer(pl)
	if self.state == 0 then
		local dist = math.pow(pl.x-self.x,2) + math.pow(pl.y-self.y,2)
		if dist < 1524 then
			self.state = 1
			self.time = 0
		end
	end

	if pl.x-5.5 > self.x+3.5 or pl.x+5.5 < self.x-3.5
	or pl.y+2 > self.y+16 or pl.y+20 < self.y+2 then
		return false
	else
		return true
	end
end

---------------------------------------------------
-- Mole : Enemy
---------------------------------------------------
Mole = {}
Mole.__index = Mole

function Mole.create(x,y,prop)
	local self = {}
	setmetatable(self, Mole)

	self.alive = true
	self.x = x
	self.y = y
	self.dir = prop.dir or -1
	self.state = 0 -- 0 = in ground, 1 = ascending, 2 = descending
	self.time = 0

	return self
end

function Mole:update(dt)
	self.time = self.time + dt
	if self.state == 1 and self.time > 3 then
		self.state = 2
		self.time = 0
	elseif self.state == 2 and self.time > 0.2 then
		self.state = 0
		self.time = 0
	end
end

function Mole:draw()
	if self.state == 0 then
		love.graphics.drawq(imgEnemies, quads.mole[0], self.x, self.y, 0, self.dir, 1, 8)
	elseif self.state == 1 then
		local frame = math.min(math.floor(self.time*20), 4)
		love.graphics.drawq(imgEnemies, quads.mole[frame], self.x, self.y, 0, self.dir, 1, 8)
	elseif self.state == 2 then
		local frame = math.min(math.floor(self.time*20), 4)
		love.graphics.drawq(imgEnemies, quads.mole[4-frame], self.x, self.y, 0, self.dir, 1, 8)
	end
end

function Mole:collidePlayer(pl)
	if self.state == 0 then
		local dist = math.pow(pl.x-self.x,2) + math.pow(pl.y-self.y,2)
		if dist < 1800 then
			self.state = 1
			self.time = 0
			addSparkle(self.x, self.y+13, 8, COLORS.lightbrown)
		end
	end

	if self.state ~= 1 then
		return false
	end

	if pl.x-5.5 > self.x+4 or pl.x+5.5 < self.x-4
	or pl.y+2 > self.y+16 or pl.y+20 < self.y+3 then
		return false
	else
		return true
	end
end

---------------------------------------------------
-- Spider : Enemy
---------------------------------------------------
Spider = {}
Spider.__index = Spider

function Spider.create(x,y,prop)
	local self = {}
	setmetatable(self, Spider)

	self.alive = true
	self.x = x
	self.y = y

	return self
end

function Spider:update(dt)
	
end

function Spider:draw()
	love.graphics.drawq(imgEnemies, quads.spider, self.x-5, self.y-2)
end

function Spider:collidePlayer(pl)
	if pl.x-5.5 > self.x+16 or pl.x+5.5 < self.x+4
	or pl.y+2 > self.y+15 or pl.y+20 < self.y+1 then
		return false
	else
		return true
	end
end

---------------------------------------------------
-- Snake : Enemy
---------------------------------------------------
Snake = {}
Snake.__index = Snake

function Snake.create(x,y,prop)
	local self = {}
	setmetatable(self, Snake)

	self.alive = true
	self.x = x
	self.y = y

	self.state = 0 -- hiding, 1 = ascending, 2 = descending
	self.time = 0

	return self
	
end

function Snake:update(dt)
	self.time = self.time + dt
	if self.state == 1 and self.time > 3 then
		self.state = 2
		self.time = 0
	elseif self.state == 2 and self.time > 0.3 then
		self.state = 0
		self.time = 0
	end
end

function Snake:draw()
	if self.state == 0 then
		love.graphics.drawq(imgEnemies, quads.snake[0], self.x, self.y, 0, 1, 1, 7, 8)
	elseif self.state == 1 then
		local frame = math.min(math.floor(self.time*20),5)
		love.graphics.drawq(imgEnemies, quads.snake[frame], self.x, self.y, 0, 1, 1, 7, 8)
	elseif self.state == 2 then
		local frame = math.min(math.floor(self.time*20),5)
		love.graphics.drawq(imgEnemies, quads.snake[5-frame], self.x, self.y, 0, 1, 1, 7, 8)
	end
end

function Snake:collidePlayer(pl)
	if self.state == 0 then
		local dist = math.pow(pl.x-self.x,2) + math.pow(pl.y-self.y,2)
		if dist < 3000 then
			self.state = 1
			self.time = 0
		end
	end
	
	if self.state ~= 1 then
		return false
	end

	if pl.x-5.5 > self.x-2 or pl.x+5.5 < self.x+3
	or pl.y+2 > self.y+4 or pl.y+20 < self.y-8 then
		return false
	else
		return true
	end
end

---------------------------------------------------
-- Turret : Enemy
---------------------------------------------------
Turret = {}
Turret.__index = Turret

function Turret.create(x,y,prop)
	local self = {}
	setmetatable(self, Turret)

	self.alive = true
	self.x = x
	self.y = y
	self.range = prop.range
	self.dir = prop.dir -- -1 = left, 1 = right, 0 = both
	self.cooldown = prop.cooldown or 1 -- in seconds
	self.dist = prop.dist or 256
	self.cool = 0

	return self
end

function Turret:update(dt)
	if self.cool > 0 then
		self.cool = self.cool - dt
	end
end

function Turret:draw()
	love.graphics.drawq(imgEnemies, quads.turret, self.x, self.y)
end

function Turret:collidePlayer(pl)
	if pl.y+20 < self.y+1 or pl.y+2 > self.y+5
	or math.abs(self.x+8-pl.x) > self.range then
		return false
	else
		if self.cool > 0 then
			return false
		end
		self.cool = self.cooldown

		if self.dir == -1 or self.dir == 0 then
			love.audio.play(snd.Turret)
			addArrow(self.x, self.y+3, -1, self.dist)
		end
		if self.dir == 1 or self.dir == 0 then
			love.audio.play(snd.Turret)
			addArrow(self.x+16, self.y+3, 1, self.dist)
		end
		return false
	end
end

---------------------------------------------------
-- Arrow : Enemy
---------------------------------------------------
Arrow = {}
Arrow.__index = Arrow

function Arrow.create(x,y,dir,dist)
	local self = {}
	setmetatable(self, Arrow)

	self.alive = true
	self.x = x
	self.y = y
	self.dir = dir
	self.dist = dist or 512
	self.moved = 0

	return self
end

function addArrow(...)
	table.insert(map.enemies, Arrow.create(...))
end

function Arrow:update(dt)
	self.x = self.x + self.dir*200*dt

	self.moved = self.moved + 200*dt
	if self.moved > self.dist and self.alive == true then
		self.alive = false
		addSparkle(self.x, self.y, 16, COLORS.offwhite)
	end
end

function Arrow:draw()
	love.graphics.drawq(imgEnemies, quads.arrow, self.x, self.y, 0, self.dir, 1, 12, 1)
end

function Arrow:collidePlayer(pl)
	if pl.x-5.5 > self.x or pl.x+5.5 < self.x
	or pl.y+2 > self.y or pl.y+20 < self.y then
		return false
	else
		return true
	end
end

---------------------------------------------------
-- Trigger : Enemy
---------------------------------------------------
Trigger = {}
Trigger.__index = Trigger

function Trigger.create(x,y,width,height,prop)
	local self = {}
	setmetatable(self, Trigger)

	self.alive = true
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.cooldown = prop.cooldown or 1 -- in seconds
	self.cool = 0
	self.prop = prop

	if self.prop.action == "stalactite" then
		self.stalactite = addStalactite(self.prop.x, self.prop.y)
	end

	return self
end

function Trigger:update(dt)
	if self.cool > 0 then
		self.cool = self.cool - dt
	end
end

function Trigger:action()
	if self.cool <= 0 then
		if self.prop.action == "stone" then
			addStone(self.prop.x, self.prop.y, self.prop.yspeed)
			love.audio.play(snd.RockRelease)
		elseif self.prop.action == "fireball" then
			addFireball(self.prop.x, self.prop.y, self.prop.top)
		elseif self.prop.action == "stalactite" then
			self.stalactite:trigger()
		end

		self.cool = self.cooldown
	end
end

function Trigger:collidePlayer(pl)
	if pl.x-5.5 > self.x+self.width or pl.x+5.5 < self.x
	or pl.y+2 > self.y+self.height or pl.y+20 < self.y then
		return false
	else
		self:action()
		return false
	end
end

---------------------------------------------------
-- Fireball : Enemy
---------------------------------------------------
Fireball = {}
Fireball.__index = Fireball

function Fireball.create(x,y,top)
	local self = {}
	setmetatable(self, Fireball)

	self.alive = true
	self.x = x
	self.y = y or 240

	self.top = top or 64
	self.moved = 0
	self.yspeed = -150
	self.starty = self.y

	addSparkle(self.x, self.y, 8, COLORS.red)
	addSparkle(self.x, self.y, 8, COLORS.yellow)
	love.audio.play(snd.Fireball1)

	return self
end

function addFireball(...)
	table.insert(map.enemies, Fireball.create(...))
end

function Fireball:update(dt)
	if self.moved < self.top then
		self.moved = self.moved + math.abs(self.yspeed*dt)
	else
		self.yspeed = math.min(150, self.yspeed + 1000*dt)
	end

	self.y = self.y + self.yspeed*dt

	if self.y > self.starty then
		self.alive = false
		addSparkle(self.x, self.y, 8, COLORS.red)
		addSparkle(self.x, self.y, 8, COLORS.yellow)
		love.audio.play(snd.Fireball2)
	end
end

function Fireball:draw()
	if self.yspeed < -50 then
		love.graphics.drawq(imgEnemies, quads.fireball_moving, self.x, self.y, 0, 1, 1,  3.5, 4)
	elseif self.yspeed > 50 then
		love.graphics.drawq(imgEnemies, quads.fireball_moving, self.x, self.y, 0, 1, -1, 3.5, 4)
	else
		love.graphics.drawq(imgEnemies, quads.fireball_still, self.x, self.y, 0, 1, 1, 3.5, 4)
	end
end

function Fireball:collidePlayer(pl)
	if pl.x-5.5 > self.x+2.5 or pl.x+5.5 < self.x-2.5
	or pl.y+2 > self.y+3 or pl.y+20 < self.y-3 then
		return false
	else
		return true
	end
end

---------------------------------------------------
-- Stone : Enemy
---------------------------------------------------
Stone = {}
Stone.__index = Stone

function Stone.create(x, y, yspeed)
	local self = {}
	setmetatable(self, Stone)

	self.alive = true
	self.x = x
	self.y = y or -10
	self.yspeed = yspeed or 200

	return self
end

function addStone(...)
	table.insert(map.enemies, Stone.create(...))
end

function Stone:update(dt)
	if self.alive then
		self.y = self.y + self.yspeed * dt

		if self.y > MAPH+32 then
			self.alive = false
			love.audio.play(snd.RockGone)
		end
	end
end

function Stone:draw()
	love.graphics.drawq(imgEnemies, quads.stone, self.x, self.y, 0,1,1, 14, 14)
end

function Stone:collidePlayer(pl)
	if pl.x-5.5 > self.x+10 or pl.x+5.5 < self.x-10
	or pl.y+2 > self.y+10 or pl.y+20 < self.y-10 then
		return false
	else
		return true
	end
end

---------------------------------------------------
-- Stalactite : Enemy
---------------------------------------------------
Stalactite = {}
Stalactite.__index = Stalactite

function Stalactite.create(x, y, yspeed)
	local self = {}
	setmetatable(self, Stalactite)

	self.alive = true
	self.x = x
	self.basey = y
	self.y = y
	self.yspeed = yspeed or 200
	self.state = 0 -- 0 = idle, 1 = falling, 2 = respawning
	self.time = 0

	return self
end

function addStalactite(...)
	local o = Stalactite.create(...)
	table.insert(map.enemies, o)
	return o
end

function Stalactite:update(dt)
	if self.state == 1 then
		self.y = self.y + self.yspeed*dt

		if collidePoint(self.x+8, self.y+16) then
			addSparkle(self.x+8, self.y+16, 16, COLORS.orange)
			self.y = self.basey
			self.state = 2
			self.time = 0
		end
	elseif self.state == 2 then
		self.time = self.time + dt
		if self.time > 2 then
			self.state = 0
		end
	end
end

function Stalactite:draw()
	if self.state == 0 then
		love.graphics.drawq(imgEnemies, quads.stalactite_whole, self.x, self.basey)
	elseif self.state == 1 then
		love.graphics.drawq(imgEnemies, quads.stalactite_base, self.x, self.basey)
		love.graphics.drawq(imgEnemies, quads.stalactite_tip, self.x, self.y)
	elseif self.state == 2 then
		if self.time < 1 or math.floor(self.time*20)%2 == 0 then
			love.graphics.drawq(imgEnemies, quads.stalactite_base, self.x, self.basey)
		else
			love.graphics.drawq(imgEnemies, quads.stalactite_whole, self.x, self.basey)
		end
	end
end

function Stalactite:trigger()
	if self.state == 0 then
		self.state = 1
		addSparkle(self.x+8, self.basey, 16, COLORS.orange)
	end
end

function Stalactite:collidePlayer(pl)
	if pl.x-5.5 > self.x+10 or pl.x+5.5 < self.x+7
	or pl.y+2 > self.y+14 or pl.y+20 < self.y+1 then
		return false
	else
		return true
	end
end
