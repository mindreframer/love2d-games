ClassMgr = {}
ClassMgr.__index = ClassMgr

function ClassMgr.new()
    local inst = {}

    setmetatable(inst, ClassMgr)

    inst.classes = {}

    inst:initializeClass("spider", "Spider", 64, 64, 80, 100, 11, 30, 30, -32, -32, 1)
    inst:initializeClass("skeleton", "Skeleton", 32, 64, 180, 55, 17, 30, 30, -16, -48, 1)
    inst:initializeClass("ghost", "Ghost", 32, 64, 110, 80, 14, 30, 30, -16, -48, 1)
    inst:initializeClass("slime", "Slime", 24, 32, 40, 45, 25, 24, 24, -12, -16, 1)
    inst:initializeClass("bat", "Bat", 64, 32, 50, 100, 8, 32, 16, -32, -16, 1)

    inst:initializeClass("hero_knight", "HeroKnight", 64, 64, 190, 55, 13, 30, 30, -32, -48, 0.5)
    inst:initializeClass("hero_templar","HeroTemplar", 64, 64, 110, 65, 16, 30, 30, -32, -48, 0.5)

    return inst
end

function ClassMgr:initializeClass(id, name, width, height, health, speed, damage, colWidth, colHeight, offsetX, offsetY, attackTimeout)
    local tileset = love.graphics.newImage(artDir .. "/images/" .. id .. ".png")
    local inst = {}

    inst.name = name
    inst.health = health
    inst.moveSpeed = speed
    inst.damage = damage
    inst.width = width
    inst.height = height
    inst.tileset = tileset
    inst.portrait = love.graphics.newImage(artDir .. "/images/portrait_" .. id .. ".png")
    inst.down = {}
    inst.up = {}
    inst.left = {}
    inst.right = {}

    inst.colWidth = colWidth
    inst.colHeight = colHeight
    inst.offsetX = offsetX
    inst.offsetY = offsetY
    inst.attackTimeout = attackTimeout

    local list = {inst.down, inst.up, inst.left, inst.right}

    table.insert(self.classes, inst)

    local quad

    for y = 0, 2, 1 do
        for x = 0, 2, 1 do
            quad = love.graphics.newQuad(x * width, y * height, width, height, tileset:getWidth(), tileset:getHeight())

            table.insert(list[y + 1], quad)
        end
    end

    for x = 0, 2, 1 do
        quad = love.graphics.newQuad(x * width, 2 * height, width, height, tileset:getWidth(), tileset:getHeight())
        quad:flip(true, false)
        table.insert(list[4], quad)
    end

end

function ClassMgr:random()
end

return ClassMgr
