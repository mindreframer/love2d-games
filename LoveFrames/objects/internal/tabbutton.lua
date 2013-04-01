--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- tabbutton class
local newobject = loveframes.NewObject("tabbutton", "loveframes_object_tabbutton", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(parent, text, tabnumber, tip, image, onopened, onclosed)

	self.type = "tabbutton"
	self.font = loveframes.smallfont
	self.text = text
	self.tabnumber = tabnumber
	self.parent = parent
	self.staticx = 0
	self.staticy = 0
	self.width = 50
	self.height = 25
	self.internal = true
	self.down = false
	self.image = nil
	self.OnOpened = nil
	self.OnClosed = nil
	
	if tip then
		self.tooltip = loveframes.objects["tooltip"]:new(self, tip)
		self.tooltip:SetFollowCursor(false)
		self.tooltip:SetFollowObject(true)
		self.tooltip:SetOffsets(0, -(self.tooltip.text:GetHeight() + 12))
	end
	
	if image then
		self:SetImage(image)
	end
	
	if onopened then
		self.OnOpened = onopened
	end
	
	if onclosed then
		self.OnClosed = onclosed
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
	local base = loveframes.base
	local update = self.Update
	local internals = self.internals
	
	self:CheckHover()
	self:SetClickBounds(parent.x, parent.y, parent.width, parent.height)
	
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
	
	local image = self.image
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawTabButton or skins[defaultskin].DrawTabButton
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
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover = self.hover
	local internals = self.internals
	
	if hover and button == "l" then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
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
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover = self.hover
	local parent = self.parent
	local tabnumber = self.tabnumber
	local internals = self.internals
	
	if hover and button == "l" then
		if button == "l" then
			local tab = self.parent.tab
			local internals = parent.internals
			local onopened = self.OnOpened
			local prevtab = internals[tab]
			local onclosed = prevtab.OnClosed
			parent:SwitchToTab(tabnumber)
			if onopened then
				onopened(self)
			end
			if onclosed then
				onclosed(prevtab)
			end
		end
	end
	
	self.down = false

end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function newobject:SetText(text)

	self.text = text
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function newobject:GetText()

	return self.text
	
end

--[[---------------------------------------------------------
	- func: SetImage(image)
	- desc: adds an image to the object
--]]---------------------------------------------------------
function newobject:SetImage(image)

	if type(image) == "string" then
		self.image = love.graphics.newImage(image)
	else
		self.image = image
	end
	
end

--[[---------------------------------------------------------
	- func: GetImage()
	- desc: gets the object's image
--]]---------------------------------------------------------
function newobject:GetImage()

	return self.image
	
end

--[[---------------------------------------------------------
	- func: GetTabNumber()
	- desc: gets the object's tab number
--]]---------------------------------------------------------
function newobject:GetTabNumber()

	return self.tabnumber
	
end