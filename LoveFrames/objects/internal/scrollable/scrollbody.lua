--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- scrollbar class
local newobject = loveframes.NewObject("scrollbody", "loveframes_object_scrollbody", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(parent, bartype)
	
	self.type = "scrollbody"
	self.bartype = bartype
	self.parent = parent
	self.x = 0
	self.y = 0
	self.internal = true
	self.internals = {}
	
	if self.bartype == "vertical" then
		self.width = 16
		self.height = self.parent.height
		self.staticx = self.parent.width - self.width
		self.staticy = 0
	elseif self.bartype == "horizontal" then
		self.width = self.parent.width
		self.height = 16
		self.staticx = 0
		self.staticy = self.parent.height - self.height
	end
	
	table.insert(self.internals, loveframes.objects["scrollarea"]:new(self, bartype))
	
	local bar = self.internals[1].internals[1]
	
	if self.bartype == "vertical" then 
		local upbutton = loveframes.objects["scrollbutton"]:new("up")
		upbutton.parent = self
		upbutton.Update	= function(object, dt)
			upbutton.staticx = 0 + self.width - upbutton.width
			upbutton.staticy = 0
			if object.down and object.hover then
				local dtscrolling = self.parent.dtscrolling
				if dtscrolling then
					local dt = love.timer.getDelta()
					bar:Scroll(-self.parent.buttonscrollamount * dt)
				else
					bar:Scroll(-self.parent.buttonscrollamount)
				end
			end
		end
		local downbutton = loveframes.objects["scrollbutton"]:new("down")
		downbutton.parent = self
		downbutton.Update = function(object, dt)
			downbutton.staticx = 0 + self.width - downbutton.width
			downbutton.staticy = 0 + self.height - downbutton.height
			if object.down and object.hover then
				local dtscrolling = self.parent.dtscrolling
				if dtscrolling then
					local dt = love.timer.getDelta()
					bar:Scroll(self.parent.buttonscrollamount * dt)
				else
					bar:Scroll(self.parent.buttonscrollamount)
				end
			end
		end
		table.insert(self.internals, upbutton)
		table.insert(self.internals, downbutton)
	elseif self.bartype == "horizontal" then
		local leftbutton = loveframes.objects["scrollbutton"]:new("left")
		leftbutton.parent = self
		leftbutton.Update = function(object, dt)
			leftbutton.staticx = 0
			leftbutton.staticy = 0
			if object.down and object.hover then
				local dtscrolling = self.parent.dtscrolling
				if dtscrolling then
					local dt = love.timer.getDelta()
					bar:Scroll(-self.parent.buttonscrollamount * dt)
				else
					bar:Scroll(-self.parent.buttonscrollamount)
				end
			end
		end
		local rightbutton = loveframes.objects["scrollbutton"]:new("right")
		rightbutton.parent = self
		rightbutton.Update = function(object, dt)
			rightbutton.staticx = 0 + self.width - rightbutton.width
			rightbutton.staticy = 0
			if object.down and object.hover then
				local dtscrolling = self.parent.dtscrolling
				if dtscrolling then
					local dt = love.timer.getDelta()
					bar:Scroll(self.parent.buttonscrollamount * dt)
				else
					bar:Scroll(self.parent.buttonscrollamount)
				end
			end
		end
		table.insert(self.internals, leftbutton)
		table.insert(self.internals, rightbutton)
	end
	
	self:SetState(parent.state)
	
	-- apply template properties to the object
	loveframes.templates.ApplyToObject(self)
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	local internals = self.internals
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
	end
	
	self:CheckHover()
	
	for k, v in ipairs(internals) do
		v:update(dt)
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

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawScrollBody or skins[defaultskin].DrawScrollBody
	local draw = self.Draw
	local drawcount = loveframes.drawcount
	local internals = self.internals
	
	-- set the object's draw order
	self:SetDrawOrder()
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
	for k, v in ipairs(internals) do
		v:draw()
	end
	
end