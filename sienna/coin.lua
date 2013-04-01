Coin = {frame = 0, flframe = 0}
Coin.__index = Coin

function Coin.create(x,y)
	local self = {}
	setmetatable(self, Coin)

	self.taken = false
	self.committed = false
	self.x = x
	self.y = y

	return self
end

function Coin.globalUpdate(dt)
	Coin.frame = (Coin.frame + dt*10) % 4
	Coin.flframe = math.floor(Coin.frame)
end

function Coin:draw()
	if self.taken == false then
		love.graphics.drawq(imgObjects, quads.coin[Coin.flframe], self.x, self.y)
	end
end

function Coin:untake()
	if self.committed == false then
		self.taken = false
		map.numcoins = map.numcoins - 1
	end
end

function Coin:commit()
	if self.taken == true then
		self.committed = true
	end
end

function Coin:collidePlayer(pl)
	if self.tame == true or pl.x-5.5 > self.x+11 or pl.x+5.5 < self.x+5
	or pl.y+2 > self.y+14 or pl.y+20 < self.y+3 then
		return false
	else
		love.audio.play(snd.Coin)
		addSparkle(self.x+8,self.y+8,32,COLORS.yellow)
		self.taken = true
		map.numcoins = map.numcoins + 1
		return true
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
