--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- columnlist class
local newobject = loveframes.NewObject("columnlist", "loveframes_object_columnlist", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: intializes the element
--]]---------------------------------------------------------
function newobject:initialize()
	
	self.type = "columnlist"
	self.width = 300
	self.height = 100
	self.columnheight = 16
	self.buttonscrollamount = 200
	self.mousewheelscrollamount = 1500
	self.autoscroll = false
	self.dtscrolling = true
	self.internal = false
	self.children = {}
	self.internals = {}
	self.OnRowClicked = nil
	self.OnScroll = nil

	local list = loveframes.objects["columnlistarea"]:new(self)
	table.insert(self.internals, list)
	
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
	
	local parent = self.parent
	local base = loveframes.base
	local children = self.children
	local internals = self.internals
	local update = self.Update
	
	self:CheckHover()
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	for k, v in ipairs(children) do
		v:update(dt)
	end
	
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
	local internals = self.internals
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawColumnList or skins[defaultskin].DrawColumnList
	local draw = self.Draw
	local drawcount = loveframes.drawcount
	
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
	
	for k, v in ipairs(children) do
		v:draw()
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
	
	local hover = self.hover
	local children  = self.children
	local internals = self.internals
	
	if hover and button == "l" then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
	end
		
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
	end
	
	for k, v in ipairs(children) do
		v:mousepressed(x, y, button)
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
	
	if not visible then
		return
	end
	
	local children = self.children
	local internals = self.internals
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
	for k, v in ipairs(children) do
		v:mousereleased(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: Adjustchildren()
	- desc: adjusts the width of the object's children
--]]---------------------------------------------------------
function newobject:AdjustColumns()

	local width = self.width
	local bar = self.internals[1].bar
	
	if bar then
		width = width - self.internals[1].internals[1].width
	end
	
	local children = self.children
	local numchildren = #children
	local columnwidth = width/numchildren
	local x = 0
	
	for k, v in ipairs(children) do
		if bar then
			v:SetWidth(columnwidth)
		else
			v:SetWidth(columnwidth)
		end
		v:SetPos(x, 0)
		x = x + columnwidth
	end
	
end

--[[---------------------------------------------------------
	- func: AddColumn(name)
	- desc: gives the object a new column with the specified
			name
--]]---------------------------------------------------------
function newobject:AddColumn(name)

	local internals = self.internals
	local list = internals[1]
	local width = self.width
	local height = self.height
	
	loveframes.objects["columnlistheader"]:new(name, self)
	self:AdjustColumns()
	
	list:SetSize(width, height)
	list:SetPos(0, 0)
	
end

--[[---------------------------------------------------------
	- func: AddRow(...)
	- desc: adds a row of data to the object's list
--]]---------------------------------------------------------
function newobject:AddRow(...)

	local internals = self.internals
	local list = internals[1]
	
	list:AddRow(arg)
	
end

--[[---------------------------------------------------------
	- func: Getchildrenize()
	- desc: gets the size of the object's children
--]]---------------------------------------------------------
function newobject:GetColumnSize()

	local children = self.children
	local numchildren = #self.children
	
	if numchildren > 0 then
		local column    = self.children[1]
		local colwidth  = column.width
		local colheight = column.height
		return colwidth, colheight
	else
		return 0, 0
	end
	
end

--[[---------------------------------------------------------
	- func: SetSize(width, height)
	- desc: sets the object's size
--]]---------------------------------------------------------
function newobject:SetSize(width, height)
	
	local internals = self.internals
	local list = internals[1]
	
	self.width = width
	self.height = height
	self:AdjustColumns()
	
	list:SetSize(width, height)
	list:SetPos(0, 0)
	list:CalculateSize()
	list:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: SetWidth(width)
	- desc: sets the object's width
--]]---------------------------------------------------------
function newobject:SetWidth(width)
	
	local internals = self.internals
	local list = internals[1]
	
	self.width = width
	self:AdjustColumns()
	
	list:SetSize(width)
	list:SetPos(0, 0)
	list:CalculateSize()
	list:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: SetHeight(height)
	- desc: sets the object's height
--]]---------------------------------------------------------
function newobject:SetHeight(height)
	
	local internals = self.internals
	local list = internals[1]
	
	self.height = height
	self:AdjustColumns()
	
	list:SetSize(height)
	list:SetPos(0, 0)
	list:CalculateSize()
	list:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: SetMaxColorIndex(num)
	- desc: sets the object's max color index for
			alternating row colors
--]]---------------------------------------------------------
function newobject:SetMaxColorIndex(num)

	local internals = self.internals
	local list = internals[1]
	
	list.colorindexmax = num
	
end

--[[---------------------------------------------------------
	- func: Clear()
	- desc: removes all items from the object's list
--]]---------------------------------------------------------
function newobject:Clear()

	local internals = self.internals
	local list = internals[1]
	
	list:Clear()
	
end

--[[---------------------------------------------------------
	- func: SetAutoScroll(bool)
	- desc: sets whether or not the list's scrollbar should
			auto scroll to the bottom when a new object is
			added to the list
--]]---------------------------------------------------------
function newobject:SetAutoScroll(bool)

	local internals = self.internals
	local list = internals[1]
	local scrollbar = list:GetScrollBar()
	
	self.autoscroll = bool
	
	if list then
		if scrollbar then
			scrollbar.autoscroll = bool
		end
	end
	
end

--[[---------------------------------------------------------
	- func: SetButtonScrollAmount(speed)
	- desc: sets the scroll amount of the object's scrollbar
			buttons
--]]---------------------------------------------------------
function newobject:SetButtonScrollAmount(amount)

	self.buttonscrollamount = amount
	self.internals[1].buttonscrollamount = amount
	
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
	self.internals[1].mousewheelscrollamount = amount
	
end

--[[---------------------------------------------------------
	- func: GetMouseWheelScrollAmount()
	- desc: gets the scroll amount of the mouse wheel
--]]---------------------------------------------------------
function newobject:GetButtonScrollAmount()

	return self.mousewheelscrollamount
	
end

--[[---------------------------------------------------------
	- func: SetColumnHeight(height)
	- desc: sets the height of the object's columns
--]]---------------------------------------------------------
function newobject:SetColumnHeight(height)

	local children = self.children
	local internals = self.internals
	local list = internals[1]
	
	self.columnheight = height
	
	for k, v in ipairs(children) do
		v:SetHeight(height)
	end
	
	list:CalculateSize()
	list:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: SetDTScrolling(bool)
	- desc: sets whether or not the object should use delta
			time when scrolling
--]]---------------------------------------------------------
function newobject:SetDTScrolling(bool)

	self.dtscrolling = bool
	self.internals[1].dtscrolling = bool
	
end

--[[---------------------------------------------------------
	- func: GetDTScrolling()
	- desc: gets whether or not the object should use delta
			time when scrolling
--]]---------------------------------------------------------
function newobject:GetDTScrolling()

	return self.dtscrolling
	
end