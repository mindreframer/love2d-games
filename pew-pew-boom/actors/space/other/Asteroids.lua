require('mixins/PacManLike')
require('mixins/BodyBuilder')
require('mixins/DebugDraw')
require('mixins/AutoCamerable')

local twoPi = math.pi * 2.0

local colors = {
  passion.colors.white,
  passion.colors.yellow,
  passion.colors.green,
  passion.colors.blue,
  passion.colors.red
}

local rnd = math.random

Asteroid = class('Asteroid', passion.physics.Actor)
Asteroid:includes(PacManLike)
Asteroid:includes(BodyBuilder)
Asteroid:includes(DebugDraw)
Asteroid:includes(AutoCamerable)

local image = passion.graphics.getImage('images/image.png')

function Asteroid:initialize(x,y,cx,cy,quad,shapes,quadTree)
  super.initialize(self)
  self:buildBody(shapes)
  self:setPosition(x,y)
  self:setCenter(cx,cy)
  self:setAngle(rnd() * twoPi)
  self:applyTorque(rnd(-1,1) * rnd())
  self:setLinearVelocity(rnd(-20,20) * rnd(), rnd(-20,20) * rnd())
  self.color = colors[rnd(1,#colors)]
  self.quad = quad
  self.quadTree = quadTree
  quadTree:insert(self)
end

function Asteroid:update(dt)
  self:pacManCheck()
end

function Asteroid:destroy()
  super.destroy(self)
  self.quadTree:remove(self)
end

BigAsteroid1 = class('BigAsteroid1', Asteroid)
function BigAsteroid1:initialize(x,y,quadTree)
  super.initialize( self, x,y, 32,32,
    passion.graphics.newQuad(image, 320,0, 64,64),
    { polygon={-28,-7 , -8,-27 , 8,-28 , 18,-19 , 25,-8 , 27,10 , 5,28 , -24,18} },
    quadTree
  )
end

BigAsteroid2 = class('BigAsteroid2', Asteroid)
function BigAsteroid2:initialize(x,y,quadTree)
  super.initialize( self, x,y, 32,32,
    passion.graphics.newQuad(image, 384,0, 64,64),
    { polygon={-21,-16 , -6,-26, 8,-27 , 23,-14 , 25,11 , 12,25 , -11,25, -25,10} },
    quadTree
  )
end

MediumAsteroid1 = class('MediumAsteroid1', Asteroid)
function MediumAsteroid1:initialize(x,y,quadTree)
  super.initialize( self, x,y, 16,16,
    passion.graphics.newQuad(image, 448,0, 32,32),
    { polygon={-6,-8 , 3,-8 , 8,-3 , 10,7 , 6,10 , -2,11 , -7,1} },
    quadTree
  )
end

MediumAsteroid2 = class('MediumAsteroid2', Asteroid)
function MediumAsteroid2:initialize(x,y,quadTree)
  super.initialize( self, x,y, 16,16,
    passion.graphics.newQuad(image, 480,0, 32,32),
    { polygon={-3,-11 , 2,-13 , 5,-8 , 7,12 , 2,13 , -8,6 , -4,1} },
    quadTree
  )
end

MediumAsteroid3 = class('MediumAsteroid3', Asteroid)
function MediumAsteroid3:initialize(x,y,quadTree)
  super.initialize( self, x,y, 16,16,
    passion.graphics.newQuad(image, 448,32, 32,32),
    { circle={-1.5, -1, 9} },
    quadTree
  )
end

SmallAsteroid1 = class('SmallAsteroid1', Asteroid)
function SmallAsteroid1:initialize(x,y,quadTree)
  super.initialize( self, x,y, 8,8 ,
    passion.graphics.newQuad(image, 480,32, 16,16),
    { polygon={-4,-3 , 1,-4 , 5,-2 , 6,4 , -3,3} },
    quadTree
  )
end

SmallAsteroid2 = class('SmallAsteroid2', Asteroid)
function SmallAsteroid2:initialize(x,y,quadTree)
  super.initialize( self, x,y, 8,8 , passion.graphics.newQuad(image, 496,32, 16,16),
    { polygon={1,-3 , 4,-3 , 4,1 , 1,4 , -3,4 , -3,1} },
    quadTree
  )
end

SmallAsteroid3 = class('SmallAsteroid3', Asteroid)
function SmallAsteroid3:initialize(x,y,quadTree)
  super.initialize( self, x,y, 8,8 , passion.graphics.newQuad(image, 480,48, 16,16),
    { polygon={4,-3 , 1,-5 , 3,-5 , 6,-2 , 6,2 , 2,6 , -2,6 , -4,4} },
    quadTree
  )
end

SmallAsteroid4 = class('SmallAsteroid4', Asteroid)
function SmallAsteroid4:initialize(x,y,quadTree)
  super.initialize( self, x,y, 8,8 , passion.graphics.newQuad(image, 496,48, 16,16),
    { polygon={-4,-2 , -1,-5 , 3,-5 , 5,-3 , 5,4 , 2,6 , -3,5 , -4,2 } },
    quadTree
  )
end



