
Game.fonts = {
  title = passion.fonts.getFont('fonts/SVBasicManual.ttf', 70),
  button = passion.fonts.getFont('fonts/SVBasicManual.ttf', 40)
}

local MainMenu = Game:addState('MainMenu')

function MainMenu:enterState()
  self.title = passion.gui.Label:new({
    text='pew pew BOOM!', 
    x=200, y=20, width=400, align='center',
    font=Game.fonts.title,
    alpha=0
  })

  self.startButton = passion.gui.Button:new({
    text='pew pew',
    x=150, y=200, width=500, valign='center',
    cornerRadius=10, padding=10,
    font=Game.fonts.button,
    onClick = function(b) game:gotoState('Play') end,
    alpha=0
  })

  self.exitButton = passion.gui.Button:new({
    text='BOOM!',
    x=150, y=400, width=500,
    cornerRadius=10, padding=10,
    font=Game.fonts.button,
    onClick = function(b) passion.exit() end,
    alpha=0
  })

  self.title:fadeIn(2)
  self.startButton:fadeIn(2)
  self.exitButton:fadeIn(2)

  self.exitButton.onMouseOver = function(obj)
    obj:effect( 1, {backgroundColor=passion.colors.red, cornerRadius=0} )
  end

end

function MainMenu:exitState()
  self.title:destroy()
  self.title = nil
  self.startButton:destroy()
  self.startButton = nil
  self.exitButton:destroy()
  self.exitButton = nil
end
