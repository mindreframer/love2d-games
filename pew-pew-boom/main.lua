-- Example: Stateful game

require('passion.init')
require('Game')
require('Game_MainMenu.lua')
require('Game_Play.lua')

function love.load()
  math.randomseed( os.time() )
  game = Game:new()
end

function love.draw()
  passion.draw()
  game:draw()
end

function love.update(dt)
  passion.update(dt)
  game:update(dt)
end
