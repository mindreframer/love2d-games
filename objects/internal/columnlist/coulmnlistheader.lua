--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- columnlistheader class
local newobject = loveframes.NewObject("columnlistheader", "loveframes_object_columnlistheader", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: intializes the element
--]]---------------------------------------------------------
function newobject:initialize(name, parent)
	
	self.type = "columnlistheader"
	self.parent = parent
	self.name = name
	self.width = 80
	self.height = self.parent.columnheight
	self.hover = false
	self.down = false
	self.clickable = true
	self.enabled = true
	self.descending = true
	self.internal = true

	table.insert(parent.children, self)
		
	local key = 0
	
	for k, v in ipairs(parent.children) do
		if v == self then
			key = k
		end
	end
	
	self.OnClick = function(object)
		local descending = object.descending
		local parent = object.parent
		local pinternals = parent.internals
		local list = pinternals[1]
		if descending then
			object.descending = false
		else
			object.descending = true
		end
		list:Sort(key, object.descending)
	end
	
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
	local base   = loveframes.base
	local update = self.Update
	
	self:CheckHover()
	
	if not self.hover then
		self.down = false
	else
		if loveframes.hoverobject == self then
			self.down = true
		end
	end
	
	if self.down and loveframes.hoverobject == self then
		self.hover = true
	end
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
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
	local drawfunc = skin.DrawColumnListHeader or skins[defaultskin].DrawColumnListHeader
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
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)

	if self.hover and button == "l" then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" and button == "l" then
			baseparent:MakeTop()
		end
		self.down = true
		loveframes.hoverobject = self
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)

	if not self.visible then
		return
	end
	
	local hover = self.hover
	local down = self.down
	local clickable = self.clickable
	local enabled = self.enabled
	local onclick = self.OnClick
	
	if hover and down and clickable and button == "l" then
		if enabled then
			onclick(self, x, y)
		end
	end
	
	self.down = false
	
end

--[[---------------------------------------------------------
	- func: GetName()
	- desc: gets the object's name
--]]---------------------------------------------------------
function newobject:GetName()

	return self.name
	
end