-- CONVENTIONS :
--- arrays start at index 1
--- arrays are NIL terminated
--- vectors are one-column matrix, accessed like that : V[x][1]

-- requires :
require "vector"
require "threed"


function makeCube( dim ) -- done
  -- Return a bunch (8) of 3D points representing a 3D cube of dim size
  -- centered on the Z axis with an offset of dist from the origin

  -- so at the end of the day both faces are stored one sequentially

  local cube = {}

  local hdim = dim/2

  local cur_pt

  -- i iterates along the X axis, j along Y and k along Z
  for k = 1, 2 do
    for j = 1, 2 do
      for i = 1, 2 do
        cur_pt = vector.create( 3 )

        cur_pt[1][1] = -hdim + (i-1)*dim 
        cur_pt[2][1] = -hdim + (j-1)*dim
        cur_pt[3][1] = -hdim + (k-1)*dim

        cube[ i + 2*(j-1) + 4*(k-1) ] = cur_pt
      end
    end
  end

  return cube
end


function love.load()
  -- the cube we are rendering - 3D points
  C = makeCube(10)

  -- projected cube on the screen - 2D points
  PC = {}

  -- distance to the screen, to the object
  distScreen = 300
  distObject = 20

  -- screen's dimensions
  SW = 640
  SH = 400

  love.graphics.setMode( SW, SH )

  -- speed rotations around, well, X and Y axis
  SRX = 0.4
  SRY = 0.7
  RDamp = 0.01

  -- set background and painting colors
  love.graphics.setBackgroundColor( 0, 0, 0 )
  love.graphics.setColor( 255, 255, 255 )

  -- point where the user pressed the left button
  FPLB = vector.create(2)
  PLB = vector.create(2)

  -- other variables
  fps = 0
end

function love.mousepressed( x, y, button )
  if button == 'wd'and distScreen > 10 then
    distScreen = distScreen - 10
  elseif button == 'wu' then
    distScreen = distScreen + 10
  elseif button == 'l' then
    FPLB[1][1] = x
    FPLB[2][1] = y
    PLB[1][1] = x
    PLB[2][1] = y
  end

end

function love.mousereleased( x, y, button )
  if button == 'l' then -- engage free glide !
    SRY = -( x - FPLB[1][1] )*RDamp
    SRX = -( y - FPLB[2][1] )*RDamp
  end
end

function love.update( dt )
  -- update fps
  fps = 1/dt

  -- compute  speed rotations
  local drx = SRX * dt
  local dry = SRY * dt

  if love.mouse.isDown( 'l' ) then -- the user is rotating the cube
    dry = -( love.mouse.getX() - PLB[1][1] ) * RDamp
    drx = -( love.mouse.getY() - PLB[2][1] ) * RDamp

    PLB[1][1] = love.mouse.getX()
    PLB[2][1] = love.mouse.getY()
  end

  -- rotate the cube

  C = threed.rotate( C, drx, dry, 0 )

  -- get the cube's projection on the screen
  PC = threed.project( C, distScreen, distObject, SW, SH )

end

function love.draw()
  -- draw some shit
  love.graphics.print( "Cube renderer !", 10, 10 )
  love.graphics.print( "SRX : " .. SRX, 10, 22 )
  love.graphics.print( "SRY : " .. SRY, 10, 34 )
  love.graphics.print( "distScreen : " .. distScreen, 10, 46 )
  love.graphics.print( "FPS : " .. fps, 10, 58 )

  -- draw the points / lines between points
  love.graphics.line( PC[1][1][1], PC[1][2][1], PC[2][1][1], PC[2][2][1] )
  love.graphics.line( PC[1][1][1], PC[1][2][1], PC[3][1][1], PC[3][2][1] )
  love.graphics.line( PC[1][1][1], PC[1][2][1], PC[5][1][1], PC[5][2][1] )
  love.graphics.line( PC[4][1][1], PC[4][2][1], PC[2][1][1], PC[2][2][1] )
  love.graphics.line( PC[4][1][1], PC[4][2][1], PC[3][1][1], PC[3][2][1] )
  love.graphics.line( PC[4][1][1], PC[4][2][1], PC[8][1][1], PC[8][2][1] )
  love.graphics.line( PC[6][1][1], PC[6][2][1], PC[2][1][1], PC[2][2][1] )
  love.graphics.line( PC[6][1][1], PC[6][2][1], PC[5][1][1], PC[5][2][1] )
  love.graphics.line( PC[6][1][1], PC[6][2][1], PC[8][1][1], PC[8][2][1] )
  love.graphics.line( PC[7][1][1], PC[7][2][1], PC[3][1][1], PC[3][2][1] )
  love.graphics.line( PC[7][1][1], PC[7][2][1], PC[5][1][1], PC[5][2][1] )
  love.graphics.line( PC[7][1][1], PC[7][2][1], PC[8][1][1], PC[8][2][1] )
end

function love.keypressed( key, unicode )
  -- quit the game if the user presses escape
  if key == 'escape' then
    love.event.push( 'q' )
  end
end
