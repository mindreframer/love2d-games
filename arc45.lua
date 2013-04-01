-- based on "Bresenham's Circle Algorithm"

function arc45(radius)
  local points = {}

  local d = 3 - (2 * radius)
  local x = 0
  local y = radius

  while y > x do
    points[#points + 1] = {x, y}

    if d < 0 then
      d = d + (4 * x) + 6
    else
      d = d + (4 * (x - y)) + 10
      y = y - 1
    end

    x = x + 1
  end

  -- I am awesome!
  local lx, ly = unpack(points[#points])
  if (ly - lx) > 1 then
    points[#points + 1] = {x, y}
  end

  return points
end

function points45(radius)
  local points = {}

  local d = 3 - (2 * radius)
  local x = 0
  local y = radius

  while y >= x do
    points[#points + 1] = {x, y}

    if d < 0 then
      d = d + (4 * x) + 6
    else
      d = d + (4 * (x - y)) + 10
      y = y - 1
    end

    x = x + 1
  end

  return points
end

function holes45(radius)
  local points = {}

  local d = 3 - (2 * radius)
  local x = 0
  local y = radius

  while y > x do
    points[#points + 1] = {x, y}

    if d < 0 then
      d = d + (4 * x) + 6
    else
      d = d + (4 * (x - y)) + 10
      y = y - 1
    end

    x = x + 1
  end

  return points
end

function printArc(radius)
  local points = arc45(radius)
  for i=1,#points do
    local x, y = unpack(points[i])
    print (x, y)
  end
end
