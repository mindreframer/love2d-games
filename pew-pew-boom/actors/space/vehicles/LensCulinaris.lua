require('actors/space/vehicles/Ship')

local image = passion.graphics.getImage('images/image.png')

LensCulinaris = class('LensCulinaris', Ship)

function LensCulinaris:initialize(ai, x, y, quadTree)
  super.initialize(self, ai, x,y, 16,16,
    -- Shapes
    { circle={0,0,16} },
    -- Slots
    { frontLeft= { x=6, y=-10 },
      frontRight={ x=6, y=10 },
      utility = { x=-9, y=0 },
      back={ x=-13, y=0 }
    },
    -- Quad
    passion.graphics.newQuad(image, 0,0, 32,32),
    -- QuadTree
    quadTree,
    -- Other stuff
    { baseThrust=0.01, baseStrafeThrust=0.01, baseRotation=0.5 }
  )
end
