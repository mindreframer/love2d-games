require "RLMap"

DemoProgram = {}

function DemoProgram.load()
  math.randomseed(os.time())

  FONT_HEIGHT = 16
  local font = love.graphics.newFont("fonts/Perfect DOS VGA 437.ttf", FONT_HEIGHT)
  FONT_WIDTH = font:getWidth("W")

  map = RLMap.new()

  player = RLMapTile.new
  {
    display = "@",
    color = {255, 255, 0, 255},
  }

  map.player = player
  map.playerX = 10
  map.playerY = 10

  objectmap = {}

  -- the vertical part of the L
  for y=8,17 do
    local wall = RLMapTile.new
    {
      display = "#",
      color = {100, 100, 100, 255},
      movement = "false",
    }

    local x = 13
    objectmap[y] = objectmap[y] or {}
    objectmap[y][x] = wall
  end

  -- the horizontal part of the L
  for x=14,17 do
    local wall = RLMapTile.new
    {
      display = "#",
      color = {100, 100, 100, 255},
      movement = "false",
    }

    local y = 17
    objectmap[y] = objectmap[y] or {}
    objectmap[y][x] = wall
  end

  DemoProgram.mapBuffer = nil

  -- leave enough room for the status bar at the bottom
  local height = FONT_HEIGHT * (map.height + 2)
  local width =  FONT_WIDTH * map.width

  love.graphics.setFont(font)
  love.graphics.setMode(width, height, false, false, 0)
  love.graphics.setCaption("demo program")
end

function DemoProgram.draw()
  DemoProgram.drawMap()
  DemoProgram.drawObjects()
  DemoProgram.drawStatus()
end

function DemoProgram.drawMap()
  if not DemoProgram.mapBuffer then
    -- get the current width and height of the screen
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    -- find the closest power of 2
    local wp = math.pow(2, math.ceil(math.log(w)/math.log(2)))
    local hp = math.pow(2, math.ceil(math.log(h)/math.log(2)))

    -- create the framebuffer for the map
    DemoProgram.mapBuffer = love.graphics.newCanvas(wp, hp)

    -- render the map to the framebuffer
    love.graphics.setCanvas(DemoProgram.mapBuffer)
    for y=1,map.height do
      for x=1,map.width do
        local tile = map[y][x]
        love.graphics.setColor(unpack(tile.color))
        love.graphics.print(tile.display, (x - 1) * FONT_WIDTH, (y - 1) * FONT_HEIGHT)
      end
    end

    -- set the render target back to the window
    love.graphics.setCanvas()
  end

  -- draw the framebuffer to the screen
  love.graphics.draw(DemoProgram.mapBuffer)
end

-- TODO: objectmap is sparse; iterate over just the objects
-- TODO: accept an objectmap parameter
function DemoProgram.drawObjects()
  for y=1,map.height do
    local column = objectmap[y]
    if column then
      for x=1,map.width do
        local tile = column[x]
        if tile then
          -- "erase" the old tile
          love.graphics.setColor(0, 0, 0, 255)
          love.graphics.print(map[y][x].display, (x - 1) * FONT_WIDTH, (y - 1) * FONT_HEIGHT)
          -- draw the object
          love.graphics.setColor(unpack(tile.color))
          love.graphics.print(tile.display, (x - 1) * FONT_WIDTH, (y - 1) * FONT_HEIGHT)
        end
      end
    end
  end

  -- draw the player last
  -- TODO: move this to its own function
  love.graphics.setColor(unpack(player.color))
  love.graphics.print(player.display, (map.playerX - 1) * FONT_WIDTH, (map.playerY - 1) * FONT_HEIGHT)
end

-- TODO: probably construct a big string elsewhere and write it all at once
function DemoProgram.drawStatus()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("X=" .. map.playerX .. " Y=" .. map.playerY, 0, (map.height + 2 - 1) * FONT_HEIGHT)
  love.graphics.print("FPS: " .. love.timer.getFPS(), (map.width - 8) * FONT_WIDTH, (map.height + 2 - 1) * FONT_HEIGHT)
end

function DemoProgram.keypressed(key, unicode)
  local newX, newY = map.playerX, map.playerY

  if key == 'left' then
    newX = math.max(1, map.playerX - 1)
  elseif key == 'right' then
    newX = math.min(map.width, map.playerX + 1)
  elseif key == 'down' then
    newY = math.min(map.height, map.playerY + 1)
  elseif key == 'up' then
    newY = math.max(1, map.playerY - 1)
  end

  -- TODO: fix this
  local tile = objectmap[newY] and objectmap[newY][newX]
  if tile and (tile.movement == "true") or not tile then
    map.playerX = newX
    map.playerY = newY
  end
end

function DemoProgram.update(dt)
  local x, y = love.mouse.getPosition()
  local mapX = math.floor(x / FONT_WIDTH) + 1
  local mapY = math.floor(y / FONT_HEIGHT) + 1
  if love.mouse.isDown("l") then
    if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
      objectmap[mapY] = objectmap[mapY] or {}
      objectmap[mapY][mapX] = nil
    else
      objectmap[mapY] = objectmap[mapY] or {}
      objectmap[mapY][mapX] = RLMapTile.new
      {
        display = "#",
        color = {100, 100, 100, 255},
        movement = "false",
      }
    end
  end
  if love.mouse.isDown("r") then
    objectmap[mapY] = objectmap[mapY] or {}
    objectmap[mapY][mapX] = nil
  end
end
