--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- tabs class
local newobject = loveframes.NewObject("tabs", "loveframes_object_tabs", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()
	
	self.type = "tabs"
	self.width = 100
	self.height = 50
	self.clickx = 0
	self.clicky = 0
	self.offsetx = 0
	self.tab = 1
	self.tabnumber = 1
	self.padding = 5
	self.tabheight = 25
	self.previoustabheight = 25
	self.buttonscrollamount = 200
	self.mousewheelscrollamount = 1500
	self.autosize = true
	self.dtscrolling = true
	self.internal = false
	self.tooltipfont = loveframes.basicfontsmall
	self.internals = {}
	self.children = {}
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the element
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
	
	local x, y = love.mouse.getPosition()
	local tabheight = self.tabheight
	local padding = self.padding
	local autosize = self.autosize
	local padding = self.padding
	local autosize = self.autosize
	local children = self.children
	local numchildren = #children
	local internals = self.internals
	local tab = self.tab
	local parent = self.parent
	local autosize = self.autosize
	local base = loveframes.base
	local update = self.Update
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	self:CheckHover()
	
	if numchildren > 0 and tab == 0 then
		self.tab = 1
	end
	
	local pos = 0
	
	for k, v in ipairs(internals) do
		v:update(dt)
		if v.type == "tabbutton" then
			v.x = (v.parent.x + v.staticx) + pos + self.offsetx
			v.y = (v.parent.y + v.staticy)
			pos = pos + v.width - 1
		end
	end
	
	for k, v in ipairs(children) do
		v:update(dt)
		v:SetPos(padding, tabheight + padding)
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
	
	local internals = self.internals
	local tabheight = self:GetHeightOfButtons()
	local stencilfunc = function() love.graphics.rectangle("fill", self.x, self.y, self.width, tabheight) end
	local stencil = love.graphics.newStencil(stencilfunc)
	local internals = self.internals
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawTabPanel or skins[defaultskin].DrawTabPanel
	local draw = self.Draw
	local drawcount = loveframes.drawcount
	
	-- set the object's draw order
	self:SetDrawOrder()
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
	love.graphics.setStencil(stencil)
	
	for k, v in ipairs(internals) do
		v:draw()
	end
	
	love.graphics.setStencil()
	
	if #self.children > 0 then
		self.children[self.tab]:draw()
	end
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)
	
	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local children = self.children
	local numchildren = #children
	local tab = self.tab
	local internals = self.internals
	local numinternals = #internals
	local hover = self.hover
	
	if hover then
		if button == "l" then
			local baseparent = self:GetBaseParent()
			if baseparent and baseparent.type == "frame" then
				baseparent:MakeTop()
			end
		end
	end
	
	if button == "wu" then
		local buttonheight = self:GetHeightOfButtons()
		local col = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width, 1, buttonheight, 1)
		local visible = internals[numinternals - 1]:GetVisible()
		if col and visible then
			local scrollamount = self.mousewheelscrollamount
			local dtscrolling = self.dtscrolling
			if dtscrolling then
				local dt = love.timer.getDelta()
				self.offsetx = self.offsetx + scrollamount * dt
			else
				self.offsetx = self.offsetx + scrollamount
			end
			if self.offsetx > 0 then
				self.offsetx = 0
			end
		end
	end
		
	if button == "wd" then
		local buttonheight = self:GetHeightOfButtons()
		local col = loveframes.util.BoundingBox(self.x, x, self.y, y, self.width, 1, buttonheight, 1)
		local visible = internals[numinternals]:GetVisible()
		if col and visible then
			local bwidth = self:GetWidthOfButtons()
			if (self.offsetx + bwidth) < self.width then
				self.offsetx = bwidth - self.width
			else
				local scrollamount = self.mousewheelscrollamount
				local dtscrolling = self.dtscrolling
				if dtscrolling then
					local dt = love.timer.getDelta()
					self.offsetx = self.offsetx - scrollamount * dt
				else
					self.offsetx = self.offsetx - scrollamount
				end
			end
		end
	end
	
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
	end
	
	if numchildren > 0 then
		children[tab]:mousepressed(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	local children = self.children
	local numchildren = #children
	local tab = self.tab
	local internals = self.internals
	
	if not visible then
		return
	end
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
	if numchildren > 0 then
		children[tab]:mousereleased(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: AddTab(name, object, tip, image)
	- desc: adds a new tab to the tab panel
--]]---------------------------------------------------------
function newobject:AddTab(name, object, tip, image, onopened, onclosed)

	local padding = self.padding
	local autosize = self.autosize
	local tabnumber = self.tabnumber
	local tabheight = self.tabheight
	local internals = self.internals
	
	object:Remove()
	object.parent = self
	object:SetState(self.state)
	object.staticx = 0
	object.staticy = 0
	
	table.insert(self.children, object)
	internals[tabnumber] = loveframes.objects["tabbutton"]:new(self, name, tabnumber, tip, image, showclose, onopened, onclosed)
	self.tabnumber = tabnumber + 1
	self:AddScrollButtons()
	
	if autosize and not retainsize then
		object:SetSize(self.width - padding * 2, (self.height - tabheight) - padding * 2)
	end
	
end

--[[---------------------------------------------------------
	- func: AddScrollButtons()
	- desc: creates scroll buttons fot the tab panel
	- note: for internal use only
--]]---------------------------------------------------------
function newobject:AddScrollButtons()

	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "scrollbutton" then
			table.remove(internals, k)
		end
	end
	
	local leftbutton = loveframes.objects["scrollbutton"]:new("left")
	leftbutton.parent = self
	leftbutton:SetPos(0, 0)
	leftbutton:SetSize(15, 25)
	leftbutton:SetAlwaysUpdate(true)
	leftbutton.Update = function(object, dt)
		if self.offsetx ~= 0 then
			object.visible = true
		else
			object.visible = false
			object.down = false
			object.hover = false
		end
		if object.down then
			if self.offsetx > 0 then
				self.offsetx = 0
			else
				local scrollamount = self.buttonscrollamount
				local dtscrolling = self.dtscrolling
				if dtscrolling then
					local dt = love.timer.getDelta()
					self.offsetx = self.offsetx + scrollamount * dt
				else
					self.offsetx = self.offsetx + scrollamount
				end
			end
		end
	end
	
	local rightbutton = loveframes.objects["scrollbutton"]:new("right")
	rightbutton.parent = self
	rightbutton:SetPos(self.width - 15, 0)
	rightbutton:SetSize(15, 25)
	rightbutton:SetAlwaysUpdate(true)
	rightbutton.Update = function(object, dt)
		local bwidth = self:GetWidthOfButtons()
		if (self.offsetx + bwidth) > self.width then
			object.visible = true
		else
			object.visible = false
			object.down = false
			object.hover = false
		end
		if object.down then
			if ((self.x + self.offsetx) + bwidth) ~= (self.x + self.width) then
				local scrollamount = self.buttonscrollamount
				local dtscrolling = self.dtscrolling
				if dtscrolling then
					local dt = love.timer.getDelta()
					self.offsetx = self.offsetx - scrollamount * dt
				else
					self.offsetx = self.offsetx - scrollamount
				end
			end
		end
	end
	
	table.insert(internals, leftbutton)
	table.insert(internals, rightbutton)

end

--[[---------------------------------------------------------
	- func: GetWidthOfButtons()
	- desc: gets the total width of all of the tab buttons
--]]---------------------------------------------------------
function newobject:GetWidthOfButtons()

	local width = 0
	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			width = width + v.width
		end
	end
	
	return width
	
end

--[[---------------------------------------------------------
	- func: GetHeightOfButtons()
	- desc: gets the height of one tab button
--]]---------------------------------------------------------
function newobject:GetHeightOfButtons()
	
	return self.tabheight
	
end

--[[---------------------------------------------------------
	- func: SwitchToTab(tabnumber)
	- desc: makes the specified tab the active tab
--]]---------------------------------------------------------
function newobject:SwitchToTab(tabnumber)
	
	local children = self.children
	
	for k, v in ipairs(children) do
		v.visible = false
	end
	
	self.tab = tabnumber
	self.children[tabnumber].visible = true
	
end

--[[---------------------------------------------------------
	- func: SetScrollButtonSize(width, height)
	- desc: sets the size of the scroll buttons
--]]---------------------------------------------------------
function newobject:SetScrollButtonSize(width, height)

	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "scrollbutton" then
			v:SetSize(width, height)
		end
	end
	
end

--[[---------------------------------------------------------
	- func: SetPadding(paddint)
	- desc: sets the padding for the tab panel
--]]---------------------------------------------------------
function newobject:SetPadding(padding)

	self.padding = padding
	
end

--[[---------------------------------------------------------
	- func: SetPadding(paddint)
	- desc: gets the padding of the tab panel
--]]---------------------------------------------------------
function newobject:GetPadding()

	return self.padding
	
end

--[[---------------------------------------------------------
	- func: SetTabHeight(height)
	- desc: sets the height of the tab buttons
--]]---------------------------------------------------------
function newobject:SetTabHeight(height)

	local autosize = self.autosize
	local padding = self.padding
	local previoustabheight = self.previoustabheight
	local children = self.children
	local internals = self.internals
	
	self.tabheight = height
	
	local tabheight = self.tabheight
	
	if tabheight ~= previoustabheight then
		for k, v in ipairs(children) do
			local retainsize = v.retainsize
			if autosize and not retainsize then
				v:SetSize(self.width - padding*2, (self.height - tabheight) - padding*2)
			end
		end
		self.previoustabheight = tabheight
	end
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			v:SetHeight(self.tabheight)
		end
	end
	
end

--[[---------------------------------------------------------
	- func: SetToolTipFont(font)
	- desc: sets the height of the tab buttons
--]]---------------------------------------------------------
function newobject:SetToolTipFont(font)

	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" and v.tooltip then
			v.tooltip:SetFont(font)
		end
	end
	
end

--[[---------------------------------------------------------
	- func: GetTabNumber()
	- desc: gets the object's tab number
--]]---------------------------------------------------------
function newobject:GetTabNumber()

	return self.tab
	
end

--[[---------------------------------------------------------
	- func: RemoveTab(id)
	- desc: removes a tab from the object
--]]---------------------------------------------------------
function newobject:RemoveTab(id)

	local children = self.children
	local internals = self.internals
	local tab = children[id]
	
	if tab then
		tab:Remove()
	end
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			if v.tabnumber == id then
				v:Remove()
			end
		end
	end
	
	local tabnumber = 1
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			v.tabnumber = tabnumber
			tabnumber = tabnumber + 1
		end
	end
	
	self.tabnumber = tabnumber
	self:AddScrollButtons()
	
end

--[[---------------------------------------------------------
	- func: SetButtonScrollAmount(speed)
	- desc: sets the scroll amount of the object's scrollbar
			buttons
--]]---------------------------------------------------------
function newobject:SetButtonScrollAmount(amount)

	self.buttonscrollamount = amount
	
end

--[[---------------------------------------------------------
	- func: GetButtonScrollAmount()
	- desc: gets the scroll amount of the object's scrollbar
			buttons
--]]---------------------------------------------------------
function newobject:GetButtonScrollAmount()

	return self.buttonscrollamount
	
end

--[[---------------------------------------------------------
	- func: SetMouseWheelScrollAmount(amount)
	- desc: sets the scroll amount of the mouse wheel
--]]---------------------------------------------------------
function newobject:SetMouseWheelScrollAmount(amount)

	self.mousewheelscrollamount = amount
	
end

--[[---------------------------------------------------------
	- func: GetMouseWheelScrollAmount()
	- desc: gets the scroll amount of the mouse wheel
--]]---------------------------------------------------------
function newobject:GetButtonScrollAmount()

	return self.mousewheelscrollamount
	
end

--[[---------------------------------------------------------
	- func: SetDTScrolling(bool)
	- desc: sets whether or not the object should use delta
			time when scrolling
--]]---------------------------------------------------------
function newobject:SetDTScrolling(bool)

	self.dtscrolling = bool
	
end

--[[---------------------------------------------------------
	- func: GetDTScrolling()
	- desc: gets whether or not the object should use delta
			time when scrolling
--]]---------------------------------------------------------
function newobject:GetDTScrolling()

	return self.dtscrolling
	
end