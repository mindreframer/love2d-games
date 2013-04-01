Orb = {}
Orb.__index = Orb

function Orb.create(x,y)
	local self = {}
	setmetatable(self, Orb)

	self.alive = true
	self.x = x
	self.y = y

	return self
end

function Orb:draw()
	if self.alive == true then
		love.graphics.drawq(imgObjects, quads.orb, self.x, self.y)
	end
end

function Orb:collidePlayer(pl)
	if self.alive == true then
		if pl.x-5.5 > self.x+16 or pl.x+5.5 < self.x
		or pl.y+2 > self.y+16 or pl.y+20 < self.y then
			return false
		else
			self.alive = false
			addSparkle(self.x+8, self.y+8, 32, COLORS.lightblue)
			return true
		end
	end
	return false
end
