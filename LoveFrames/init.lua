--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- central library table
loveframes = {}

-- library info
loveframes.info = {}
loveframes.info.author = "Kenny Shields"
loveframes.info.version = "0.9.5.6"
loveframes.info.stage = "Alpha"

-- library configurations
loveframes.config = {}
loveframes.config["DIRECTORY"] = ""
loveframes.config["DEFAULTSKIN"] = "Blue"
loveframes.config["ACTIVESKIN"] = "Blue"
loveframes.config["INDEXSKINIMAGES"] = true
loveframes.config["DEBUG"] = false

-- misc library vars
loveframes.state = "none"
loveframes.drawcount = 0
loveframes.hoverobject = false
loveframes.modalobject = false
loveframes.inputobject = false
loveframes.basicfont = love.graphics.newFont(12)
loveframes.basicfontsmall = love.graphics.newFont(10)
loveframes.objects = {}

--[[---------------------------------------------------------
	- func: load()
	- desc: loads the library
--]]---------------------------------------------------------
function loveframes.load()
	
	-- install directory of the library
	local dir = loveframes.config["DIRECTORY"]
	
	-- require the internal base libraries
	require(dir .. ".third-party.middleclass")
	require(dir .. ".util")
	require(dir .. ".skins")
	require(dir .. ".templates")
	require(dir .. ".debug")
	
	-- replace all "." with "/" in the directory setting
	dir = dir:gsub("%.", "/")
	loveframes.config["DIRECTORY"] = dir
	
	-- create a list of gui objects, skins and templates
	local objects = loveframes.util.GetDirectoryContents(dir .. "/objects")
	local skins = loveframes.util.GetDirectoryContents(dir .. "/skins")
	local templates = loveframes.util.GetDirectoryContents(dir .. "/templates")
	
	-- loop through a list of all gui objects and require them
	for k, v in ipairs(objects) do
		if v.extension == "lua" then
			require(v.requirepath)
		end
	end
	
	-- loop through a list of all gui templates and require them
	for k, v in ipairs(templates) do
		if v.extension == "lua" then
			require(v.requirepath)
		end
	end
	
	-- loop through a list of all gui skins and require them
	for k, v in ipairs(skins) do
		if v.extension == "lua" then
			require(v.requirepath)
		end
	end
	
	-- create the base gui object
	local base = loveframes.objects["base"]
	loveframes.base = base:new()
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates all library objects
--]]---------------------------------------------------------
function loveframes.update(dt)

	local base = loveframes.base
	base:update(dt)

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws all library objects
--]]---------------------------------------------------------
function loveframes.draw()

	local base = loveframes.base
	local r, g, b, a = love.graphics.getColor()
	local font = love.graphics.getFont()
	
	base:draw()
	
	loveframes.drawcount = 0
	loveframes.debug.draw()
	
	love.graphics.setColor(r, g, b, a)
	
	if font then
		love.graphics.setFont(font)
	end
	
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function loveframes.mousepressed(x, y, button)

	local base = loveframes.base
	base:mousepressed(x, y, button)
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function loveframes.mousereleased(x, y, button)

	local base = loveframes.base
	base:mousereleased(x, y, button)
	
	-- reset the hover object
	if button == "l" then
		loveframes.hoverobject = false
		loveframes.selectedobject = false
	end
	
end

--[[---------------------------------------------------------
	- func: keypressed(key)
	- desc: called when the player presses a key
--]]---------------------------------------------------------
function loveframes.keypressed(key, unicode)

	local base = loveframes.base
	base:keypressed(key, unicode)
	
end

--[[---------------------------------------------------------
	- func: keyreleased(key)
	- desc: called when the player releases a key
--]]---------------------------------------------------------
function loveframes.keyreleased(key)

	local base = loveframes.base
	base:keyreleased(key)
	
end

--[[---------------------------------------------------------
	- func: Create(type, parent)
	- desc: creates a new object or multiple new objects
			(based on the method used) and returns said
			object or objects for further manipulation
--]]---------------------------------------------------------
function loveframes.Create(data, parent)
	
	if type(data) == "string" then
	
		local objects = loveframes.objects
		local object = objects[data]
		
		if not object then
			loveframes.util.Error("Error creating object: Invalid object '" ..data.. "'.")
		end
		
		-- create the object
		local newobject = object:new()
		
		-- apply template properties to the object
		loveframes.templates.ApplyToObject(newobject)
		
		-- if the object is a tooltip, return it and go no further
		if data == "tooltip" then
			return newobject
		end
		
		-- remove the object if it is an internal
		if newobject.internal then
			newobject:Remove()
			return
		end
		
		-- parent the new object by default to the base gui object
		newobject.parent = loveframes.base
		table.insert(loveframes.base.children, newobject)
		
		-- if the parent argument is not nil, make that argument the object's new parent
		if parent then
			newobject:SetParent(parent)
		end
		
		-- return the object for further manipulation
		return newobject
		
	elseif type(data) == "table" then

		-- table for creation of multiple objects
		local objects = {}
		
		-- this function reads a table that contains a layout of object properties and then
		-- creates objects based on those properties
		local function CreateObjects(t, o, c)
			local child = c or false
			for k, v in pairs(t) do
				-- current default object
				local object = _G[v.type]:new()
				-- indert the object into the table of objects being created
				table.insert(objects, object)
				-- parent the new object by default to the base gui object
				object.parent = loveframes.base
				table.insert(loveframes.base.children, object)
				if o then
					object:SetParent(o)
				end
				-- loop through the current layout table and assign the properties found
				-- to the current object
				for i, j in pairs(v) do
					if i ~= "children" and i ~= "func" then
						if child == true then
							if i == "x" then
								object["staticx"] = j
							elseif i == "y" then
								object["staticy"] = j
							else
								object[i] = j
							end
						else
							object[i] = j
						end
					elseif i == "children" then
						CreateObjects(j, object, true)
					end
				end
				if v.func then
					v.func(object)
				end
			end
		end
		
		-- create the objects
		CreateObjects(data)
		
		return objects
		
	end
	
end

--[[---------------------------------------------------------
	- func: NewObject(id, name, inherit_from_base)
	- desc: creates a new object
--]]---------------------------------------------------------
function loveframes.NewObject(id, name, inherit_from_base)
	
	local objects = loveframes.objects
	local object = false
	
	if inherit_from_base then
		local base = objects["base"]
		object = class(name, base)
		objects[id] = object
	else
		object = class(name)
		objects[id] = object
	end
	
	return object
	
end

--[[---------------------------------------------------------
	- func: SetState(name)
	- desc: sets the current state
--]]---------------------------------------------------------
function loveframes.SetState(name)

	loveframes.state = name
	loveframes.base.state = name
	
end

--[[---------------------------------------------------------
	- func: GetState()
	- desc: gets the current state
--]]---------------------------------------------------------
function loveframes.GetState()

	return loveframes.state
	
end

-- load the library
loveframes.load()