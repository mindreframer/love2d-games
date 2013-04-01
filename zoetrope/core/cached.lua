-- Class: Cached
-- This helps you re-use assets in your app instead of creating extraneous
-- copies of them. It also hides Love-related calls so that your code is
-- more portable.
--
-- If you're using a class built into Zoetrope, you do not need to use
-- this class directly. They take care of setting things up for you
-- appropriately. However, if you're rolling your own, you'll want to use
-- this to save memory.
--
-- This class is not meant to be created directly. Instead, call
-- methods on Cached directly, e.g. Cached:sound(), Cached:image(), and so on.
--
-- Extends:
--		<Class>

Cached = Class:extend
{
	-- Property: defaultGlyphs
	-- The default character order of a bitmap font, if none is specified
	-- in a <font> call.
	defaultGlyphs = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`' ..
					'abcdefghijklmnopqrstuvwxyz{|}~',

	-- private property: library
	-- a table to store already-instantiated assets
	_library = { image = {}, text = {}, sound = {}, font = {}, binds = {}, },

	-- Method: image
	-- Returns a cached image asset.
	--
	-- Arguments:
	--		path - pathname to image file
	--
	-- Returns:
	--		Love image object

	image = function (self, path)
		assert(type(path) == 'string', 'path must be a string')

		if not self._library.image[path] then
			self._library.image[path] = love.graphics.newImage(path)
		end

		return self._library.image[path]
	end,

	-- Method: text
	-- Returns a cached text asset.
	--
	-- Arguments:
	--		path - pathname to text file
	--
	-- Returns:
	--		string

	text = function (self, path)
		assert(type(path) == 'string', 'path must be a string')

		if not self._library.text[path] then
			self._library.text[path] = love.filesystem.read(path)
		end

		return self._library.text[path]
	end,

	-- Method: sound
	-- Returns a cached sound asset.
	--
	-- Arguments:
	--		path - pathname to sound file
	--		length - either 'short' or 'long'. *It's very important to pass
	--				 the correct option here.* A short sound is loaded entirely
	--				 into memory, while a long one is streamed from disk. If you
	--				 mismatch, you'll either hear a delay in the sound (short sounds
	--				 played from disk) or your app will freeze (long sounds played from
	--				 memory).
	-- 
	-- Returns:
	--		Either a Love SoundData object (for short sounds) or a
	--		Love Decoder object (for long sounds). Either can be used to
	--		create a Love Source object.
	--
	-- See Also:
	--		<playSound>, <sound>

	sound = function (self, path, length)
		assert(type(path) == 'string', 'path must be a string')

		if not self._library.sound[path] then
			if length == 'short' then
				self._library.sound[path] = love.sound.newSoundData(path)
			elseif length == 'long' then
				self._library.sound[path] = love.sound.newDecoder(path)
			else
				error('length must be either "short" or "long"')
			end
		end

		return self._library.sound[path]
	end,

	-- Method: font
	-- Returns a cached font asset.
	--
	-- Arguments:
	-- Can be:
	--		* A single number. This uses Love's default outline font at that point size.
	--		* A single string. This uses a bitmap font given by this pathname, and assumes that
	--		  the characters come in
	--		  <printable ASCII order at https://en.wikipedia.org/wiki/ASCII#ASCII_printable_characters>.
	--		* A string, then a number. This uses an outline font whose pathname is the first argument,
	--		  at the point size given in the second argument.
	--		* Two strings. The first is treated as a pathname to a bitmap font, the second
	--		  as the character order in the font.
	--
	-- Returns:
	--		Love font object

	font = function (self, ...)
		local arg = {...}
		local libKey = arg[1]

		if #arg > 1 then libKey = libKey .. arg[2] end

		if not self._library.font[libKey] then
			local font, image

			if #arg == 1 then
				if type(arg[1]) == 'number' then
					font = love.graphics.newFont(arg[1])
				elseif type(arg[1]) == 'string' then
					image = Cached:image(arg[1])
					font = love.graphics.newImageFont(image, self.defaultGlyphs)
				else
					error("don't understand single argument: " .. arg[1])
				end
			elseif #arg == 2 then
				if type(arg[2]) == 'number' then
					font = love.graphics.newFont(arg[1], arg[2])
				elseif type(arg[2]) == 'string' then
					image = Cached:image(arg[1])
					font = love.graphics.newImageFont(image, arg[2])
				else
					error("don't understand arguments: " .. arg[1] .. ", " .. arg[2])
				end
			else
				error("too many arguments; should be at most two")
			end

			self._library.font[libKey] = font
		end

		return self._library.font[libKey]
	end,

	-- Function: bind
	-- Returns a function that's bound to an object so it can be later called with
	-- the correct context. This can be abbreviated as just bind().
	--
	-- Arguments:
	--		obj - object to use as function owner
	--		func - either a string name of a property of obj, or a free-standing
	--			   function.
	--		... - any number of extra arguments 

	bind = function (self, obj, func, ...)
		local arg = {...}

		-- look for previous bind
		
		for key, value in pairs(self._library.binds) do
			if key[1] == func and key[2] == obj then
				local match = true

				for i = 1, #arg do
					if key[i + 2] ~= arg[i] then
						match = false
						break
					end
				end

				if match then
					print('found existing bind for ', obj, func, arg)
					return value
				end
			end
		end

		-- have to create a new one
		-- note that we have to create a compound key, hence the loop above

		local result = function()
			if type(func) == 'string' then
				return obj[func](obj, unpack(arg))
			else
				return func(obj, unpack(arg))
			end
		end
	
		self._library.binds[{func, obj, arg}] = result
		return result
	end
}
