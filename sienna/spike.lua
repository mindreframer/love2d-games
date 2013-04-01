Spike = {frame = 0, flframe = 0}
Spike.__index = Spike

function Spike.create(x,y)
	local self = {}
	setmetatable(self, Spike)

	self.alive = true
	self.x = x
	self.y = y

	return self
end

function Spike.globalUpdate(dt)
	Spike.frame = (Spike.frame + dt*16) % 2
	Spike.flframe = math.floor(Spike.frame)
end

function Spike:draw()
	love.graphics.drawq(imgObjects, quads.spike[Spike.flframe], self.x, self.y)
end

function Spike:collidePlayer(pl)
	if pl.x-5.5 > self.x+12 or pl.x+5.5 < self.x+4
	or pl.y+2 > self.y+10 or pl.y+20 < self.y+3 then
		return false
	else
		return true
	end
end
