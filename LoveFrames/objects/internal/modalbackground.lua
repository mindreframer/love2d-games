--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- modalbackground class
local newobject = loveframes.NewObject("modalbackground", "loveframes_object_modalbackground", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(object)
	
	self.type = "modalbackground"
	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()
	self.x = 0
	self.y = 0
	self.internal = true
	self.parent = loveframes.base
	self.object = object
	
	table.insert(loveframes.base.children, self)
	
	if self.object.type ~= "frame" then
		self:Remove()
	end
	
	-- apply template properties to the object
	loveframes.templates.ApplyToObject(self)
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the element
--]]---------------------------------------------------------
function newobject:update(dt)
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local object = self.object
	local update = self.Update
	local base = loveframes.base
	local basechildren = base.children
	
	if #basechildren > 1 then
		if basechildren[#basechildren - 1] ~= self then
			self:Remove()
			table.insert(basechildren, self)
		end
	end
	
	if not object:IsActive() then
		self:Remove()
		loveframes.modalobject = false
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
	
	if not self.visible then
		return
	end
	
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawModalBackground or skins[defaultskin].DrawModalBackground
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