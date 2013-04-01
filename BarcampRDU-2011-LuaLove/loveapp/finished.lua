-- main.lua
-- This is where the magic happens people.

require 'logo'
require 'vector'

game = {}

function love.load()
  
  image = love.graphics.newImage('images/barcamp.png')

  logos = {}

  maxlogos = 5

  score = 0

end

function love.keypressed(key)
  if key == 'escape' then
    love.event.push('q')
  end
end

function love.mousepressed(x, y, button)
  
  local toRemove = {}
  
  for i, logo in ipairs(logos) do
    if logo:containsPoint(vector(x, y)) then
      table.insert(toRemove, i)
      score = score + 1
    end
  end

  for i, v in ipairs(toRemove) do
    table.remove(logos, v - i + 1)
  end
  
end

function addLogo()
  local logo = Logo(image)
  table.insert(logos, logo)
end

function love.update(dt)
  if #logos < maxlogos then
    addLogo()
  end
  
  local toRemove = {}
  
  for i, logo in ipairs(logos) do
    logo:update(dt)
    
    if logo.position.y > love.graphics.getHeight() then
      table.insert(toRemove, i)
    end
  end

  for i, v in ipairs(toRemove) do
    table.remove(logos, v - i + 1)
  end

end

function love.draw()
  love.graphics.print(string.format('YOUR SCORE IS: %i', score), 10, 10)
  
  for i, logo in ipairs(logos) do
    logo:draw()
  end
  
end