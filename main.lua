-- to do:
-- how to stop world on push/pop?

require 'PhysicalSceneController'
require 'PhysicalObject'
require 'FallingSceneController'

function love.load()
    local scene = FallingSceneController:new()

    pushSceneController(scene)
end

function love.update(dt)
    sceneControllers[sceneControllersCount]:update(dt)
end

function love.draw()
    sceneControllers[sceneControllersCount]:draw()
end

function love.mousepressed(x, y, button)
    sceneControllers[sceneControllersCount]:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    sceneControllers[sceneControllersCount]:mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
    sceneControllers[sceneControllersCount]:keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
    sceneControllers[sceneControllersCount]:keyreleased(key, unicode)
end

function love.focus(f)
    -- sceneControllers[sceneControllersCount]:focus(f)
end

function love.quit()
end
