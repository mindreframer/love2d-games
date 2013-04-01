--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- progressbar class
local newobject = loveframes.NewObject("progressbar", "loveframes_object_progressbar", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()

	self.type = "progressbar"
	self.width = 100
	self.height = 25
	self.min = 0
	self.max = 10
	self.value = 0
	self.barwidth = 0
	self.lerprate = 1000
	self.lerpvalue = 0
	self.lerpto = 0
	self.lerpfrom = 0
	self.completed = false
	self.lerp = false
	self.internal = false
	self.OnComplete = nil
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local lerp = self.lerp
	local lerprate = self.lerprate
	local lerpvalue = self.lerpvalue
	local lerpto = self.lerpto
	local lerpfrom = self.lerpfrom
	local value = self.value
	local completed = self.completed
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	local oncomplete = self.OnComplete
	
	self:CheckHover()
	
	-- caclulate barwidth
	if lerp then
		if lerpfrom < lerpto then
			if lerpvalue < lerpto then
				self.lerpvalue = lerpvalue + lerprate*dt
			elseif lerpvalue > lerpto then
				self.lerpvalue = lerpto
			end
		elseif lerpfrom > lerpto then
			if lerpvalue > lerpto then
				self.lerpvalue = lerpvalue - lerprate*dt
			elseif lerpvalue < lerpto then
				self.lerpvalue = lerpto
			end
		elseif lerpfrom == lerpto then
			self.lerpvalue = lerpto
		end
		self.barwidth = self.lerpvalue/self.max * self.width
		-- min check
		if self.lerpvalue < self.min then
			self.lerpvalue = self.min
		end
		-- max check
		if self.lerpvalue > self.max then
			self.lerpvalue = self.max
		end
	else
		self.barwidth = value/self.max * self.width
		-- min max check
		if value < self.min then
			self.value = self.min
		elseif value > self.max then
			self.value = self.max
		end
	end
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	-- completion check
	if not completed then
		if self.value >= self.max then
			self.completed = true
			if oncomplete then
				oncomplete(self)
			end
		end
	end
	
	if update then
		update(self, dt)
	end
	
end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function newobject:draw()
	
	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawProgressBar or skins[defaultskin].DrawProgressBar
	local draw = self.Draw
	local drawcount = loveframes.drawcount
	
	-- set the object's draw order
	self:SetDrawOrder()
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
end

--[[---------------------------------------------------------
	- func: SetMax(max)
	- desc: sets the object's maximum value
--]]---------------------------------------------------------
function newobject:SetMax(max)

	self.max = max
	
end

--[[---------------------------------------------------------
	- func: GetMax()
	- desc: gets the object's maximum value
--]]---------------------------------------------------------
function newobject:GetMax()

	return self.max
	
end

--[[---------------------------------------------------------
	- func: SetMin(min)
	- desc: sets the object's minimum value
--]]---------------------------------------------------------
function newobject:SetMin(min)

	self.min = min
	
end

--[[---------------------------------------------------------
	- func: GetMin()
	- desc: gets the object's minimum value
--]]---------------------------------------------------------
function newobject:GetMin()

	return self.min
	
end

--[[---------------------------------------------------------
	- func: SetMinMax()
	- desc: sets the object's minimum and maximum values
--]]---------------------------------------------------------
function newobject:SetMinMax(min, max)

	self.min = min
	self.max = max
	
end

--[[---------------------------------------------------------
	- func: GetMinMax()
	- desc: gets the object's minimum and maximum values
--]]---------------------------------------------------------
function newobject:GetMinMax()

	return self.min, self.max
	
end

--[[---------------------------------------------------------
	- func: SetValue(value)
	- desc: sets the object's value
--]]---------------------------------------------------------
function newobject:SetValue(value)

	local lerp = self.lerp
	
	if lerp then
		self.lerpvalue = self.lerpvalue
		self.lerpto = value
		self.lerpfrom = self.lerpvalue
		self.value = value
	else
		self.value = value
	end
	
end

--[[---------------------------------------------------------
	- func: GetValue()
	- desc: gets the object's value
--]]---------------------------------------------------------
function newobject:GetValue()

	return self.value
	
end

--[[---------------------------------------------------------
	- func: SetLerp(bool)
	- desc: sets whether or not the object should lerp
			when changing between values
--]]---------------------------------------------------------
function newobject:SetLerp(bool)

	self.lerp = bool
	self.lerpto = self:GetValue()
	self.lerpvalue = self:GetValue()
	
end

--[[---------------------------------------------------------
	- func: GetLerp()
	- desc: gets whether or not the object should lerp
			when changing between values
--]]---------------------------------------------------------
function newobject:GetLerp()

	return self.lerp
	
end

--[[---------------------------------------------------------
	- func: SetLerpRate(rate)
	- desc: sets the object's lerp rate
--]]---------------------------------------------------------
function newobject:SetLerpRate(rate)

	self.lerprate = rate
	
end

--[[---------------------------------------------------------
	- func: GetLerpRate()
	- desc: gets the object's lerp rate
--]]---------------------------------------------------------
function newobject:GetLerpRate()

	return self.lerprate
	
end

--[[---------------------------------------------------------
	- func: GetCompleted()
	- desc: gets whether or not the object has reached its
			maximum value
--]]---------------------------------------------------------
function newobject:GetCompleted()

	return self.completed
	
end

--[[---------------------------------------------------------
	- func: GetBarWidth()
	- desc: gets the object's bar width
--]]---------------------------------------------------------
function newobject:GetBarWidth()
	
	return self.barwidth
	
end