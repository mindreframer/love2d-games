-- Four Languages quiz game (c) Rachel J. Morris 2013, Moosader.com - zlib license

require "mouse"

ui = {}

colors = {
	primaryButton = {
		normal = 		{ r = 255, g = 152, b = 232 },
		highlight = 	{ r = 255, g = 200, b = 255 },
		text = 			{ r = 140, g = 13, b = 122 },
		border = 		{ r = 255, g = 255, b = 255 }
	},
	secondaryButton = {
		normal = 		{ r = 149, g = 231, b = 132 },
		highlight = 	{ r = 197, g = 251, b = 186 },
		text = 			{ r = 23, g = 118, b = 0 },
		border = 		{ r = 255, g = 255, b = 255 }
	},
	disabledButton = {
		normal = 		{ r = 175, g = 175, b = 175 },
		highlight = 	{ r = 200, g = 200, b = 200 },
		text = 			{ r = 0, g = 0, b = 0 },
		border = 		{ r = 255, g = 255, b = 255 }
	},

	background = {
		r = 149, g = 209, b = 201
	}
}

fonts = {
	button = 	love.graphics.newFont( "content/Averia-Bold.ttf", 24 ),
	header = 	love.graphics.newFont( "content/Averia-Bold.ttf", 40 ),
	text = 		love.graphics.newFont( "content/Averia-Bold.ttf", 16 )
}

function ui:drawBackground()
	love.graphics.setColor( colors.background.r, colors.background.g, colors.background.b )
	love.graphics.rectangle( "fill", 0, 0, 800, 600 )
end

function ui:drawPrimaryButton( text, x, y, w, h )
	self:drawButton( text, x, y, w, h, colors.primaryButton )
end

function ui:drawSecondaryButton( text, x, y, w, h )
	self:drawButton( text, x, y, w, h, colors.secondaryButton )
end

function ui:drawDisabledButton( text, x, y, w, h )
	self:drawButton( text, x, y, w, h, colors.disabledButton )
end

function ui:drawButton( text, x, y, w, h, btnColor )
	if ( mouse:isMouseOver( x, y, w, h ) ) then
		-- Highlight button
		love.graphics.setColor( btnColor.highlight.r, btnColor.highlight.g, btnColor.highlight.b, 255 )
	else
		-- Normal button colors
		love.graphics.setColor( btnColor.normal.r, btnColor.normal.g, btnColor.normal.b, 255 )
	end
	love.graphics.rectangle( "fill", x, y, w, h )	-- Button base
	
	love.graphics.setColor( btnColor.border.r, btnColor.border.g, btnColor.border.b, 255 )
	love.graphics.rectangle( "line", x, y, w, h )	-- Border
	
	love.graphics.setFont( fonts.button )
	love.graphics.setColor( btnColor.text.r, btnColor.text.g, btnColor.text.b, 255 )
	love.graphics.printf( text, x, y, w, "center" )
end

function ui:drawHeader( text, x, y, color )
	love.graphics.setFont( fonts.header )
	love.graphics.setColor( color.r, color.g, color.b )
	love.graphics.printf( text, x, y, 800, "center" )
end

function ui:drawScore( text, x, y, color )
	love.graphics.setFont( fonts.text )
	love.graphics.setColor( color.r, color.g, color.b )
	love.graphics.printf( text, x, y, 800, "left" )
end
