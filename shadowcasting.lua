require "RLMap"

ShadowCasting = {}

function ShadowCasting.load()
  math.randomseed(os.time())

  FONT_HEIGHT = 16
  local font = love.graphics.newFont("fonts/Perfect DOS VGA 437.ttf", FONT_HEIGHT)
  FONT_WIDTH = font:getWidth("W")

  StatusString = ""

  map = RLMap.new
  {
    tile = {
      display = ".",
      color = {0, 255, 0, 0},
    }
  }

  player = RLMapTile.new
  {
    display = "@",
    color = {255, 255, 0, 255},
  }

  map.player = player
  map.playerX = 20
  map.playerY = 20

  objectmap = {}

  ShadowCasting.mapBuffer = nil
  shadows = false

  -- leave enough room for the status bar at the bottom
  local height = FONT_HEIGHT * (map.height + 2)
  local width =  FONT_WIDTH * map.width

  love.graphics.setFont(font)
  love.graphics.setMode(width, height, false, false, 0)
  love.graphics.setCaption("shadowcasting!")
end

function ShadowCasting.draw()
  ShadowCasting.drawMap()
  ShadowCasting.drawObjects()
  ShadowCasting.castShadows()
  ShadowCasting.drawStatus()
end

function ShadowCasting.drawMap()
  love.graphics.setColor(255, 255, 255, 255)

  if not ShadowCasting.mapBuffer then
    -- get the current width and height of the screen
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    -- find the closest power of 2
    local wp = math.pow(2, math.ceil(math.log(w)/math.log(2)))
    local hp = math.pow(2, math.ceil(math.log(h)/math.log(2)))

    -- create the framebuffer for the map
    ShadowCasting.mapBuffer = love.graphics.newCanvas(wp, hp)

    -- render the map to the framebuffer
    love.graphics.setCanvas(ShadowCasting.mapBuffer)
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
  love.graphics.draw(ShadowCasting.mapBuffer)
end


function ShadowCasting.drawObjects()
  for y=1,map.height do
    if map[y] then
      for x=1,map.width do
        map[y][x].color[4] = 0
        local column = objectmap[y]
        if column then
          tile = column[x]
          if tile then
            map[y][x] = tile
          end
        end
      end
    end
  end

  -- draw the player last
  -- TODO: move this to its own function
  love.graphics.setColor(unpack(player.color))
  love.graphics.print(player.display, (map.playerX - 1) * FONT_WIDTH, (map.playerY - 1) * FONT_HEIGHT)
end

function ShadowCasting.castShadows()
  if not shadows then
    local sx, sy = map.playerX, map.playerY
    local r, g, b = 0, 0, 0

    local function draw(x, y)
      -- print(string.format("visiting %f, %f", x, y))
      local mx, my = math.floor(sx + x), math.floor(sy - y)
      map[my] = map[my] or {}
      map[my][mx] = map[my][mx] or {}
      if(map[my][mx].color) then
        r, g, b = unpack(map[my][mx].color)
      end
      map[my][mx].color = {r, g, b, 255} --math.min(255, math.floor(10000/(x^2+y^2)))}
    end

    local function drawEight(x, y)
      draw(x, y)
      draw(-x, y)
      draw(x, -y)
      draw(-x, -y)
      draw(y, x)
      draw(-y, x)
      draw(y, -x)
      draw(-y, -x)
    end

    local function isWall(x, y)
      local mx, my = math.floor(sx + x), math.floor(sy - y)
      map[my] = map[my] or {}
      local tile = map[my][mx] or {}
      if tile.display == "#" then
        -- print("wall at " .. x .. ", " .. y)
        return true
      end
      return false
    end

    local function callRecursiveFOV()
      recursiveFOV(1, 16, 1, 0, draw, isWall)
    end

    local theFunc = callRecursiveFOV

    theFunc()
    ShadowCasting.mapBuffer = nil
    shadows = true
  end
end

function permissiveFOV()
end

function recursiveFOV(startRadius, endRadius, startSlope, endSlope, visit, blocks)
  if startSlope > 1 then startSlope = 1 end
  if endSlope < 0 then endSlope = 0 end
  if startSlope < endSlope then return end

  local blocking = false

  print(string.format("entering loop from %f to %f, %f to %f", startRadius, endRadius, startSlope, endSlope))
  for y=startRadius,endRadius do
    local x = y * startSlope
    repeat
      visit(x, y)
      if blocking then
        if not blocks(x, y) then
          print(string.format("not blocking at %f, %f", x, y))
          blocking = false
          startSlope = (x+0.5)/(y+0.5)
          print(string.format("new startSlope: %f", startSlope))
        end
      else
        if blocks(x, y) then
          print(string.format("blocking at %f, %f", x, y))
          blocking = true
          local newEndSlope = (x+0.5)/(y-0.5)
          print(string.format("new endSlope: %f", newEndSlope))
          recursiveFOV(y+1, endRadius, startSlope, newEndSlope, visit, blocks)
        end
      end
      x = x - 1
    until x/y < endSlope
    if blocking then
      break
    end
  end
end

-- TODO: probably construct a big string elsewhere and write it all at once
function ShadowCasting.drawStatus()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print(StatusString, 0, (map.height + 2 - 1) * FONT_HEIGHT)
end


-- TODO: duplication! also, am I likely to put anything in here?
function ShadowCasting.update(dt)
  local x, y = love.mouse.getPosition()
  local mapX = math.floor(x / FONT_WIDTH) + 1
  local mapY = math.floor(y / FONT_HEIGHT) + 1

  local relX = mapX - map.playerX
  local relY = map.playerY - mapY

  StatusString = string.format("Relative Coords: %d, %d", relX, relY)
end

function ShadowCasting.mousereleased(x, y, button)
  local mapX = math.floor(x / FONT_WIDTH) + 1
  local mapY = math.floor(y / FONT_HEIGHT) + 1

  local function placeBlock(bx, by)
    objectmap[by] = objectmap[by] or {}
    objectmap[by][bx] = RLMapTile.new
    {
      display = "#",
      color = {100, 100, 100, 0},
      movement = "false",
    }
  end

  local function removeBlock(bx, by)
    objectmap[by] = objectmap[by] or {}
    objectmap[by][bx] = nil
    map[by][bx] = RLMapTile.new
    {
      display = ".",
      color = {0, 255, 0, 0},
    }
  end

  if button == "l" then
    if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
      removeBlock(mapX, mapY)
      shadows = false
    else
      placeBlock(mapX, mapY)
      shadows = false
    end
  elseif button == "r" then
    removeBlock(mapX, mapY)
    shadows = false
  end
end
