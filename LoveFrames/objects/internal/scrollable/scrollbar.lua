--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- scrollbar class
local newobject = loveframes.NewObject("scrollbar", "loveframes_object_scrollbar", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(parent, bartype)

	self.type = "scrollbar"
	self.bartype = bartype
	self.parent = parent
	self.x = 0
	self.y = 0
	self.staticx = 0
	self.staticy = 0
	self.maxx = 0
	self.maxy = 0
	self.clickx = 0
	self.clicky = 0
	self.starty = 0
	self.lastwidth = 0
	self.lastheight = 0
	self.lastx = 0
	self.lasty = 0
	self.internal = true
	self.hover = false
	self.dragging = false
	self.autoscroll = false
	self.internal = true
	
	if self.bartype == "vertical" then
		self.width = self.parent.width
		self.height = 5
	elseif self.bartype == "horizontal" then
		self.width = 5
		self.height = self.parent.height
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
	
	self:CheckHover()
	
	local x, y     = love.mouse.getPosition()
	local bartype  = self.bartype
	local cols     = {}
	local basecols = {}
	local dragging = self.dragging
	
	if bartype == "vertical" then
		self.width 		= self.parent.width
	elseif bartype == "horizontal" then
		self.height 	= self.parent.height
	end
	
	if bartype == "vertical" then
		local parent = self.parent
		local listo = parent.parent.parent
		local height = parent.height * (listo.height/listo.itemheight)
		local update = self.Update
		if height < 20 then
			self.height = 20
		else
			self.height = height
		end
		self.maxy = parent.y + (parent.height - self.height)
		self.x = parent.x + parent.width - self.width
		self.y = parent.y + self.staticy
		if dragging then
			if self.staticy ~= self.lasty then
				if listo.OnScroll then
					listo.OnScroll(listo)
				end
				self.lasty = self.staticy
			end
			self.staticy = self.starty + (y - self.clicky)
		end
		local space = (self.maxy - parent.y)
		local remaining = (0 + self.staticy)
		local percent = remaining/space
		local extra = listo.extraheight * percent
		local autoscroll = self.autoscroll
		local lastheight = self.lastheight
		listo.offsety = 0 + extra
		if self.staticy > space then
			self.staticy = space
			listo.offsety = listo.extraheight
		end
		if self.staticy < 0 then
			self.staticy = 0
			listo.offsety = 0
		end
		if autoscroll then
			if listo.itemheight > lastheight then
				local type = listo.type
				self.lastheight = listo.itemheight
				if type == "textinput" then
					local indicatory = listo.indicatory
					local font = listo.font
					local theight = font:getHeight("a")
					local y = listo.y
					local height = listo.height
					local linecount = #listo.lines
					local parentheight = self.parent.height
					if (indicatory + theight) > (y + height) then
						self:Scroll(parentheight/linecount)
					end
				else
					local maxy = self.maxy
					self:Scroll(maxy)
				end
			end
		end
	elseif bartype == "horizontal" then
		local parent = self.parent
		local listo = self.parent.parent.parent
		local width = self.parent.width * (listo.width/listo.itemwidth)
		if width < 20 then
			self.width = 20
		else
			self.width = width
		end
		self.maxx = parent.x + (parent.width) - self.width
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
		if dragging then
			if self.staticx ~= self.lastx then
				if listo.OnScroll then
					listo.OnScroll(listo)
				end
				self.lastx = self.staticx
			end
			self.staticx = self.startx + (x - self.clickx)
		end
		local space      = (self.maxx - parent.x)
		local remaining  = (0 + self.staticx)
		local percent    = remaining/space
		local extra      = listo.extrawidth * percent
		local autoscroll = self.autoscroll
		local lastwidth  = self.lastwidth
		listo.offsetx = 0 + extra
		if self.staticx > space then
			self.staticx = space
			listo.offsetx = listo.extrawidth
		end
					
		if self.staticx < 0 then
			self.staticx = 0
			listo.offsetx = 0
		end
		if autoscroll then
			if listo.itemwidth > lastwidth then
				self.lastwidth = listo.itemwidth
				self:Scroll(self.maxx)
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

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawScrollBar or skins[defaultskin].DrawScrollBar
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

	local visible = self.visible
	local hover = self.hover
	
	if not visible then
		return
	end
	
	if not hover then
		return
	end
	
	local baseparent = self:GetBaseParent()
	
	if baseparent.type == "frame" then
		baseparent:MakeTop()
	end
	
	local dragging = self.dragging
	
	if not dragging then
		if button == "l" then
			self.starty = self.staticy
			self.startx = self.staticx
			self.clickx = x
			self.clicky = y
			self.dragging = true
			loveframes.hoverobject = self
		end
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
	
	if self.dragging then
		self.dragging = false
	end

end

--[[---------------------------------------------------------
	- func: SetMaxX(x)
	- desc: sets the object's max x position
--]]---------------------------------------------------------
function newobject:SetMaxX(x)

	self.maxx = x
	
end

--[[---------------------------------------------------------
	- func: SetMaxY(y)
	- desc: sets the object's max y position
--]]---------------------------------------------------------
function newobject:SetMaxY(y)

	self.maxy = y
	
end

--[[---------------------------------------------------------
	- func: Scroll(amount)
	- desc: scrolls the object
--]]---------------------------------------------------------
function newobject:Scroll(amount)

	local bartype = self.bartype
	local listo = self.parent.parent.parent
	local onscroll = listo.OnScroll
	
	if bartype == "vertical" then
		local newy = (self.y + amount)
		if newy > self.maxy then
			self.staticy = self.maxy - self.parent.y
		elseif newy < self.parent.y then
			self.staticy = 0
		else
			self.staticy = self.staticy + amount
		end
	elseif bartype == "horizontal" then
		local newx = (self.x + amount)
		if newx > self.maxx then
			self.staticx = self.maxx - self.parent.x
		elseif newx < self.parent.x then
			self.staticx = 0
		else
			self.staticx = self.staticx + amount
		end
	end
	
	if onscroll then
		onscroll(listo)
	end
	
end

--[[---------------------------------------------------------
	- func: IsDragging()
	- desc: gets whether the object is being dragged or not
--]]---------------------------------------------------------
function newobject:IsDragging()

	return self.dragging
	
end

--[[---------------------------------------------------------
	- func: GetBarType()
	- desc: gets the object's bartype
--]]---------------------------------------------------------
function newobject:GetBarType()

	return self.bartype
	
end