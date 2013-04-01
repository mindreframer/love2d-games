HC = require "hardoncollider"

function onCollision(dt, shapeA, shapeB, mtvX, mtvY)
    if shapeB.isWall then
        shapeA:move(mtvX, mtvY)
        local cx, cy = shapeA:center()
        shapeA.instance.cx = cx
        shapeA.instance.cy = cy
        shapeA.instance:onHitWall()
    else
        shapeA:move(mtvX / 2, mtvY / 2)
        local cx, cy = shapeA:center()
        shapeA.instance.cx = cx
        shapeA.instance.cy = cy
        shapeA.instance:onHitEntity(shapeB.instance)

        shapeB:move(-mtvX / 2, -mtvY / 2)
        cx, cy = shapeB:center()
        shapeB.instance.cx = cx
        shapeB.instance.cy = cy
        shapeB.instance:onHitEntity(shapeA.instance)
    end
end

function onCollisionStop(dt, shape_a, shape_b)
end

function boxCheck(startX, startY, endX, endY, class, ignoreSet)
    if ignoreSet == nil then
        ignoreSet = {}
    end

    local isFound = {}
    local found = {}

    for shape in pairs(collider:shapesInRange(startX, startY, endX, endY)) do
        if shape.instance ~= nil then
            if ignoreSet[shape] == nil and isFound[shape] == nil and (shape.instance.class == class or class == nil) then
                local x1, y1, x2, y2 = shape:bbox()
                if x1 < endX and y1 < endY and x2 > startX and y2 > startY then
                    isFound[shape] = 1
                    table.insert(found, shape)
                end
            end
        end
    end

    return found
end

function raycast(startX, startY, endX, endY, ignoreSet, retFirst, wallsOnly)
    local rayX = startX
    local rayY = startY
    local width = endX - startX
    local height = endY - startY
    local len = math.sqrt(math.pow(width, 2) + math.pow(height, 2))
    local dx = width / len
    local dy = height / len

    if endX < startX then
        endX, startX = startX, endX
    end
    if endY < startY then
        endY, startY = startY, endY
    end
    width = endX - startX
    height = endY - startY

    if ignoreSet == nil then
        ignoreSet = {}
    end

    if wallsOnly == nil then
        wallsOnly = false
    end

    if retFirst == nil then
        retFirst = false
    end

    local isFound = {}
    local found = {}

    for shape in pairs(collider:shapesInRange(startX, startY, endX, endY)) do
        local x1, y1, x2, y2 = shape:bbox()
        if x1 < endX and y1 < endY and x2 > startX and y2 > startY then
            if ignoreSet[shape] == nil and isFound[shape] == nil then
                if (wallsOnly and shape.isWall) or not wallsOnly then
                    local intersecting, t = shape:intersectsRay(rayX, rayY, dx, dy)
                    if intersecting then
                        if retFirst then
                            return {shape}
                        end
                        isFound[shape] = 1
                        table.insert(found, shape)
                    end
                end
            end
        end
    end

    return found
end

--[[
function raycast(startX, startY, endX, endY, ignoreSet, retFirst)
    local difX = endX - startX
    local difY = endY - startY
    local dist = math.sqrt(math.pow(difX, 2) + math.pow(difY, 2))
    local inc = 32
    local stepX = difX * inc / dist
    local stepY = difY * inc / dist
    local x = startX
    local y = startY
    local isFound = {}
    local found = {}

    if retFirst == nil then
        retFirst = true
    end

    if ignoreSet == nil then
        ignoreSet = {}
    end

    for i = 0, dist, inc do
        for _, shape in ipairs(collider:shapesAt(x, y)) do
            if ignoreSet[shape] == nil and isFound[shape] == nil then
                if retFirst then
                    return {shape}
                end
                isFound[shape] = 1
                table.insert(found, shape)
            end
        end
        x = x + stepX
        y = y + stepY
    end

    if (x - startX) > difX or (y - startY) > difY then
        x = endX
        y = endY
        for _, shape in ipairs(collider:shapesAt(x, y)) do
            if ignoreSet[shape] == nil and isFound[shape] == nil then
                if retFirst then
                    return {shape}
                end
                isFound[shape] = 1
                table.insert(found, shape)
            end
        end
    end

    return found
end
]]

return HC
