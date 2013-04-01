-- Class: Cursor
-- A cursor is a group that follows the user's cursor.

Cursor = Group:extend{
	-- Property: hotspot
	-- A table with x and y offsets for the cursor. e.g. if
	-- you want the user to click with a center of a crosshairs
	-- image, set this to half the width and half the height of
	-- the image.
	hotspot = { x = 0, y = 0 },

	new = function (self, obj)
		obj = self:extend(obj)
		the.cursor = obj
		if obj.onNew then obj:onNew() end
		return obj
	end,

	update = function (self, elapsed)
		-- follow the mouse

		self.translate.x = the.mouse.x - self.hotspot.x
		self.translate.y = the.mouse.y - self.hotspot.y
		
		Group.update(self, elapsed)
	end
}
