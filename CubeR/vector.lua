--[[ NOTES :
Bon, en fait, baser Vector sur Matrix ne semble pas être une si bonne idee
que ça. Notamment parce que si le module Matrix s'étend (avec inversions,
déterminants et tout le toutim), Vector va se servir d'une partie
microscopique tout en important tout quanqd même.

TODO : à l'occasion, y repenser et peut-être rendre Vector indépendant.
--]]

-- VECTOR
--  Module handling vectors in a basic fashion

-- CONVENTIONS :
--- arrays start at index 1
--- arrays are NIL terminated
--- vectors are one-column matrix, accessed like that : V[x][1]

-- requires :
require "matrix"

-- provides :
--  create
--  dot
--  cross
--  norm
--  printv


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function create( nRow, initValue ) -- done
  -- create a nRow vector filled with initValue.

  return matrix.create( nRow, 1, initValue )
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function dot( V1, V2 ) -- done
  -- return the result of V1 and V2 dot product

  assert( #V1 == #V2, [[Incompatible vectors dimensions for multiply]] )

  local result = 0

  for i = 1, #V1 do
    result = result + ( V1[i][1] * V2[i][1] )
  end

  return result
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function cross( V1, V2 ) -- done
  -- return the vector resulting of V1 and V2 cross product

  assert( #V1 == 3, [[Others dims than 3 not supported.]] )
  assert( #V1 == #V2, [[Incompatible vectors dimensions for multiply]] )

  local V = create( 3 )

  V[1][1] = V1[2][1]*V2[3][1] - V1[3][1]*V2[2][1]
  V[2][1] = V1[3][1]*V2[1][1] - V1[1][1]*V2[3][1]
  V[3][1] = V1[1][1]*V2[2][1] - V1[2][1]*V2[1][1]

  return V
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function norm( V ) -- done
  -- return vector V norm

  return math.sqrt( dot( V, V ) )
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function printv( V ) -- done
  -- this function only calls the matrix one. They call it syntaxic sugar

  matrix.printm( V )
end


vector =
{
  create = create,
  dot    = dot,
  cross  = cross,
  norm   = norm,
  printv = printv
}
