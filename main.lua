DEBUG = false
if DEBUG then
  require 'luarocks.loader'
  require 'luacov'
end

GameEngine = require 'src.GameEngine'

function love.run()
  -- initialize and hand off to GameEngine:run()
  engine = GameEngine.GameEngine:new()
  engine:run()
end

