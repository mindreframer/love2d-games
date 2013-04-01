-- Class: Map
-- A map saves memory and CPU time by acting as if it were a grid of sprites.
-- Each different type of sprite in the grid is represented via a single
-- object. Each sprite must have the same size, however.
-- 
-- This works very similarly to a tilemap, but there is additional flexibility
-- in using a sprite, e.g. animation and other display effects. (If you want it
-- to act like a tilemap, use its loadTiles method.) However, changing a sprite's
-- x or y position has no effect. Changing the scale will have weird effects as
-- a map expects every sprite to be the same size.
--
-- Extends:
--		<Sprite>

Map = Sprite:extend{
	-- Constant: NO_SPRITE
	-- Represents a map entry with no sprite.
	NO_SPRITE = -1,

	-- Property: sprites
	-- An ordered table of <Sprite> objects to be used in conjunction with the map property.
	sprites = {},

	-- Property: map
	-- A two-dimensional table of values, each corresponding to an entry in the sprites property.
	-- nb. The tile at (0, 0) visually is stored in [1, 1].
	map = {},

	-- Method: empty
	-- Creates an empty map.
	--
	-- Arguments:
	--		width - width of the map in sprites
	--		height - height of the map in sprites
	-- 
	-- Returns:
	--		self, for chaining

	empty = function (self, width, height)
		local x, y
		
		-- empty the map

		for x = 1, width do
			self.map[x] = {}
			
			for y = 1, height do
				self.map[x][y] = Map.NO_SPRITE
			end
		end
		
		-- set bounds
		
		self.width = width * self.spriteWidth
		self.height = height * self.spriteHeight
		
		return self
	end,

	-- Method: loadMap
	-- Loads map data from a file, typically comma-separated values.
	-- Each entry corresponds to an index in self.sprites, and all rows
	-- must have the same number of columns.
	--
	-- Arguments:
	--		file - filename of source text to use
	--		colSeparator - character to use as separator of columns, default ','
	--		rowSeparator - character to use as separator of rows, default newline
	--
	-- Returns:
	--		self, for chaining

	loadMap = function (self, file, colSeparator, rowSeparator)
		colSeparator = colSeparator or ','
		rowSeparator = rowSeparator or '\n'
		
		-- load data
		
		local x, y
		local source = Cached:text(file)
		local rows = split(source, rowSeparator)
		
		for y = 1, #rows do
			local cols = split(rows[y], colSeparator)
			
			for x = 1, #cols do
				if not self.map[x] then self.map[x] = {} end
				self.map[x][y] = tonumber(cols[x])
			end
		end
		
		-- set bounds
		
		self.width = #self.map[1] * self.spriteWidth
		self.height = #self.map * self.spriteHeight
		
		return self
	end,

	-- Method: loadTiles
	--- Loads the sprites group with slices of a source image.
	--  By default, this uses the Tile class for sprites, but you
	--  may pass as replacement class.
	--
	--  Arguments:
	--		image - source image to use for tiles
	--		class - class to create objects with; constructor
	--				  will be called with properties: image, width,
	--				  height, imageOffset (with x and y sub-properties)
	--		startIndex - starting index of tiles in self.sprites, default 0
	--
	--  Returns:
	--		self, for chaining

	loadTiles = function (self, image, class, startIndex)
		assert(self.spriteWidth and self.spriteHeight, 'sprite size must be set before loading tiles')
		if type(startIndex) ~= 'number' then startIndex = 0 end
		
		class = class or Tile
		self.sprites = self.sprites or {}
		
		local imageObj = Cached:image(image)
		local imageWidth = imageObj:getWidth()
		local imageHeight = imageObj:getHeight()
		 
		local i = startIndex
		
		for y = 0, imageHeight - self.spriteHeight, self.spriteHeight do
			for x = 0, imageWidth - self.spriteWidth, self.spriteWidth do
				self.sprites[i] = class:new{ image = image, width = self.spriteWidth,
											  height = self.spriteHeight,
											  imageOffset = { x = x, y = y }}
				i = i + 1
			end
		end
		
		return self
	end,

	-- Method: subcollide
	-- This acts as a wrapper to multiple collide() calls, as if
	-- there really were all the sprites in their particular positions.
	-- This is much more useful than Map:collide(), which simply checks
	-- if a sprite or group is touching the map at all. 
	--
	-- Arguments:
	--		other - other <Sprite> or <Group>
	--
	-- Returns:
	--		boolean, whether any collision was detected

	subcollide = function (self, other)
		local hit = false
		local others

		if other.sprites then
			others = other.sprites
		else
			others = { other }
		end

		for _, othSpr in pairs(others) do
			if othSpr.solid then
				if othSpr.sprites then
					-- recurse into subgroups
					-- order is important here to avoid short-circuiting inappopriately
				
					hit = self:subcollide(othSpr.sprites) or hit
				else
					local startX, startY = self:pixelToMap(othSpr.x - self.x, othSpr.y - self.y)
					local endX, endY = self:pixelToMap(othSpr.x + othSpr.width - self.x,
													   othSpr.y + othSpr.height - self.y)
					local x, y
					
					for x = startX, endX do
						for y = startY, endY do
							local spr = self.sprites[self.map[x][y]]
							
							if spr and spr.solid then
								-- position our map sprite as if it were onscreen
								
								spr.x = self.x + (x - 1) * self.spriteWidth
								spr.y = self.y + (y - 1) * self.spriteHeight
								
								hit = spr:collide(othSpr) or hit
							end
						end
					end
				end
			end
		end

		return hit
	end,

	-- Method: subdisplace
	-- This acts as a wrapper to multiple displace() calls, as if
	-- there really were all the sprites in their particular positions.
	-- This is much more useful than Map:displace(), which pushes a sprite or group
	-- so that it does not touch the map in its entirety. 
	--
	-- Arguments:
	--		other - other <Sprite> or <Group> to displace
	--		xHint - force horizontal displacement in one direction, uses direction constants
	--		yHint - force vertical displacement in one direction, uses direction constants

	subdisplace = function (self, other, xHint, yHint)	
		local others

		if other.sprites then
			others = other.sprites
		else
			others = { other }
		end

		for _, othSpr in pairs(others) do
			if othSpr.solid then
				if othSpr.sprites then
					-- recurse into subgroups
					-- order is important here to avoid short-circuiting inappopriately
				
					self:subdisplace(othSpr.sprites)
				else
					local startX, startY = self:pixelToMap(othSpr.x - self.x, othSpr.y - self.y)
					local endX, endY = self:pixelToMap(othSpr.x + othSpr.width - self.x,
													   othSpr.y + othSpr.height - self.y)
					local x, y
					
					for x = startX, endX do
						for y = startY, endY do
							local spr = self.sprites[self.map[x][y]]
							
							if spr and spr.solid then
								-- position our map sprite as if it were onscreen
								
								spr.x = self.x + (x - 1) * self.spriteWidth
								spr.y = self.y + (y - 1) * self.spriteHeight
								
								spr:displace(othSpr)
							end
						end
					end
				end
			end
		end
	end,

	-- Method: getMapSize
	-- Returns the size of the map in sprites.
	--
	-- Arguments:
	--		none
	--
	-- Returns:
	--		width and height in integers

	getMapSize = function (self)
		if #self.map == 0 then
			return 0, 0
		else
			return #self.map, #self.map[1]
		end
	end,

	draw = function (self, x, y)
		-- lock our x/y coordinates to integers
		-- to avoid gaps in the tiles
	
		x = math.floor(x or self.x)
		y = math.floor(y or self.y)
		if not self.visible or self.alpha <= 0 then return end
		if not self.spriteWidth or not self.spriteHeight then return end
		
		-- determine drawing bounds
		-- we draw to fill the entire app windoow
		
		local startX, startY = self:pixelToMap(-x, -y)
		local endX, endY = self:pixelToMap(the.app.width - x, the.app.height - y)
		
		-- queue each sprite drawing operation
		
		local toDraw = {}
		
		for drawY = startY, endY do
			for drawX = startX, endX do
				local sprite = self.sprites[self.map[drawX][drawY]]
				
				if sprite and sprite.visible then
					if not toDraw[sprite] then
						toDraw[sprite] = {}
					end
					
					table.insert(toDraw[sprite], { x + (drawX - 1) * self.spriteWidth,
												   y + (drawY - 1) * self.spriteHeight })
				end
			end
		end
		
		-- draw each sprite in turn
		
		for sprite, list in pairs(toDraw) do
			for _, coords in pairs(list) do
				sprite:draw(coords[1], coords[2])
			end
		end
		
		Sprite.draw(self)
	end,

	-- Method: pixelToMap
	-- Converts pixels to map coordinates.
	--
	-- Arguments:
	--		x - x coordinate in pixels
	--		y - y coordinate in pixels
	--		clamp - clamp to map bounds? defaults to true
	--
	-- Returns:
	--		x, y map coordinates

	pixelToMap = function (self, x, y, clamp)
		if type(clamp) == 'nil' then clamp = true end

		-- remember, Lua tables start at index 1

		local mapX = math.floor(x / self.spriteWidth) + 1
		local mapY = math.floor(y / self.spriteHeight) + 1
		
		-- clamp to map bounds
		
		if clamp then
			if mapX < 1 then mapX = 1 end
			if mapY < 1 then mapY = 1 end
			if mapX > #self.map then mapX = #self.map end
			if mapY > #self.map[1] then mapY = #self.map[1] end
		end

		return mapX, mapY
	end,

	-- makes sure all sprites receive startFrame messages

	startFrame = function (self, elapsed)
		for _, spr in pairs(self.sprites) do
			spr:startFrame(elapsed)
		end

		Sprite.startFrame(self, elapsed)
	end,

	-- makes sure all sprites receive update messages

	update = function (self, elapsed)
		for _, spr in pairs(self.sprites) do
			spr:update(elapsed)
		end

		Sprite.update(self, elapsed)
	end,

	-- makes sure all sprites receive endFrame messages

	endFrame = function (self, elapsed)
		for _, spr in pairs(self.sprites) do
			spr:endFrame(elapsed)
		end

		Sprite.endFrame(self, elapsed)
	end,

	__tostring = function (self)
		local result = 'Map (x: ' .. self.x .. ', y: ' .. self.y ..
					   ', w: ' .. self.width .. ', h: ' .. self.height .. ', '

		if self.active then
			result = result .. 'active, '
		else
			result = result .. 'inactive, '
		end

		if self.visible then
			result = result .. 'visible, '
		else
			result = result .. 'invisible, '
		end

		if self.solid then
			result = result .. 'solid'
		else
			result = result .. 'not solid'
		end

		return result .. ')'
	end
}
