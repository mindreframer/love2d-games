-- Class: Storage
-- Allows your app to save data between sessions -- high scores or game
-- progress, for example. A single storage instance corresponds to a
-- file on disk. If you'd like to maintain individual files (e.g. so
-- a user can email a save game to a friend), you'll need to create a
-- separate storage instance for each one.
--
-- Your data is saved on disk in Lua format. This means that if someone
-- figures out where your data files are saved, it is very trivial for them
-- to change the data. If saving or loading fails, then this class still
-- retains your data across a single app session. If you want to be notified
-- when errors occur, check the <save()> and <load()> methods' arguments.
--
-- Make sure to set your app's identity in conf.lua, so that your 
-- files don't clobber some other app's. See https://love2d.org/wiki/Config_Files
-- for details.
--
--
-- Extends:
--		<Class>

Storage = Class:extend{
	-- Property: data
	-- Use this property to store whatever data you like. You can
	-- nest tables inside this.
	data = {},

	-- Property: filename
	-- What filename to store the data on disk under. See
	-- https://love2d.org/wiki/love.filesystem for where exactly this
	-- will be saved. Make sure to set this if your app is using
	-- multiple storage objects -- otherwise they will overwrite
	-- each other.

	filename = 'storage.dat',

	new = function (self, obj)
		obj = obj or {}
		self:extend(obj)

		if obj.filename then obj:load() end

		if obj.onNew then obj:onNew() end
		return obj
	end,

	-- Method: save
	-- Saves data to disk.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	save = function (self, ignoreError)
		if ignoreError ~= false then ignoreError = true end

		local ok, message = pcall(love.filesystem.write, self.filename, dump(self.data))

		if not ok and not ignoreError then
			error("could not save storage from disk: " .. message)
		end
	end,

	-- Method: load
	-- Loads data from disk.
	--
	-- Arguments:
	--		ignoreError - silently ignore any errors loading, default to true
	--
	-- Returns:
	--		whether loading actually worked, boolean

	load = function (self, ignoreError)
		if ignoreError ~= false then ignoreError = true end

		local ok, data = pcall(love.filesystem.read, self.filename)

		if ok then
			print(data)
			ok, self.data = pcall(loadstring('return ' .. data))
			
			if not ok then
				if ignoreError then
					self.data = {}
				else
					error("could not deserialize storage data: " .. self.data)
				end
			end
		else
			if not ignoreError then
				error("could not load storage from disk: " .. data)
			end
		end

		return ok
	end
}
