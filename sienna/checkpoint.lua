Checkpoint = {}
Checkpoint.__index = Checkpoint

function Checkpoint.create(x,y,prop)
	local self = {}
	setmetatable(self, Checkpoint)

	self.x = x
	self.y = y
	self.alive = true
	self.dir = prop.dir or 1

	return self
end

function Checkpoint:draw()
	if self.alive == true then
		love.graphics.drawq(imgObjects, quads.orb, self.x, self.y)
	end
end

function Checkpoint:collidePlayer(pl)
	if self.alive ==true then
		if pl.x-5.5 > self.x+16 or pl.x+5.5 < self.x
		or pl.y+2 > self.y+16 or pl.y+20 < self.y then
			return false
		else
			self.alive = false
			map.startx = self.x+8
			map.starty = self.y-0.01
			map.startdir = self.dir
			addSparkle(self.x+8, self.y, 32, COLORS.lightblue)
			love.audio.play(snd.Checkpoint)
			commitCoins()

			return true
		end
	end
	return false
end
