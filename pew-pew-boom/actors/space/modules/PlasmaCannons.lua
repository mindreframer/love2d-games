require('actors/Module.lua')
require('actors/Weapon.lua')
require('actors/Projectile.lua')
require('actors/space/other/PlasmaProjectiles.lua')

local image = passion.graphics.getImage('images/image.png')
local source = passion.audio.getSource( 'sfx/pew.mp3', 'static', 4 )
local quad1 = passion.graphics.newQuad( image,  0,48, 16,16 )
local quad2 = passion.graphics.newQuad( image, 17,48, 16,16 )
local quad3 = passion.graphics.newQuad( image, 33,48, 16,16 )

PlasmaCannon = class('PlasmaCannon', Weapon)
function PlasmaCannon:initialize(coolDown, projectileClass, quad)
  super.initialize(self, 8,8, coolDown, projectileClass, quad, source)
end

PlasmaCannon1 = class('PlasmaCannon1', PlasmaCannon)
function PlasmaCannon1:initialize()
  super.initialize(self, 0.75, PlasmaProjectile1, quad1)
end

PlasmaCannon2 = class('PlasmaCannon2', PlasmaCannon)
function PlasmaCannon2:initialize()
  super.initialize(self, 0.5, PlasmaProjectile2, quad2)
end

PlasmaCannon3 = class('PlasmaCannon3', PlasmaCannon)
function PlasmaCannon3:initialize()
  super.initialize(self, 0.4, PlasmaProjectile3, quad3)
end
