-- Section: Globals

-- Variable: the
-- This is a repository table for the current app, view, keys, and mouse.
-- You can use this for other objects that are useful to track. This should
-- be considered read-only; references here are for convenience and changing
-- things here will have no effect.
the = {}

-- Constant: STRICT
-- If set to true, then Zoetrope will do some extra checking for obvious
-- errors at the expense of some performance. Some of these checks will
-- throw errors, while others will simply print a warning to the console.
-- If you are going to use this, make sure to do so before your project's
-- require 'zoetrope' statement.

-- Constant: DEBUG
-- If set to true, Zoetrope's debug console will be enabled. If you are
-- going to use this, make sure to do so before your project's require
-- 'zoetrope' statement.

-- Constant: NEARLY_ZERO
-- Any number less than this is considered 0 by Zoetrope.
NEARLY_ZERO = 0.0001

-- Constant: UP
-- Directional constant corresponding to up.
UP = 'up'

-- Constant: DOWN
-- Directional constant corresponding to down.
DOWN = 'down'

-- Constant: LEFT
-- Directional constant corresponding to left.
LEFT = 'left'

-- Constant: RIGHT
-- Directional constant corresponding to right.
RIGHT = 'right'


-- Function: trim
-- trim() implementation for strings via http://lua-users.org/wiki/stringtrim
-- 
-- Arguments:
-- 		source - source string
--
-- Returns:
-- 		string trimmed of leading and trailing whitespace

function trim (source)
	return source:gsub("^%s*(.-)%s*$", "%1")
end

-- Function: split
-- split() implementation for strings via http://lua-users.org/wiki/splitjoin
--
-- Arguments:
--		source - source string
--		pattern - Lua pattern to split on, see http://www.lua.org/pil/20.1.html
--
-- Returns:
-- 		table of split strings	

function split (source, pattern)
	assert(type(source) == 'string', 'source must be a string')
	assert(type(pattern) == 'string', 'pattern must be a string')
	
	local result = {}
	local searchStart = 1
	local splitStart, splitEnd = string.find(source, pattern, searchStart)
	
	while splitStart do
		table.insert(result, string.sub(source, searchStart, splitStart - 1))
		searchStart = splitEnd + 1
		splitStart, splitEnd = string.find(source, pattern, searchStart)
	end
	
	table.insert(result, string.sub(source, searchStart))
	return result
end

-- Function: tovalue
-- Coerces, if possible, a string to a boolean or number value.
-- If the string cannot be coerced to either of these types, this
-- returns the same string passed.
--
-- Arguments:
--		source - string to coerce
--
-- Returns:
--		number, boolean, or string

function tovalue (source)
	if source == 'true' then return true end
	if source == 'false' then return false end

	return tonumber(source) or source
end

-- Function: sound
-- Loads a sound but does not play it. It's important to use the hint property
-- appropriately; if set incorrectly, it can cause sound playback to stutter or lag.
--
-- Arguments:
--		path - string pathname to sound
--		hint - either 'short' or 'long', depending on length of sound; default 'short'
--
-- Returns:
--		LOVE sound source, see https://love2d.org/wiki/Source

function sound (path, hint)
	return love.audio.newSource(Cached:sound(path, hint or 'short'))
end

-- Function: playSound
-- Plays a sound once. This is the easiest way to play a sound. It's important
-- to use the hint property appropriately; if set incorrectly, it can cause sound
-- playback to stutter or lag.
--
-- Arguments:
--		path - string pathname to sound
--		volume - volume to play at, from 0 to 1; default 1
--		hint - either 'short' or 'long', depending on length of sound; default 'short'
--
-- Returns:
--		LOVE sound source, see https://love2d.org/wiki/Source

function playSound (path, volume, hint)
	volume = volume or 1
	local source = sound(path, hint)
	source:setVolume(volume)
	source:play()
	return source
end

-- Function: searchTable
-- Returns the index of a value in a table. If the value
-- does not exist in the table, this returns nil.
--
-- Arguments:
--		table - table to search
--		search - value to search for
--
-- Returns:
--		integer index or nil

function searchTable (table, search)
	for i, value in ipairs(table) do
		if value == search then return i end
	end

	return nil
end

-- Function: copyTable
-- Returns a superficial copy of a table. If it contains a 
-- reference to another table in one of its properties, that
-- reference will be copied shallowly. 
--
-- Arguments:
-- 		source - source table
--
-- Returns:
-- 		new table

function copyTable (source)
	assert(type(source) == 'table', "asked to copy a non-table")

	local result = {}
	setmetatable(result, getmetatable(source))
	
	for key, value in pairs(source) do
		result[key] = value
	end
	
	return result
end

-- Function: shuffleTable
-- Shuffles the contents of a table in place.
-- via http://www.gammon.com.au/forum/?id=9908
--
-- Arguments:
--		table - table to shuffle
--
-- Returns:
--		table passed

function shuffleTable (table)
  local n = #table
 
  while n >= 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    table[n], table[k] = table[k], table[n]
    n = n - 1
  end
 
  return table
end

-- Function: dump
-- Returns a string representation of a variable in a way
-- that can be reconstituted via loadstring(). Yes, this
-- is basically a serialization function, but that's so much
-- to type :) This ignores any userdata, functions, or circular
-- references.
-- via http://www.lua.org/pil/12.1.2.html
--
-- Arguments:
--		source - variable to describe
--		ignore - a table of references to ignore (to avoid cycles),
--				 defaults to empty table. This uses the references as keys,
--				 *not* as values, to speed up lookup.
--
-- Returns:
--		string description

function dump (source, ignore)
	ignore = ignore or { source = true }
	local sourceType = type(source)
	
	if sourceType == 'table' then
		local result = '{ '

		for key, value in pairs(source) do
			if not ignore[value] then
				local dumpValue = dump(value, ignore)

				if dumpValue ~= '' then
					result = result .. '["' .. key .. '"] = ' .. dumpValue .. ', '
				end

				if type(value) == 'table' then
					ignore[value] = true
				end
			end
		end

		if result ~= '{ ' then
			return string.sub(result, 1, -3) .. ' }'
		else
			return '{}'
		end
	elseif sourceType == 'string' then
		return string.format('%q', source)
	elseif sourceType ~= 'userdata' and sourceType ~= 'function' then
		return tostring(source)
	else
		return ''
	end
end

bind = function (...)
	return Cached:bind(...)
end
