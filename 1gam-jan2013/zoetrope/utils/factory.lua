-- Class: Factory
-- A factory allows for simple object pooling; that is,
-- reusing object instances instead of creating them and deleting
-- them as needed. This approach saves CPU and memory.
--
-- Be careful of accidentally adding an instance to a view twice.
-- This will manifest itself as the sprite moving twice as fast, for
-- example, each time it is recycled. The easiest way to avoid this
-- problem is for the object to add itself to the view in its onNew
-- handler, since that will only be called once.
--
-- If you only want a certain number of instances of a class ever
-- created, first call preload() to create as many instances as you want,
-- then freeze() to prevent any new instances from being created.
-- If a factory is ever asked to make a new instance of a frozen class
-- but none are available for recycling, it returns nil.
--
-- Event: onReset
-- Called not on the factory, but the object is creates whenever
-- it is either initially created or recycled via create(). 
--
-- Extends:
--		<Class>

Factory = Class:extend{
	-- private property: objects ready to be recycled, stored by prototype
	_recycled = {},

	-- private property: tracks which pools cannot be added to, stored by prototype.
	_frozen = {},

	-- Method: create
	-- Creates a fresh object, either by reusing a previously
	-- recycled one or creating a new instance. If the object has
	-- a revive method, it calls it.
	--
	-- Arguments:
	--		prototype - <Class> object
	--		props - table of properties to mix into the class
	--
	-- Returns:
	-- 		fresh object

	create = function (self, prototype, props)
		local newObj

		if STRICT then
			assert(prototype.instanceOf and prototype:instanceOf(Class), 'asked to create something that isn\'t a class')
		end
		
		if self._recycled[prototype] and #self._recycled[prototype] > 0 then
			newObj = table.remove(self._recycled[prototype])
			if props then newObj:mixin(props) end
		else
			-- create a new instance if we're allowed to

			if not self._frozen[prototype] then
				newObj = prototype:new(props)
			else
				return nil
			end
		end

		if newObj.revive then newObj:revive() end
		if newObj.onReset then newObj:onReset() end
		return newObj
	end,

	-- Method: recycle
	-- Marks an object as ready to be recycled. If the object
	-- has a die method, then this function it.
	--
	-- Arguments:
	-- 		object - object to recycle
	--
	-- Returns:
	--		nothing

	recycle = function (self, object)
		if not self._recycled[object.prototype] then
			self._recycled[object.prototype] = {}
		end

		table.insert(self._recycled[object.prototype], object)

		if object.die then object:die() end
	end,

	-- Method: preload
	-- Preloads the factory with a certain number of instances of a class.
	--
	-- Arguments:
	--		prototype - class object
	--		count - number of objects to create
	--
	-- Returns:
	--		nothing

	preload = function (self, prototype, count)
		if not self._recycled[prototype] then
			self._recycled[prototype] = {}
		end

		local i

		for i = 1, count do
			table.insert(self._recycled[prototype], prototype:new())
		end
	end,

	-- Method: freeze
	-- Prevents any new instances of a class from being created via create().
	--
	-- Arguments:
	-- 		prototype - class object
	--
	-- Returns:
	--		nothing

	freeze = function (self, prototype)
		self._frozen[prototype] = true
	end,

	-- Method: unfreeze
	-- Allows new instances of a class to be created via create().
	--
	-- Arguments:
	--		prototype - class object
	--
	-- Returns:
	--		nothing

	unfreeze = function (self, prototype)
		self._frozen[prototype] = false
	end
}
