showDebugInfo = false

Game = class('Game', StatefulObject)
Game:includes(Beholder)

function Game:initialize()
  super.initialize(self)

  self:gotoState('MainMenu')
  self:observe('keypressed_tab', 'toggleDebug')
end

function Game:toggleDebug()
  showDebugInfo = not showDebugInfo
end

function Game:draw()
end

function Game:update()
end
