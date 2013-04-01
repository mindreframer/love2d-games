WaveMgr = {}
WaveMgr.__index = WaveMgr

function WaveMgr.new(total, spawns)
	local inst = {}

	setmetatable(inst, WaveMgr)

	inst.spawns = spawns
	inst.batch = math.floor(total / #spawns)
	inst.total = total
	inst.dispatched = 0
	inst.dispatchStep = 0
	inst.dispatching = nil

	return inst
end

function WaveMgr:update(dt)
	local spawn = self.dispatching
	local old = self.dispatchStep

	if spawn then
		self.dispatchStep = self.dispatchStep + dt

		if math.floor(self.dispatchStep) > old then
			local class

			if world.lcg:random() >= 0.75 then
				class = "HeroTemplar"
			else
				class = "HeroKnight"
			end

			Enemy.new(spawn.x * 32, spawn.y * 32, class)

			self.dispatched = self.dispatched + 1

			print("Dispatched " .. self.dispatched .. "/" .. self.total)
		end

		if self.dispatchStep >= self.batch then
			self.dispatching = nil
		end
	else
		if #world.enemies == 0 then
			if self.dispatched >= self.total then
				gui.over = true
				gui.won = true
			else
				local spawn = self.spawns[1]
			
				self.dispatchStep = 0
				self.dispatching = spawn
			
				table.remove(self.spawns, 1)
				gui:notifyWave(spawn.x, spawn.y)
			end
		end

		if #world.friendlies == 0 then
			gui.over = true
			gui.won = false
		end
	end
end

return WaveMgr
