Jumppad = {frame = 0, flframe = 0}
Jumppad.__index = Jumppad

function Jumppad.create(x,y,prop)
	local self = {}
	setmetatable(self,Jumppad)

	self.x = x
	self.y = y
	self.power = prop.power or 500

	return self
end

function Jumppad.globalUpdate(dt)
	Jumppad.frame = (Jumppad.frame + dt*12) % 4
	Jumppad.flframe = math.floor(Jumppad.frame)
end

function Jumppad:draw()
	love.graphics.drawq(imgObjects, quads.jumppad[Jumppad.flframe], self.x, self.y)
end

function Jumppad:collidePlayer(pl)
	if pl.x-5.5 > self.x+10 or pl.x+5.5 < self.x+6
	or pl.y+2 > self.y+16 or pl.y+20 < self.y+13 then
		return false
	else
		pl.yspeed = -self.power
		love.audio.play(snd.Jumppad)
		return true
	end
end
