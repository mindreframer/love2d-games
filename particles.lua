-------------------------------------------
-- Sparkle : Particle
-------------------------------------------
Sparkle = {}
Sparkle.__index = Sparkle

local lg = love.graphics

function Sparkle.create(x,y,count,color,time,ysp)
	local self = {}
	setmetatable(self, Sparkle)

	self.alive = true
	self.time = time or 1
	self.count = count or 5
	self.color = color or COLORS.yellow

	self.particles = {}
	for i=1, self.count do
		self.particles[i] = {}
		self.particles[i].x = x
		self.particles[i].xspeed = math.random(-100,100)

		self.particles[i].y = y
		self.particles[i].yspeed = math.random(-200,50) + (ysp or 0)
	end

	return self
end

function addSparkle(...)
	table.insert(map.particles, Sparkle.create(...))
end

function Sparkle:update(dt)
	self.time = self.time - dt
	if self.time < 0 then
		self.alive = false
		return
	end

	for i,v in ipairs(self.particles) do
		v.x = v.x + v.xspeed*dt

		v.yspeed = v.yspeed + 500*dt
		v.y = v.y + v.yspeed*dt
	end
end

function Sparkle:draw()
	lg.setColor(self.color)
	for i,v in ipairs(self.particles) do
		lg.rectangle("fill", 0.5+v.x, 0.5+v.y, 1, 1)
	end
	lg.setColor(255,255,255,255)
end

-------------------------------------------
-- Dust : Particle
-------------------------------------------
Dust = {}
Dust.__index = Dust

function Dust.create(x,y)
	local self = {}
	setmetatable(self, Dust)

	self.alive = true
	self.time = 0
	self.x = x
	self.y = y

	return self
end

function addDust(...)
	table.insert(map.particles, Dust.create(...))
end

function Dust:update(dt)
	self.time = self.time + dt
	if self.time > 0.25 then
		self.alive = false
		return
	end
end

function Dust:draw()
	lg.setColor(COLORS.offwhite)
	lg.rectangle("fill", self.x-self.time*16, self.y-self.time*16, 1,1)
	lg.rectangle("fill", self.x+self.time*16, self.y-self.time*16, 1,1)
	lg.rectangle("fill", self.x-self.time*16, self.y+self.time*16, 1,1)
	lg.rectangle("fill", self.x+self.time*16, self.y+self.time*16, 1,1)
	lg.setColor(255,255,255)
end

-------------------------------------------
-- Ring : Particle
-------------------------------------------
Ring = {}
Ring.__index = Ring

function Ring.create(x,y,count,radius,color)
	local self = {}
	setmetatable(self, Ring)

	self.alive = true
	self.x = x
	self.y = y
	self.time = 0.25
	self.count = count or 8
	self.radius = radius or 32
	self.color = color or COLORS.yellow

	return self
end

function addRing(...)
	table.insert(map.particles, Ring.create(...))
end

function Ring:update(dt)
	self.time = self.time - dt
	if self.time < 0 then
		self.alive = false
		return
	end
end

function Ring:draw()
	lg.setColor(self.color)
	for i=1,self.count do
		local px = self.x + math.cos((i/self.count)*2*math.pi)*(0.25-self.time)*self.radius
		local py = self.y + math.sin((i/self.count)*2*math.pi)*(0.25-self.time)*self.radius
		lg.rectangle("fill", px, py, 1, 1)
	end
	lg.setColor(255,255,255,255)
end
