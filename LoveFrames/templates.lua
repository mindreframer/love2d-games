--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- templates library
loveframes.templates = {}

-- available templates
loveframes.templates.available = {}

-- objects
loveframes.templates.objects = {}

--[[---------------------------------------------------------
	- func: AddProperty(templatename, property, value)
	- desc: creates a property within the specified template
			and assigns it to the specified object
--]]---------------------------------------------------------
function loveframes.templates.AddProperty(templatename, object, property, value)

	-- display an error if name is nil or false
	if not templatename then
		loveframes.util.Error("Could not create property: No template name given.")
	end
	
	-- display an error if property is nil or false
	if not property then
		loveframes.util.Error("Could not create property: No property name given.")
	end
	
	local templatename = tostring(templatename)
	local property = tostring(property)
	local templates = loveframes.templates.available
	local template = templates[templatename]
	
	-- display an error message if the property is not a string
	if type(property) ~= "string" then
		loveframes.util.Error("Could not create property: Property names must be strings.")
	end
	
	-- display an error message if the property is an empty string
	if property == "" then
		loveframes.util.Error("Could not create property: Property names must not be empty.")
	end
	
	-- display an error message if the template is invalid
	if not template then
		loveframes.util.Error("Could not add property '" ..property.. "' to template '" ..templatename.. "': Invalid template.")
	end
	
	local properties = template.properties
	local object = properties[object]
	
	if not object then
		loveframes.util.Error("Could not add property '" ..property.. "' to template '" ..templatename.. "': Invalid object.")
	end
	
	-- create the property within the template
	object[property] = value
	
end

--[[---------------------------------------------------------
	- func: Register(template)
	- desc: registers a template
--]]---------------------------------------------------------
function loveframes.templates.Register(template)

	-- display and error message if template is nil or false
	if not template then
		loveframes.util.Error("Could not register template: Missing template argument.")
	end
	
	-- display an error message if template is not a table
	if type(template) ~= "table" then
		loveframes.util.Error("Could not register template: Template argument must be a table.")
	end
	
	local templates = loveframes.templates.available
	local registeredobjects = loveframes.templates.objects
	local name = template.name
	local properties = template.properties
	local objects = loveframes.objects
	local base = objects["base"]
	local found = false
	local foundall = false
	
	-- display an error message if a template name was not given
	if not name then
		loveframes.util.Error("Could not register template: No template name given.")
	end
	
	if name == "Base" then
		base:include(template.properties["*"])
	end
	
	-- insert the template into the available templates table
	templates[name] = template
	
end

--[[---------------------------------------------------------
	- func: Get(name)
	- desc: gets a template
--]]---------------------------------------------------------
function loveframes.templates.Get(name)

	-- display and error if name is nil or false
	if not name then
		loveframes.util.Error("Could not create property: No template name given.")
	end
	
	local name = tostring(name)
	local templates = loveframes.templates.available
	local template = templates[name]
	
	-- display an error message if the template is invalid
	if not template then
		loveframes.util.Error("Could not get template: Invalid template.")
	end

	-- return the template
	return template
	
end

--[[---------------------------------------------------------
	- func: GetAvailable()
	- desc: gets all available templates
--]]---------------------------------------------------------
function loveframes.templates.GetAvailable()

	-- available templates
	local templates = loveframes.templates.available
	
	-- return the templates
	return templates
	
end

--[[---------------------------------------------------------
	- func: loveframes.templates.ApplyToObject(object)
	- desc: applies the properties of registered templates 
			to an object
--]]---------------------------------------------------------
function loveframes.templates.ApplyToObject(object)

	local templates = loveframes.templates.GetAvailable()
	local type = object.type
	
	-- loop through all available templates
	for k, v in pairs(templates) do
		-- make sure the base template doesn't get applied more than once
		if k ~= "Base" then
			local properties = v.properties
			local hasall = loveframes.util.TableHasKey(properties, "*")
			local hasobject = false
			if not hasall then
				hasobject = loveframes.util.TableHasKey(properties, type)
			end
			if hasall then
				for k, v in pairs(properties["*"]) do
					object[k] = v
				end
			elseif hasobject then
				-- apply the template properties to the object
				for k, v in pairs(properties[type]) do
					object[k] = v
				end
			end
		end
	end
	
end