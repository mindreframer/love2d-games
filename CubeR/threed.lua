-- 3D
--  Module performing some 3D engine operations

-- CONVENTIONS :
--- arrays start at index 1
--- arrays are NIL terminated
--- vectors are one-column matrix, accessed like that : V[x][1]

-- requires :
require "matrix"
require "vector"

-- provides :
--  rotate
--  project

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function rotate( bunchOfPoints, rx, ry, rz ) -- WIP
  -- rotate a bunch of 3D points around origin axis by respective amounts
  -- rx, ry and rz and return them

  local RMat    = matrix.createId( 3 )
  local tempMat = matrix.createId( 3 )

  -- generate the rotation matrix
  if rx ~= 0 then
    tempMat[2][2] = math.cos( rx )
    tempMat[2][3] = - math.sin( rx )
    tempMat[3][2] = math.sin( rx )
    tempMat[3][3] = tempMat[2][2]

    RMat = matrix.multiply( RMat, tempMat )
  end

  if ry ~= 0 then
    tempMat = matrix.createId( 3 )

    tempMat[1][1] = math.cos( ry )
    tempMat[1][3] = math.sin( ry )
    tempMat[3][1] = - math.sin( ry )
    tempMat[3][3] = tempMat[1][1]

    RMat = matrix.multiply( RMat, tempMat )
  end

  if rz ~= 0 then
    tempMat = matrix.createId( 3 )

    tempMat[1][1] = math.cos( rz )
    tempMat[1][2] = - math.sin( rz )
    tempMat[2][1] = math.sin( rz )
    tempMat[2][2] = tempMat[1][1]

    RMat = matrix.multiply( RMat, tempMat )
  end

  -- apply it to the bunch of points
  local RP = {}

  for i, p in ipairs( bunchOfPoints ) do
    RP[ i ] = matrix.multiply( RMat, p )
  end

  return RP
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function project( bunchOfPoints, K1, K2, SW, SH ) -- WIP
  -- take a bunch of 3D points and project them in a 2D space. Return the
  -- bunch of 2D projected points
  -- K1 is the distance from the viewer to the projection screen

  PC = {}

  for i, p in ipairs( bunchOfPoints ) do
    PC[ i ] = vector.create( 3 )
    
    PC[i][1][1] = SW/2 + (K1*p[1][1]) / ( K2 + p[3][1] )
    PC[i][2][1] = SH/2 - (K1*p[2][1]) / ( K2 + p[3][1] )
  end

  return PC
end


threed =
{
  rotate  = rotate,
  project = project
}
