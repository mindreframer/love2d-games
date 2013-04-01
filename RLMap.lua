-- TODO: learn about metatables etc
-- TODO: create grass, stone, and other generic types (right now the default is grass)

-- TODO: move RLMapTile to its own file?
RLMapTile = {}

function RLMapTile.new(args)
  local args = args or {}

  -- TODO: make this a bit better to avoid the nil/false confusion as before (probably with a metatable)
  local ret = {
    display = args.display or ".",
    color = args.color or {0, math.random(255), 0, 255},  -- TODO: create a colour table?
    movement = args.movement or "true",
  }

  return ret
end

RLMap = {}

function RLMap.new(args)
  local args = args or {}

  -- defaults
  local ret = {
    height = args.height or 25,
    width = args.width or 80,
  }

  for i=1,ret.height do
    local column = {}
    for j=1,ret.width do
      column[j] = RLMapTile.new(args.tile)
    end
    ret[i] = column
  end

  return ret
end
