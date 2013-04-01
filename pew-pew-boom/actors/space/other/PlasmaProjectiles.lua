require('actors/Projectile.lua')

local image = passion.graphics.getImage('images/image.png')
local quad1 = passion.graphics.newQuad(image,  0,32, 16,16 )
local quad2 = passion.graphics.newQuad(image, 16,32, 16,16 )
local quad3 = passion.graphics.newQuad(image, 32,32, 16,16 )

PlasmaProjectile = class('PlasmaProjectile', Projectile)
function PlasmaProjectile:initialize(x,y,velX,velY,angle,groupIndex,quad,quadTree)
  super.initialize(self, x,y,velX,velY,angle,groupIndex, 0.5, 1, quad,quadTree)
end

PlasmaProjectile1 = class('PlasmaProjectile1', PlasmaProjectile)
function PlasmaProjectile1:initialize(x,y,velX,velY,angle,groupIndex,quadTree)
  super.initialize(self, x,y,velX,velY,angle,groupIndex,quad1,quadTree)
end

PlasmaProjectile2 = class('PlasmaProjectile2', PlasmaProjectile)
function PlasmaProjectile2:initialize(x,y,velX,velY,angle,groupIndex,quadTree)
  super.initialize(self, x,y,velX,velY,angle,groupIndex,quad2,quadTree)
end

PlasmaProjectile3 = class('PlasmaProjectile3', PlasmaProjectile)
function PlasmaProjectile3:initialize(x,y,velX,velY,angle,groupIndex,quadTree)
  super.initialize(self, x,y,velX,velY,angle,groupIndex,quad3,quadTree)
end
