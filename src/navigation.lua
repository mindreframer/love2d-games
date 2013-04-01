function dist(aX, aY, bX, bY)
    return math.sqrt(math.pow(aX - bX, 2) + math.pow(aY - bY, 2))
end

function comparePath(a, b)
    return a[2] < b[2]
end

function getPath(startX, startY, targetX, targetY, ignoreSet)
    if # raycast(startX, startY, targetX, targetY, ignoreSet, nil, true, true) == 0 then
        return 0
    end

    local openSet = {}
    local inOpenSet = {}
    local inClosedSet = {}
    local cameFrom = {}
    local gScore = {}

    for a, node in pairs(world.nodes) do
        if # raycast(startX, startY, node.x, node.y, ignoreSet, nil, true, true) == 0 then
            gScore[a] = dist(node.x, node.y, startX, startY)
            local data = {a, gScore[a] + dist(node.x, node.y, targetX, targetY)}
            table.insert(openSet, data)
            inOpenSet[a] = 1
        end
    end
    
    local inTargetSet = {}
    for a, node in pairs(world.nodes) do
        if # raycast(targetX, targetY, node.x, node.y, ignoreSet, nil, true, true) == 0 then
            inTargetSet[a] = 1
        end
    end

    while # openSet ~= 0 do
        table.sort(openSet, comparePath)

        local current = table.remove(openSet, 1)
        inOpenSet[current[1]] = nil
        inClosedSet[current[1]] = 1

        if inTargetSet[current[1]] == 1 then
            return reconstructPath(cameFrom, current[1])
        end

        for a, id in pairs(world.nodes[current[1]].neighbors) do
            if inClosedSet[id] == nil then
                local x = world.nodes[id].x
                local y = world.nodes[id].y
                local tgScore = gScore[current[1]] + dist(world.nodes[current[1]].x, world.nodes[current[1]].y, x, y)
                if inOpenSet[id] == nil then
                    cameFrom[id] = current[1]
                    gScore[id] = tgScore
                    local data = {id, tgScore + dist(x, y, targetX, targetY)}
                    table.insert(openSet, data)
                    inOpenSet[id] = 1
                elseif gScore[id] ~= nil then
                    if tgScore < gScore[id] then
                        cameFrom[id] = current[1]
                        gScore[id] = tgScore
                        for b, test in pairs(openSet) do
                            if test[1] == id then
                                test[2] = tgScore + dist(x, y, targetX, targetY)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

function reconstructPath(cameFrom, current)
    if cameFrom[current] ~= nil then
        local path = reconstructPath(cameFrom, cameFrom[current])
        table.insert(path, current)
        return path
    end
    return {current}
end
