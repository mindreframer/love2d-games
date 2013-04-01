-- MATRIX
--  Module handling matrixes in a basic fashion

-- CONVENTIONS :
--- arrays start at index 1
--- arrays are NIL terminated
--- vectors are one-column matrix, accessed like that : V[x][1]

-- requires : NONE

-- provides :
--  create
--  createId
--  multiply
--  printm

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function create( nRow, nCol, initValue ) -- done
  -- create a nRow x nCol matrix filled with initValue
  -- if nCol isn't specified, a nRow x nRow square matrix is created

  initValue = initValue or 0
  nCol      = nCol or nRow

  local M = {}

  for i = 1, nRow do
    M[ i ] = {}

    for j = 1, nCol do
      M[ i ][ j ] = initValue
    end
  end

  return M
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function createId( nRow ) -- done
  -- create a square identity matrix of dimension nRow x nRow

  local I = create( nRow, nRow, 0 )

  for i = 1, nRow do
    I[i][i] = 1
  end

  return I
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function add( A, B )
  local ANRow = #A
  local ANCol = #( A[1] )
  local BNRow = #B
  local BNCol = #( B[1] )

  assert( ANCol == BNCol and ANRow == BNRow, [[Incompatibles matrixes
    dimensions for addition.]] )

  local R = create( ANRow, ANCol )

  for i = 1, ANRow do
    for j = 1, ANCol do
      R[i][j] = A[i][j] + B[i][j]
    end
  end

  return R
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function multiply( A, B ) -- done
  -- Multiply the matrix A by the matrix B and return the result

  local ANRow = #A
  local ANCol = #( A[1] )
  local BNRow = #B
  local BNCol = #( B[1] )

  -- perform size check : A's number of rows must equal B's number of
  -- columns
  assert( ANCol == BNRow, [[Incompatibles matrixes
    dimensions for multiply]] )

  local Y = create( ANRow, BNCol )

  for jB = 1, BNCol do
    for iA = 1, ANRow do
      for jA = 1, ANCol do
        Y[iA][jB] = Y[iA][jB] + A[iA][jA]*B[jA][jB]
      end
    end
  end

  return Y
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function printm( M ) -- done

  local line

  for i, v in ipairs( M ) do
    line = ""

    for j, value in ipairs( v ) do
      line = line .. value .. " "
    end

    print( line )
  end

end

matrix =
{
  create   = create,
  createId = createId,
  multiply = multiply,
  printm   = printm
}
