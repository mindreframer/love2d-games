require 'middleclass'

sceneControllers = {}
sceneControllersCount = 0

function pushSceneController(c)
    if sceneControllersCount < 0 then
        sceneControllers[sceneControllersCount]:stop()
    end
    table.insert(sceneControllers, c)
    sceneControllersCount = sceneControllersCount + 1
    c:pushed()
    c:start()
end

function popSceneController()
    sceneControllers[sceneControllersCount]:stop()
    sceneControllers[sceneControllersCount]:popped()
    table.remove(sceneControllers)
    sceneControllersCount = sceneControllersCount - 1
    sceneControllers[sceneControllersCount]:start()
end

SceneController = class('SceneController')

function SceneController:initialize()
    self:cancelAllTimers()
    self.screenWidth = 800
    self.screenHeight = 600
end

function SceneController:timerWithDurationAndCallback(duration, f)
    local currentTime = love.timer.getTime()
    local targetTime = currentTime + duration
    local timerData = {}
    timerData['targetTime'] = targetTime
    timerData['function'] = f
    table.insert(self.timers, timerData)
    table.sort(self.timers, function(a,b) return a['targetTime']<b['targetTime'] end)
end

function SceneController:cancelAllTimers()
    self.timers = {}
end

function SceneController:update(dt)
    local currentTime = love.timer.getTime()
    
    while self.timers[1] and self.timers[1]['targetTime'] < currentTime do
        self.timers[1]['function']()
        table.remove(self.timers, 1)
    end
end

function SceneController:draw()
end

function SceneController:mousepressed(x, y, button)
end

function SceneController:mousereleased(x, y, button)
end

function SceneController:keypressed(key, unicode)
end

function SceneController:keyreleased(key, unicode)
end

function SceneController:pushed()
end

function SceneController:popped()
end

function SceneController:start()
end

function SceneController:stop()
end
