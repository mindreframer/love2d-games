--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- list class
local newobject = loveframes.NewObject("list", "loveframes_object_list", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()
	
	self.type = "list"
	self.display = "vertical"
	self.width = 300
	self.height = 150
	self.clickx = 0
	self.clicky = 0
	self.padding = 0
	self.spacing = 0
	self.offsety = 0
	self.offsetx = 0
	self.extrawidth = 0
	self.extraheight = 0
	self.buttonscrollamount = 200
	self.mousewheelscrollamount = 1500
	self.internal = false
	self.hbar = false
	self.vbar = false
	self.autoscroll = false
	self.horizontalstacking = false
	self.dtscrolling = true
	self.internals = {}
	self.children = {}
	self.OnScroll = nil
	
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
	local alwaysupdate 	= self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local internals = self.internals
	local children = self.children
	local display = self.display
	local parent = self.parent
	local horizontalstacking = self.horizontalstacking
	local base = loveframes.base
	local update = self.Update
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	self:CheckHover()
	
	for k, v in ipairs(internals) do
		v:update(dt)
	end
	
	local x = self.x
	local y = self.y
	local width = self.width
	local height = self.height
	local offsetx = self.offsetx
	local offsety = self.offsety
	
	for k, v in ipairs(children) do
		v:update(dt)
		v:SetClickBounds(x, y, width, height)
		v.x = (v.parent.x + v.staticx) - offsetx
		v.y = (v.parent.y + v.staticy) - offsety
		if display == "vertical" then
			if v.lastheight ~= v.height then
				self:CalculateSize()
				self:RedoLayout()
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

	local x = self.x
	local y = self.y
	local width = self.width
	local height = self.height
	local internals = self.internals
	local children = self.children
	local stencilfunc = function() love.graphics.rectangle("fill", x, y, width, height) end
	local stencil = love.graphics.newStencil(stencilfunc)
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawList or skins[defaultskin].DrawList
	local drawoverfunc = skin.DrawOverList or skins[defaultskin].DrawOverList
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
		
	for k, v in ipairs(children) do
		local col = loveframes.util.BoundingBox(x, v.x, y, v.y, width, v.width, height, v.height)
		if col then
			v:draw()
		end
	end
	
	love.graphics.setStencil()
	
	for k, v in ipairs(internals) do
		v:draw()
	end
	
	if not draw then
		drawoverfunc(self)
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
	
	local toplist = self:IsTopList()
	local hover = self.hover
	local vbar = self.vbar
	local hbar = self.hbar
	local scrollamount = self.mousewheelscrollamount
	local children = self.children
	local internals = self.internals
	
	if hover and button == "l" then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
	end
	
	if vbar or hbar then
		if toplist then
			local bar = self:GetScrollBar()
			local dtscrolling = self.dtscrolling
			if dtscrolling then
				local dt = love.timer.getDelta()
				if button == "wu" then
					bar:Scroll(-scrollamount * dt)
				elseif button == "wd" then
					bar:Scroll(scrollamount * dt)
				end
			else
				if button == "wu" then
					bar:Scroll(-scrollamount)
				elseif button == "wd" then
					bar:Scroll(scrollamount)
				end
			end
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
	- func: AddItem(object)
	- desc: adds an item to the object
--]]---------------------------------------------------------
function newobject:AddItem(object)
	
	if object.type == "frame" then
		return
	end

	local children = self.children
	
	-- remove the item object from its current parent and make its new parent the list object
	object:Remove()
	object.parent = self
	object.state = self.state
	
	-- insert the item object into the list object's children table
	table.insert(children, object)
	
	-- resize the list and redo its layout
	self:CalculateSize()
	self:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: RemoveItem(object or number)
	- desc: removes an item from the object
--]]---------------------------------------------------------
function newobject:RemoveItem(data)

	local dtype = type(data)
	
	if dtype == "number" then
		local children = self.children
		local item = children[data]
		if item then
			item:Remove()
		end
	else
		data:Remove()
	end
	
	self:CalculateSize()
	self:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: CalculateSize()
	- desc: calculates the size of the object's children
--]]---------------------------------------------------------
function newobject:CalculateSize()
	
	local numitems = #self.children
	local height = self.height
	local width = self.width
	local padding = self.padding
	local spacing = self.spacing
	local itemheight = self.padding
	local itemwidth = self.padding
	local display = self.display
	local vbar = self.vbar
	local hbar = self.hbar
	local internals = self.internals
	local children = self.children
	local horizontalstacking = self.horizontalstacking
	
	if display == "vertical" then
		if horizontalstacking then
			local curwidth = 0
			local maxwidth = width - padding * 2
			local prevheight = 0
			local scrollbar = self:GetScrollBar()
			if scrollbar then
				maxwidth = maxwidth - scrollbar.width
			end
			for k, v in ipairs(children) do
				if v.height > prevheight then
					prevheight = v.height
				end
				curwidth = curwidth + v.width + spacing
				if children[k + 1] then
					if curwidth + children[k + 1].width > maxwidth then
						curwidth = padding
						itemheight = itemheight + prevheight + spacing
						prevheight = 0
					end
				else
					itemheight = itemheight + prevheight + padding
				end
			end
			self.itemheight = itemheight
		else
			for k, v in ipairs(children) do
				itemheight = itemheight + v.height + spacing
			end
			self.itemheight = (itemheight - spacing) + padding
		end
		local itemheight = self.itemheight
		if itemheight > height then
			self.extraheight = itemheight - height
			if not vbar then
				local scrollbar = loveframes.objects["scrollbody"]:new(self, display)
				table.insert(internals, scrollbar)
				self.vbar = true
				self:GetScrollBar().autoscroll = self.autoscroll
			end
		else
			if vbar then
				local bar = internals[1]
				bar:Remove()
				self.vbar = false
				self.offsety = 0
			end
		end
	elseif display == "horizontal" then
		for k, v in ipairs(children) do
			itemwidth = itemwidth + v.width + spacing
		end
		self.itemwidth = (itemwidth - spacing) + padding
		local itemwidth = self.itemwidth
		if itemwidth > width then
			self.extrawidth = itemwidth - width
			if not hbar then
				local scrollbar = loveframes.objects["scrollbody"]:new(self, display)
				table.insert(internals, scrollbar)
				self.hbar = true
				self:GetScrollBar().autoscroll = self.autoscroll
			end
		else
			if hbar then
				local bar = internals[1]
				bar:Remove()
				self.hbar = false
				self.offsetx = 0
			end
		end
	end
	
end

--[[---------------------------------------------------------
	- func: RedoLayout()
	- desc: used to redo the layout of the object
--]]---------------------------------------------------------
function newobject:RedoLayout()
	
	local width = self.width
	local height = self.height
	local children = self.children
	local internals = self.internals
	local padding = self.padding
	local spacing = self.spacing
	local starty = padding
	local startx = padding
	local vbar = self.vbar
	local hbar = self.hbar
	local display = self.display
	local horizontalstacking = self.horizontalstacking
	local scrollbody, scrollbodywidth, scrollbodyheight
	
	if vbar or hbar then
		scrollbody = internals[1]
		scrollbodywidth = scrollbody.width
		scrollbodyheight = scrollbody.height
	end
	
	if #children > 0 then
		if display == "vertical" then
			if horizontalstacking then
				local curwidth = padding
				local curheight = padding
				local maxwidth = self.width - padding * 2
				local prevheight = 0
				local scrollbar = self:GetScrollBar()
				if scrollbar then
					maxwidth = maxwidth - scrollbar.width
				end
				for k, v in ipairs(children) do
					local itemheight = v.height
					v.lastheight = itemheight
					v.staticx = curwidth
					v.staticy = curheight
					if v.height > prevheight then
						prevheight = v.height
					end
					if children[k + 1] then
						curwidth = curwidth + v.width + spacing
						if curwidth + (children[k + 1].width) > maxwidth then
							curwidth = padding
							curheight = curheight + prevheight + spacing
							prevheight = 0
						end
					end
				end
			else
				for k, v in ipairs(children) do
					local itemwidth = v.width
					local itemheight = v.height
					local retainsize = v.retainsize
					v.staticx = padding
					v.staticy = starty
					v.lastheight = itemheight
					if vbar then
						if itemwidth + padding > (width - scrollbodywidth) then
							v:SetWidth((width - scrollbodywidth) - (padding * 2))
						end
						if not retainsize then
							v:SetWidth((width - scrollbodywidth) - (padding * 2))
						end
						scrollbody.staticx = width - scrollbodywidth
						scrollbody.height = height
					else
						if not retainsize then
							v:SetWidth(width - (padding * 2))
						end
					end
					starty = starty + itemheight
					starty = starty + spacing
				end
			end
		elseif display == "horizontal" then
			for k, v in ipairs(children) do
				local itemwidth = v.width
				local itemheight = v.height
				local retainsize = v.retainsize
				v.staticx = startx
				v.staticy = padding
				if hbar then
					if itemheight + padding > (height - scrollbodyheight) then
						v:SetHeight((height - scrollbodyheight) - (padding * 2))
					end
					if not retainsize then
						v:SetHeight((height - scrollbodyheight) - (padding * 2))
					end
					scrollbody.staticy = height - scrollbodyheight
					scrollbody.width = width
				else
					if not retainsize then
						v:SetHeight(height - (padding * 2))
					end
				end
				startx = startx + itemwidth
				startx = startx + spacing
			end
		end
	end
	
end

--[[---------------------------------------------------------
	- func: SetDisplayType(type)
	- desc: sets the object's display type
--]]---------------------------------------------------------
function newobject:SetDisplayType(type)

	local children = self.children
	local numchildren 	= #children
	
	self.display = type
	self.vbar = false
	self.hbar = false
	self.offsetx = 0
	self.offsety = 0
	self.internals = {}
	
	if numchildren > 0 then
		self:CalculateSize()
		self:RedoLayout()
	end

end

--[[---------------------------------------------------------
	- func: GetDisplayType()
	- desc: gets the object's display type
--]]---------------------------------------------------------
function newobject:GetDisplayType()

	return self.display
	
end

--[[---------------------------------------------------------
	- func: SetPadding(amount)
	- desc: sets the object's padding
--]]---------------------------------------------------------
function newobject:SetPadding(amount)

	local children = self.children
	local numchildren = #children
	
	self.padding = amount
	
	if numchildren > 0 then
		self:CalculateSize()
		self:RedoLayout()
	end
	
end

--[[---------------------------------------------------------
	- func: SetSpacing(amount)
	- desc: sets the object's spacing
--]]---------------------------------------------------------
function newobject:SetSpacing(amount)

	local children = self.children
	local numchildren = #children
	
	self.spacing = amount
	
	if numchildren > 0 then
		self:CalculateSize()
		self:RedoLayout()
	end
	
end

--[[---------------------------------------------------------
	- func: Clear()
	- desc: removes all of the object's children
--]]---------------------------------------------------------
function newobject:Clear()
	
	self.children = {}
	self:CalculateSize()
	self:RedoLayout()

end

--[[---------------------------------------------------------
	- func: SetWidth(width)
	- desc: sets the object's width
--]]---------------------------------------------------------
function newobject:SetWidth(width)

	self.width = width
	self:CalculateSize()
	self:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: SetHeight(height)
	- desc: sets the object's height
--]]---------------------------------------------------------
function newobject:SetHeight(height)

	self.height = height
	self:CalculateSize()
	self:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: GetSize()
	- desc: gets the object's size
--]]---------------------------------------------------------
function newobject:SetSize(width, height)

	self.width = width
	self.height = height
	self:CalculateSize()
	self:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: GetScrollBar()
	- desc: gets the object's scroll bar
--]]---------------------------------------------------------
function newobject:GetScrollBar()

	local vbar = self.vbar
	local hbar = self.hbar
	local internals  = self.internals
	
	if vbar or hbar then
		local scrollbody = internals[1]
		local scrollarea = scrollbody.internals[1]
		local scrollbar = scrollarea.internals[1]
		return scrollbar
	else
		return false
	end
	
end

--[[---------------------------------------------------------
	- func: SetAutoScroll(bool)
	- desc: sets whether or not the list's scrollbar should
			auto scroll to the bottom when a new object is
			added to the list
--]]---------------------------------------------------------
function newobject:SetAutoScroll(bool)

	local scrollbar = self:GetScrollBar()
	
	self.autoscroll = bool
	
	if scrollbar then
		scrollbar.autoscroll = bool
	end
	
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
	- func: EnableHorizontalStacking(bool)
	- desc: enables or disables horizontal stacking
--]]---------------------------------------------------------
function newobject:EnableHorizontalStacking(bool)

	local children = self.children
	local numchildren = #children
	
	self.horizontalstacking = bool
	
	if numchildren > 0 then
		self:CalculateSize()
		self:RedoLayout()
	end
	
end

--[[---------------------------------------------------------
	- func: GetHorizontalStacking()
	- desc: gets whether or not the object allows horizontal
			stacking
--]]---------------------------------------------------------
function newobject:GetHorizontalStacking()

	return self.horizontalstacking
	
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