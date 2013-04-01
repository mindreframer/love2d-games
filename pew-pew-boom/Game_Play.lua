require('actors/PlayerAI')
require('actors/space/vehicles/LensCulinaris')
require('actors/space/vehicles/Razor')
require('actors/space/modules/PlasmaCannons')
require('actors/space/modules/Thrusters')
require('actors/space/modules/Gyroscopes')
require('actors/space/other/Asteroids')
require('actors/FollowField')
require('actors/AutoCamera')

local Play = Game:addState('Play')

function Play:enterState()

  passion.physics.newWorld(3050, 3050)
  self.quadTree = passion.ai.QuadTree:new(3000, 3000)
  self.ship = LensCulinaris:new(PlayerAI:new(), 100,100, self.quadTree)
  self.field = FollowField:new(self.ship, 200, 200, self.quadTree)

  autoCamera = AutoCamera:new(self.ship)

  self.ship:attach('frontLeft', PlasmaCannon1:new() )
  self.ship:attach('frontRight', PlasmaCannon2:new())
  self.ship:attach('utility', Gyroscope1:new())
  self.ship:attach('back', Thruster1:new())

  local asteroidClasses = {
    BigAsteroid1,
    BigAsteroid2,
    MediumAsteroid1,
    MediumAsteroid2,
    MediumAsteroid3,
    SmallAsteroid1,
    SmallAsteroid2,
    SmallAsteroid3,
    SmallAsteroid4
  }

  self.asteroids = {}

  for i=1,50 do
    table.insert(self.asteroids,
      asteroidClasses[math.random(1,#asteroidClasses)]:new(
        math.random(150, 3000-150),
        math.random(150, 3000-150),
        self.quadTree
      )
    )
  end
end

function Play:exitState()
  
  autoCamera:destroy()
  autoCamera = nil

  self.ship:destroy()
  self.ship = nil

  for _,asteroid in ipairs(self.asteroids) do
    asteroid:destroy()
  end
  self.asteroids = nil

  passion.destroyWorld()
end

function Play:draw()
  if(showDebugInfo) then
    love.graphics.setColor(unpack(passion.colors.gray))
    autoCamera:draw(game.quadTree)
  end
  autoCamera:set()
  local mx, my = autoCamera:invert(love.mouse.getPosition())
  love.graphics.circle('fill', mx, my, 5, 15)
  autoCamera:unset()
  --[[autoCamera.parent:set()
  mx, my = autoCamera.parent:invert(love.mouse.getPosition())
  love.graphics.circle('fill', mx, my, 5, 15)
  autoCamera.parent:unset()
  ]]
  
end

function Play:update(dt)
  self.quadTree:update()
end
