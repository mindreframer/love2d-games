require "arc45"

DemoCircles = {}

function DemoCircles.load()
  DemoCircles.MAXRAD = 20
  DemoCircles.BOXSIZE = 10

  DemoCircles.CurrentRadius = 6

  DemoCircles.CurrentAlgorithm = holes45

  local width = (2 * DemoCircles.MAXRAD + 3) * DemoCircles.BOXSIZE
  local height = width

  love.graphics.setMode(width, height)
end

function DemoCircles.draw()
  local points = DemoCircles.CurrentAlgorithm(DemoCircles.CurrentRadius)

  for i=1,#points do
    local x, y = unpack(points[i])
    DemoCircles.drawBoxes(x, y)
  end

  local center = DemoCircles.MAXRAD + 1
  love.graphics.rectangle("fill",
                          center * DemoCircles.BOXSIZE,
                          center * DemoCircles.BOXSIZE,
                          DemoCircles.BOXSIZE,
                          DemoCircles.BOXSIZE)
end

function DemoCircles.drawBoxes(x, y)
  local center = DemoCircles.MAXRAD + 1
  local bx = center * DemoCircles.BOXSIZE
  local by = center * DemoCircles.BOXSIZE
  local px = x * DemoCircles.BOXSIZE
  local py = y * DemoCircles.BOXSIZE
  love.graphics.rectangle("fill", bx + px, by + py, DemoCircles.BOXSIZE, DemoCircles.BOXSIZE)
  love.graphics.rectangle("fill", bx + px, by - py, DemoCircles.BOXSIZE, DemoCircles.BOXSIZE)
  love.graphics.rectangle("fill", bx - px, by + py, DemoCircles.BOXSIZE, DemoCircles.BOXSIZE)
  love.graphics.rectangle("fill", bx - px, by - py, DemoCircles.BOXSIZE, DemoCircles.BOXSIZE)
  love.graphics.rectangle("fill", bx + py, by + px, DemoCircles.BOXSIZE, DemoCircles.BOXSIZE)
  love.graphics.rectangle("fill", bx + py, by - px, DemoCircles.BOXSIZE, DemoCircles.BOXSIZE)
  love.graphics.rectangle("fill", bx - py, by + px, DemoCircles.BOXSIZE, DemoCircles.BOXSIZE)
  love.graphics.rectangle("fill", bx - py, by - px, DemoCircles.BOXSIZE, DemoCircles.BOXSIZE)
end

function DemoCircles.keypressed(key, unicode)
  if key == "p" then
    DemoCircles.CurrentAlgorithm = points45
  elseif key == "h" then
    DemoCircles.CurrentAlgorithm = holes45
  elseif key == "i" then
    DemoCircles.CurrentAlgorithm = arc45
  elseif key == "up" then
    DemoCircles.CurrentRadius = math.min(DemoCircles.CurrentRadius + 1, DemoCircles.MAXRAD)
  elseif key == "down" then
    DemoCircles.CurrentRadius = math.max(DemoCircles.CurrentRadius - 1, 1)
  end
end

function DemoCircles.mousepressed(x, u, button)
  if button == "wd" then
    DemoCircles.CurrentRadius = math.max(DemoCircles.CurrentRadius - 1, 1)
  elseif button == "wu" then
    DemoCircles.CurrentRadius = math.min(DemoCircles.CurrentRadius + 1, DemoCircles.MAXRAD)
  end
end
