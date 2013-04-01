-- Four Languages quiz game (c) Rachel J. Morris 2013, Moosader.com - zlib license

mouse = {}

function mouse:isMouseOverTable( tbl )
	return mouse:isMouseOver( tbl.x, tbl.y, tbl.w, tbl.h )
end

function mouse:isMouseOver( x, y, w, h )
	return ( love.mouse.getX() >= x and love.mouse.getX() <= x + w and
			love.mouse.getY() >= y and love.mouse.getY() <= y + h )
end
