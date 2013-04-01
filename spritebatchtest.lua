-- A hopefully simple demo of how love2d's sprite batches work.

-- love2d's image is a sprite atlas
-- love2d's quad is a sprite

-- so to draw stuff all over the screen:

-- create a quad for each sprite
-- each added quad (sprite) represents an instruction to draw that sprite

-- for the background, pre-load the batch using addq
-- as foreground items change, change each quad in the batch using setq

SpriteBatchTest = {}

SpriteBatchTest.MAP_TILES_WIDE = 80
SpriteBatchTest.MAP_TILES_HIGH = 25

SpriteBatchTest.ATLAS_NAME = "images/Codepage-437.png"

SpriteBatchTest.ATLAS_TILES_WIDE = 16
SpriteBatchTest.ATLAS_TILES_HIGH = 8

SpriteBatchTest.ATLAS_TILE_WIDTH  = 9
SpriteBatchTest.ATLAS_TILE_HEIGHT = 16

function SpriteBatchTest.load()
  local atlas = love.graphics.newImage(SpriteBatchTest.ATLAS_NAME)
  SpriteBatchTest.atlas = atlas

  SpriteBatchTest.ATLAS_WIDTH  = atlas:getWidth()
  SpriteBatchTest.ATLAS_HEIGHT = atlas:getHeight()

  local numMapTiles = SpriteBatchTest.MAP_TILES_WIDE * SpriteBatchTest.MAP_TILES_HIGH
  local batch = love.graphics.newSpriteBatch(atlas, numMapTiles)
  
  local x = 0 * SpriteBatchTest.ATLAS_TILE_WIDTH    -- zero columns over (first sprite in this row)
  local y = 2 * SpriteBatchTest.ATLAS_TILE_HEIGHT   -- two rows down

  local sprite = love.graphics.newQuad(x, 
				       y, 
				       SpriteBatchTest.ATLAS_TILE_WIDTH, 
				       SpriteBatchTest.ATLAS_TILE_HEIGHT, 
				       SpriteBatchTest.ATLAS_WIDTH, 
				       SpriteBatchTest.ATLAS_HEIGHT)
  SpriteBatchTest.sprite = sprite

  SpriteBatchTest.pos_x = 10
  SpriteBatchTest.pos_y = 10

  SpriteBatchTest.draw_man = batch:addq(sprite, 
					SpriteBatchTest.pos_x * SpriteBatchTest.ATLAS_TILE_WIDTH, 
					SpriteBatchTest.pos_y * SpriteBatchTest.ATLAS_TILE_HEIGHT)
  SpriteBatchTest.batch = batch

  love.graphics.setCaption("spitebatch")
  love.graphics.setMode(SpriteBatchTest.MAP_TILES_WIDE * SpriteBatchTest.ATLAS_TILE_WIDTH,
			SpriteBatchTest.MAP_TILES_HIGH * SpriteBatchTest.ATLAS_TILE_HEIGHT)
  love.keyboard.setKeyRepeat(0.2, 0.05)
end

function SpriteBatchTest.draw()
  SpriteBatchTest.batch:setq(SpriteBatchTest.draw_man,
			     SpriteBatchTest.sprite,
			     SpriteBatchTest.pos_x * SpriteBatchTest.ATLAS_TILE_WIDTH, 
			     SpriteBatchTest.pos_y * SpriteBatchTest.ATLAS_TILE_HEIGHT)
			     
  love.graphics.draw(SpriteBatchTest.batch, 0, 0)
end

function SpriteBatchTest.keypressed(key, unicode)
  if key == "up" then
    SpriteBatchTest.pos_y = math.max(0, SpriteBatchTest.pos_y - 1)
  elseif key == "down" then
    SpriteBatchTest.pos_y = math.min(SpriteBatchTest.MAP_TILES_HIGH - 1, SpriteBatchTest.pos_y + 1)
  elseif key == "left" then
    SpriteBatchTest.pos_x = math.max(0, SpriteBatchTest.pos_x - 1)
  elseif key == "right" then
    SpriteBatchTest.pos_x = math.min(SpriteBatchTest.MAP_TILES_WIDE - 1, SpriteBatchTest.pos_x + 1)
  end
end
