require('mixins/PacManLike.lua')
require('mixins/DebugDraw.lua')
require('mixins/HasGroupIndex.lua')
require('mixins/AutoCamerable.lua')


Projectile = class('Projectile', passion.physics.Actor)
Projectile:includes(PacManLike)
Projectile:includes(DebugDraw)
Projectile:includes(HasGroupIndex)
Projectile:includes(AutoCamerable)

function Projectile:initialize(x,y,velX,velY,angle,groupIndex,duration,impulse,quad,quadTree)
  super.initialize(self)

  self:newBody()
  self:setBullet(true)

  self:newRectangleShape(-5,-2,10,4)
  self:setCenter(8,8)
  self:setMassFromShapes()
  self:setGroupIndex(groupIndex)

  self:setPosition(x,y)
  self:setAngle(angle)
  self:setLinearVelocity(velX, velY)
  self:applyImpulse(math.cos(angle)*impulse, math.sin(angle)*impulse)

  self.quad = quad
  self.quadTree = quadTree
  self.quadTree:insert(self)

  self:after(duration, 'destroy')
end

function Projectile:update()
  self:pacManCheck()
end

function Projectile:destroy()
  self.quadTree:remove(self)
  super.destroy(self)
end
