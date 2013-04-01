-- Class: Subview
-- A subview is a view that steals lives inside a parent view. It's useful for
-- things like a pause overlay or inventory screen, which don't interact with a main view
-- directly and are useful when they're sectioned off into their own world.
--
-- A subview should not interact much with its parent view, if at all. It's important
-- to, if a subview calls a method on its parent, that it set the.view to the parent,
-- and then restore it to itself afterwards.
--
-- A subview is modal, meaning that although the parent view is visible underneath
-- its subview, it does not receive any update-related events. If you want to display
-- something on top of a view while it still is visible and updating, use a <Group>
-- instead.
--
-- Events:
--		onActivate - Called when the subview activates.
--		onDeactivate - Called when the subview deactivates.
--
-- Extends:
--		<View>

Subview = View:extend
{
	-- Property: drawParent
	-- Draw the parent view underneath this one? Defaults to true.
	drawParent = true,

	-- Property: activated
	-- Is this subview currently visible and active? This property is read-only.
	-- To change the status of the subview, use either the <activate()> or
	-- <deactivate()> methods.
	activated = false,

	-- Method: activate
	-- Shows the subview.
	-- 
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	activate = function (self)
		if the.view == self then
			if STRICT then
				local info = debug.getinfo(2, 'Sl')
				print('Warning: treid to activate an already active subview (' ..
					  info.short_src .. ', line ' .. info.currentline .. ')')
			end

			return
		end

		self.parentView = the.view
		the.app.view = self
		self.activated = true
		if self.onActivate then self:onActivate() end
	end,

	-- Method: deactivate
	-- Hides the subview.
	-- 
	-- Arguments:
	--		none
	--
	-- Returns:
	--		nothing

	deactivate = function (self)
		the.app.view = self.parentView
		self.activated = false
		if self.onDeactivate then self:onDeactivate() end
	end,

	draw = function (self, x, y)
		if self.drawParent and self.parentView then self.parentView:draw(x, y) end
		View.draw(self, x, y)
	end
}
