--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- util library
loveframes.util = {}

--[[---------------------------------------------------------
	- func: SetActiveSkin(name)
	- desc: sets the active skin
--]]---------------------------------------------------------
function loveframes.util.SetActiveSkin(name)
	
	loveframes.config["ACTIVESKIN"] = name

end

--[[---------------------------------------------------------
	- func: GetActiveSkin()
	- desc: gets the active skin
--]]---------------------------------------------------------
function loveframes.util.GetActiveSkin()
	
	local index = loveframes.config["ACTIVESKIN"]
	local skin = loveframes.skins.available[index]
	
	return skin

end

--[[---------------------------------------------------------
	- func: BoundingBox(x1, x2, y1, y2, w1, w2, h1, h2)
	- desc: checks for a collision between two boxes
	- note: i take no credit for this function
--]]---------------------------------------------------------
function loveframes.util.BoundingBox(x1, x2, y1, y2, w1, w2, h1, h2)

	if x1 > x2 + w2 - 1 or y1 > y2 + h2 - 1 or x2 > x1 + w1 - 1 or y2 > y1 + h1 - 1 then
		return false
	else
		return true
	end
	
end

--[[---------------------------------------------------------
	- func: loveframes.util.GetCollisions(object, table)
	- desc: gets all objects colliding with the mouse
--]]---------------------------------------------------------
function loveframes.util.GetCollisions(object, t)

	local x, y = love.mouse.getPosition()
	local object = object or loveframes.base
	local t = t or {}
	
	-- add the current object if colliding
	if object.visible == true then
		local col = loveframes.util.BoundingBox(x, object.x, y, object.y, 1, object.width, 1, object.height)
		if col == true and object.collide ~= false then
			if object.clickbounds then
				local clickcol = loveframes.util.BoundingBox(x, object.clickbounds.x, y, object.clickbounds.y, 1, object.clickbounds.width, 1, object.clickbounds.height)
				if clickcol then
					table.insert(t, object)
				end
			else
				table.insert(t, object)
			end
		end
	end
	
	-- check for children
	if object.children then
		for k, v in ipairs(object.children) do
			if v.visible then
				loveframes.util.GetCollisions(v, t)
			end
		end
	end
	
	-- check for internals
	if object.internals then
		for k, v in ipairs(object.internals) do
			if v.visible and v.type ~= "tooltip" then
				loveframes.util.GetCollisions(v, t)
			end
		end
	end
	
	return t

end

--[[---------------------------------------------------------
	- func: loveframes.util.GetAllObjects(object, table)
	- desc: gets all active objects
--]]---------------------------------------------------------
function loveframes.util.GetAllObjects(object, t)
	
	local object = object or loveframes.base
	local internals = object.internals
	local children = object.children
	local t = t or {}
	
	table.insert(t, object)
	
	if internals then
		for k, v in ipairs(internals) do
			loveframes.util.GetAllObjects(v, t)
		end
	end
	
	if children then
		for k, v in ipairs(children) do
			loveframes.util.GetAllObjects(v, t)
		end
	end
	
	return t
	
end

--[[---------------------------------------------------------
	- func: GetDirectoryContents(directory, table)
	- desc: gets the contents of a directory and all of
			its subdirectories
--]]---------------------------------------------------------
function loveframes.util.GetDirectoryContents(dir, t)

	local dir = dir
	local t = t or {}
	local files = love.filesystem.enumerate(dir)
	local dirs = {}
	
	for k, v in ipairs(files) do
		local isdir = love.filesystem.isDirectory(dir.. "/" ..v)
		if isdir == true then
			table.insert(dirs, dir.. "/" ..v)
		else
			local parts = loveframes.util.SplitString(v, "([.])")
			local extension = parts[#parts]
			parts[#parts] = nil
			local name = table.concat(parts)
			table.insert(t, {path = dir, fullpath = dir.. "/" ..v, requirepath = dir .. "." ..name, name = name, extension = extension})
		end
	end
	
	if #dirs > 0 then
		for k, v in ipairs(dirs) do
			t = loveframes.util.GetDirectoryContents(v, t)
		end
	end
	
	return t
	
end


--[[---------------------------------------------------------
	- func: Round(num, idp)
	- desc: rounds a number based on the decimal limit
	- note: i take no credit for this function
--]]---------------------------------------------------------
function loveframes.util.Round(num, idp)

	local mult = 10^(idp or 0)
	
    if num >= 0 then 
		return math.floor(num * mult + 0.5) / mult
    else 
		return math.ceil(num * mult - 0.5) / mult 
	end
	
end

--[[---------------------------------------------------------
	- func: SplitString(string, pattern)
	- desc: splits a string into a table based on a given pattern
	- note: i take no credit for this function
--]]---------------------------------------------------------
function loveframes.util.SplitString(str, pat)

	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	
	if pat == " " then
		local fpat = "(.-)" .. pat
		local last_end = 1
		local s, e, cap = str:find(fpat, 1)
		while s do
			if s ~= #str then
				cap = cap .. " "
			end
			if s ~= 1 or cap ~= "" then
				table.insert(t,cap)
			end
			last_end = e+1
			s, e, cap = str:find(fpat, last_end)
		end
		if last_end <= #str then
			cap = str:sub(last_end)
			table.insert(t, cap)
		end
	else
		local fpat = "(.-)" .. pat
		local last_end = 1
		local s, e, cap = str:find(fpat, 1)
		while s do
			if s ~= 1 or cap ~= "" then
				table.insert(t,cap)
			end
			last_end = e+1
			s, e, cap = str:find(fpat, last_end)
		end
		if last_end <= #str then
			cap = str:sub(last_end)
			table.insert(t, cap)
		end
	end
	
	return t
	
end

--[[---------------------------------------------------------
	- func: RemoveAll()
	- desc: removes all gui elements
--]]---------------------------------------------------------
function loveframes.util.RemoveAll()

	loveframes.base.children = {}
	loveframes.base.internals = {}
	
end

--[[---------------------------------------------------------
	- func: loveframes.util.TableHasKey(table, key)
	- desc: checks to see if a table has a specific key
--]]---------------------------------------------------------
function loveframes.util.TableHasKey(table, key)

	local haskey = false
	
	for k, v in pairs(table) do
		if k == key then
			haskey = true
			break
		end
	end
	
	return haskey
	
end

--[[---------------------------------------------------------
	- func: loveframes.util.Error(message)
	- desc: displays a formatted error message
--]]---------------------------------------------------------
function loveframes.util.Error(message)

	error("[Love Frames] " ..message)
	
end