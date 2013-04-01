require('actors/space/vehicles/Ship')

local image = passion.graphics.getImage('images/image.png')

Razor = class('Razor', Ship)

function Razor:initialize(ai, x, y, quadTree)
  super.initialize(self, ai, x,y, 16,16,
    -- Shapes
    { circle={0,0,16} },
    -- Slots
    { frontLeft= { x=6,y=-10 },
      frontRight={ x=6,y=10 },
      back={ x=-13, y=0 }
    },
    -- Quad
    passion.graphics.newQuad(image, 32,0, 32,32),
    -- QuadTree
    quadTree,
    -- Other stuff
    { baseThrust=0.05, baseStrafeThrust=0.03, baseRotation=1.2 }
  )
end
