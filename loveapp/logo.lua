-- 
--  logo.lua
--  BarcampRDU-2011-LuaLove
--  
--  Created by Jay Roberts on 2011-10-14.
-- 

require 'middleclass'
require 'vector'

Logo = class('Logo')

function Logo:initialize(image)
  self.image = image
  self.position = vector(math.random(0, love.graphics.getWidth()), 0)
  self.speed = math.random(50, 200)
  self.scale = 0.5
end

function Logo:containsPoint(point)
  return point.x > self.position.x and
     point.y > self.position.y and
     point.x < self.position.x + (self.image:getWidth() * self.scale) and
     point.y < self.position.y + (self.image:getHeight() * self.scale)
end


function Logo:update(dt)
  self.position.y = self.position.y + self.speed * dt
end

function Logo:draw()
  love.graphics.draw(self.image, self.position.x, self.position.y, 0, self.scale, self.scale)
end

