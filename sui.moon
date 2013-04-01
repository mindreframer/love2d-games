-- Copyright (c) 2012 Ryusei Yamaguchi
--
-- This software is provided 'as-is', without any express or implied
-- warranty.  In no event will the authors be held liable for any damages
-- arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
--
-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgment in the product documentation would be
--    appreciated but is not required.
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.

export sui

import graphics, mouse from love

tau = 2 * math.pi
quarter_tau = 0.25 * tau

copy = (obj) ->
	{k, v for k, v in pairs obj}

bang = (obj) ->
	if type(obj) == 'function'
		obj!
	else
		obj

sequence = (f1, f2) ->
	(...) ->
		f1 ...
		f2 ...

forward = (table) -> ->
	i = 0
	->
		i += 1
		table[i]

backward = (table) -> ->
	i = #table
	->
		i, j = i - 1, i
		table[j]

sui = {}

sui.bang = bang

connect_handler = (child, parent) ->
	if type(child) == 'function'
		sequence(child, parent)
	else
		parent

connect_focus = (child, parent) ->
	if type(child) == 'function'
		(i, f) -> return child(parent(i, f))
	else
		parent

rotate_focus = (f_iter, b_iter) ->
	(i, f) ->
		iter = if type(i) == 'boolean' and i then b_iter else f_iter
		for wid in iter()
			changefocus = wid.changefocus
			if type(changefocus) == 'function'
				i, f = changefocus i, f
		return i, f

allwidget = (name, widgets) -> (...) ->
	for i, wid in ipairs widgets
		f = wid[name]
		if type(f) == 'function' then f ...

container = (func, widgets, ...) ->
	names = {'update', 'focus', 'keypressed', 'keyreleased', 'joystickpressed', 'joystickreleased', ...}
	obj = {}
	obj.children = widgets
	for k, v in ipairs names
		obj[v] = func v, widgets
	return obj

sui.container = container

sui.layer = (widgets) ->
	obj = container allwidget, widgets, 'draw', 'mousepressed', 'mousereleased'
	obj.changefocus = rotate_focus forward(widgets), backward(widgets)
	obj.size = ->
		ox, oy = 0, 0
		for i, wid in ipairs widgets
			w, h = wid.size()
			ox = math.max ox, w
			oy = math.max oy, h
		return ox, oy
	return obj

sui.vbox = (padding, widgets) ->
	obj = container allwidget, widgets
	obj.size = (x, y, ...) ->
		p = bang(padding)
		ox, oy = 0, 0
		for i, wid in ipairs widgets
			w, h = wid.size()
			ox = math.max ox, w
			oy += h + p
		return ox, oy - p
	func = (name) -> (x, y, ...) ->
		p = bang(padding)
		oy = 0
		for i, wid in ipairs widgets
			f = wid[name]
			if type(f) == 'function'
				f x, y + oy, ...
			w, h = wid.size()
			oy += h + p
	obj.draw = func 'draw'
	obj.mousepressed = func 'mousepressed'
	obj.mousereleased = func 'mousereleased'
	obj.changefocus = rotate_focus forward(widgets), backward(widgets)
	return obj

sui.hbox = (padding, widgets) ->
	obj = container allwidget, widgets
	obj.children = widgets
	obj.size = (x, y, ...) ->
		p = bang(padding)
		ox, oy = 0, 0
		for i, wid in ipairs widgets
			w, h = wid.size()
			ox += w + p
			oy = math.max oy, h
		return ox - p, oy
	func = (name) -> (x, y, ...) ->
		p = bang(padding)
		ox = 0
		for i, wid in ipairs widgets
			f = wid[name]
			if type(f) == 'function'
				f x + ox, y, ...
			w, h = wid.size()
			ox += w + p
	obj.draw = func 'draw'
	obj.mousepressed = func 'mousepressed'
	obj.mousereleased = func 'mousereleased'
	obj.changefocus = rotate_focus forward(widgets), backward(widgets)
	return obj

sui.grid = (width, height, column, widgets) ->
	obj = container allwidget, widgets
	obj.size = (x, y, ...) ->
		w, h = bang(width), bang(height)
		c = math.floor(bang(column))
		if c == 0
			return w * #widgets, h
		else
			return w * c, h * math.ceil(#widgets / c)
	func = (name) -> (x, y, ...) ->
		ox, oy = 0, 0
		w, h = bang(width), bang(height)
		c = math.ceil(bang(column))
		for i, wid in ipairs widgets
			f = wid[name]
			if type(f) == 'function'
				f x + ox, y + oy, ...
			ox += w
			if c ~= 0 and i % c == 0
				ox = 0
				oy += h
	obj.draw = func 'draw'
	obj.mousepressed = func 'mousepressed'
	obj.mousereleased = func 'mousereleased'
	obj.changefocus = rotate_focus forward(widgets), backward(widgets)
	return obj

sui.option = (key, widgets) ->
	func = (name, wids) -> (...) ->
		wid = wids[bang(key)]
		if wid ~= nil
			v = wid[name]
			if type(v) == 'function' then v(...)
	obj = container func, widgets, 'draw', 'mousepressed', 'mousereleased'
	obj.size = ->
		wid = widgets[bang(key)]
		if wid ~= nil
			return wid.size()
		else
			return 0, 0
	return obj

sui.event = (name, handler, widget) ->
	obj = copy(widget)
	obj[name] = connect_handler obj[name], handler
	return obj

handle_on_area = (size, handler) ->
	(x, y, button) ->
		w, h = size()
		if 0 <= x and x < w and 0 <= y and y < h
			handler(x, y, button)

mouse_coordinate_transform = (handler) -> (wx, wy, mx, my, button) ->
	x, y = mx - wx, my - wy
	handler(x, y, button)

sui.mousepressed = (handler, widget) ->
	sui.event 'mousepressed', mouse_coordinate_transform(handle_on_area(widget.size, handler)), widget

sui.mousereleased = (handler, widget) ->
	sui.event 'mousereleased', mouse_coordinate_transform(handle_on_area(widget.size, handler)), widget

sui.global_mousepressed = (handler, widget) ->
	sui.event 'mousepressed', mouse_coordinate_transform(handler), widget

sui.global_mousereleased = (handler, widget) ->
	sui.event 'mousereleased', mouse_coordinate_transform(handler), widget

sui.update = (handler, widget) ->
	sui.event 'update', handler, widget

sui.keypressed = (handler, widget) ->
	sui.event 'keypressed', handler, widget

sui.keyreleased = (handler, widget) ->
	sui.event 'keyreleased', handler, widget

sui.joystickpressed = (handler, widget) ->
	sui.event 'joystickpressed', handler, widget

sui.joystickreleased = (handler, widget) ->
	sui.event 'joystickreleased', handler, widget

sui.clicked = (handler, widget) ->
	mousedown = nil
	sui.mousepressed (x, y, button) -> mousedown = button,
		sui.global_mousereleased (x, y, button) -> mousedown = nil,
			sui.mousereleased (x, y, button) -> if mousedown == button then handler(x, y, button),
				widget

sui.focusroot = (widget) ->
	obj = copy(widget)
	changefocus = obj.changefocus
	obj.changefocus = (i, f) ->
		i, f = changefocus(i, f)
		if f then changefocus(i, true)
	obj.changefocus(nil, true)
	return obj

sui.focus = (handler, widget) ->
	sui.event 'focus', handler, widget

sui.focusstop = (widget) ->
	obj = copy(widget)
	focused = false
	focus = obj.focus
	if type(focus) ~= 'function' then focus = ->
	func = (i, f) ->
		x = f or focused or false
		y = focused
		switch type(i)
			when 'nil'
				focused = f
				x = false
			when 'table'
				focused = f and (i == obj)
			when 'boolean'
				if f
					focused = true
					x, i = false, nil
				else
					focused = false
			when 'number'
				i = math.floor(i)
				if i == 0
					focused = x
					x = false
				else
					focused = false
					if x
						if i > 0 then i -= 1 else i += 1
		if focused != y
			focus(focused)
		return i, x
	obj.changefocus = connect_focus obj.changefocus, func
	return obj

sui.focusfc = (color, widget) ->
	focused = false
	sui.focus (f) -> focused = f,
		sui.fc (-> if focused then bang(color)), widget

sui.focusbc = (color, widget) ->
	focused = false
	sui.focus (f) -> focused = f,
		sui.bc (-> if focused then bang(color)), widget

sui.focusevent = (name, handler, widget) ->
	focused = false
	sui.focus ((f) -> focused = f),
		sui.event name, ((...) -> if focused then handler ...), widget

sui.focusoption = (widgets) ->
	focused = false
	sui.focus ((f) -> focused = f),
		sui.option (-> focused), widgets

sui.float = (dx, dy, widget) ->
	obj = copy(widget)
	obj.size = -> return 0, 0
	func = (f) ->
		if type(f) == 'function'
			(x, y, ...) -> f(x + bang(dx), y + bang(dy), ...)
		else
			f
	obj.draw = func obj.draw
	obj.mousepressed = func obj.mousepressed
	obj.mousereleased = func obj.mousereleased
	return obj

sui.margin = (marginx, marginy, widget) ->
	obj = copy(widget)
	size = obj.size
	obj.size = ->
		mx, my = bang(marginx), bang(marginy)
		w, h = size()
		return w + 2 * mx, h + 2 * my
	func = (f) ->
		if type(f) == 'function'
			(x, y, ...) -> f(x + bang(marginx), y + bang(marginy), ...)
		else
			f
	
	obj.draw = func obj.draw
	obj.mousepressed = func obj.mousepressed
	obj.mousereleased = func obj.mousereleased
	return obj

sui.font = (font, widget) ->
	obj = copy(widget)
	draw = obj.draw
	obj.draw = (x, y) ->
		f = bang(font)
		if f == nil
			return draw x, y
		prev = graphics.getFont()
		graphics.setFont f
		draw x, y
		graphics.setFont prev
	return obj

sui.fc = (color, widget) ->
	obj = copy(widget)
	draw = obj.draw
	obj.draw = (x, y) ->
		c = bang(color)
		if c == nil
			return draw x, y
		r, g, b, a = graphics.getColor()
		graphics.setColor c
		draw x, y
		graphics.setColor r, g, b, a
	return obj

sui.bc = (color, widget) ->
	obj = copy(widget)
	draw = obj.draw
	size = obj.size
	obj.draw = (x, y) ->
		c = bang(color)
		if c == nil
			return draw x, y
		r, g, b, a = graphics.getColor()
		graphics.setColor c
		w, h = size()
		graphics.rectangle 'fill', x, y, w, h
		graphics.setColor r, g, b, a
		draw x, y
	return obj

sui.scale = (sx, sy, widget) ->
	import ceil, abs from math
	import push, pop, translate, scale from graphics
	obj = copy(widget)
	size = obj.size
	draw = obj.draw
	mousepressed = obj.mousepressed
	mousereleased = obj.mousereleased
	obj.size = ->
		w, h = size()
		return ceil(abs(w * bang(sx))), ceil(abs(h * bang(sy)))
	obj.draw = (x, y) ->
		local lsx, lsy
		lsx, lsy = bang(sx), bang(sy)
		w, h = size()
		wx, wy = 0, 0
		if lsx < 0
			wx = -w
		if lsy < 0
			wy = -h
		push()
		translate x, y
		scale lsx, lsy
		draw wx, wy
		pop()
	func = (f) -> (wx, wy, mx, my, button) ->
		x, y = bang(sx), bang(sy)
		if x < 0 then x = -x
		if y < 0 then y = -y
		if x ~= 0 and y ~= 0
			f(0, 0, (mx - wx) / x, (my - wy) / y)
	if type(mousepressed) == 'function' then obj.mousepressed = func mousepressed
	if type(mousereleased) == 'function' then obj.mousereleased = func mousereleased
	return obj

sui.translate = (dx, dy, widget) ->
	import push, pop, translate from graphics
	obj = copy(widget)
	size = obj.size
	draw = obj.draw
	mousepressed = obj.mousepressed
	mousereleased = obj.mousereleased
	obj.size = ->
		w, h = size()
		return ceil(w + bang(dx)), ceil(h + bang(dy))
	obj.draw = (x, y) ->
		push()
		translate bang(dx), bang(dy)
		draw x, y
		pop()
	func = (f) -> (wx, wy, mx, my, button) ->
		x, y = bang(dx), bang(dy)
		f(wx, wy, mx - x, wy - y)
	if type(mousepressed) == 'function' then obj.mousepressed = func mousepressed
	if type(mousereleased) == 'function' then obj.mousereleased = func mousereleased
	return obj

sui.frame = (width, height, draw) ->
	obj = {}
	obj.size = -> return bang(width), bang(height)
	obj.draw = draw
	return obj

sui.label = (width, height, caption) ->
	sui.frame width, height, (x, y) -> graphics.printf bang(caption), x, y, bang(width)

sui.alabel = (width, height, align, caption) ->
	sui.frame width, height, (x, y) -> graphics.printf bang(caption), x, y, bang(width), bang(align)

sui.clabel = (width, height, caption) ->
	sui.frame width, height, (x, y) -> graphics.printf bang(caption), x, y, bang(width), 'center'

sui.rlabel = (width, height, caption) ->
	sui.frame width, height, (x, y) -> graphics.printf bang(caption), x, y, bang(width), 'right'

sui.hbar = (width, height, value) ->
	sui.frame width, height, (x, y) -> graphics.rectangle 'fill', x, y, bang(width) * bang(value), bang(height)

sui.pie = (diameter, value) ->
	obj = {}
	obj.draw = (x, y) ->
		d = bang(diameter)
		r = d / 2
		graphics.arc 'fill', x + r, y + r, r, -quarter_tau, tau * bang(value) - quarter_tau
	obj.size = ->
		d = bang(diameter)
		return d, d
	return obj

sui.flipable = (angle, widgets) ->
	import max, cos from math
	local w, o
	widget1 = widgets[1]
	widget2 = widgets[2]
	w1, h1 = widget1.size()
	w2, h2 = widget2.size()
	w, h = max(w1, w2), max(h1, h2)
	o = 1
	set_o = -> o = cos(bang angle)
	f0 = ->
		cos(bang angle) >= 0
	f1 = ->
		w / 2 * (1 - o)
	f2 = -> w / 2 * (1 + o)
	obj = sui.update set_o, sui.option f0, {
		[true]: sui.translate f1, 0, sui.scale (-> o), 1, widget1
		[false]: sui.translate f2, 0, sui.scale (-> -o), 1, widget2
	}
	obj.size = -> w, h
	return obj
