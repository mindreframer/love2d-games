module(..., package.seeall)

           require 'libs/middleclass/middleclass'
Stateful = require 'libs/stateful/stateful'
Beholder = require 'libs/beholder/beholder'
Tween    = require 'libs/tween/tween'

GameEngine = class('GameEngine')

function GameEngine:initialize()
  self.keysPressed = {}
  love.graphics.setMode(0, 0, true)
end

function GameEngine:run()
  -- keep it random
  math.randomseed(os.time())
  math.random() math.random()
  local dt = 0

  -- main loop
  while true do
    if love.event then
      love.event.pump()
      for e, a, b, c, d in love.event.poll() do
        if DEBUG then print(e, a, b, c, d) end
        if e == "quit" then
          self:quit()
          return
        elseif e == "keypressed" then
          self:keyPressed(a, b)
        elseif e == "keyreleased" then
          self:keyReleased(a, b)
        elseif e == "mousepressed" then
          self:mouseClicked(a, b, c)
        elseif e == "mousereleased" then
          self:mouseReleased(a, b, c)
        end
      end
    end

    -- update dt
    if love.timer then
      love.timer.step()
      dt = love.timer.getDelta()
    end

    -- call update
    self:update(dt)

    -- call draw
    love.graphics.clear()
    self:draw()

    if love.timer then love.timer.sleep(0.001) end
    if love.graphics then love.graphics.present() end

  end
end

function GameEngine:update(dt)
end

function GameEngine:draw()
end

function GameEngine:keyPressed(key)
  self.keysPressed[key] = true
  return true
end

function GameEngine:keyReleased(key)
  self.keysPressed[key] = false
  if key == 'escape' then
    love.event.push 'quit'
  end
  return true
end

function GameEngine:isKeyPressed(key)
  return self.keysPressed[key] == true
end

function GameEngine:mouseClicked(x, y, button)
end

function GameEngine:mouseReleased(x, y, button)
end

function GameEngine:quit()
end

