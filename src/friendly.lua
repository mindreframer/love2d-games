Friendly = {}
FriendlyMT = {__index = Friendly}
setmetatable(Friendly, {__index = Entity})

function Friendly.new(x, y, class)
    local inst = {}

    setmetatable(inst, FriendlyMT)

    inst.className = "friendly"
    inst.class = 0x01
    local entityClass = classMgr.classes[1]
    if type(class) == "string" then
        local classNum = 1
        for i=1, #classMgr.classes, 1 do
            if(classMgr.classes[i].name == class) then
                classNum = i
                break
            end
        end
        entityClass = classMgr.classes[classNum]
    else
        entityClass = classMgr.classes[class]
    end

    local width = entityClass.width
    local height = entityClass.height

    inst.entityClass = entityClass
    inst.cx = x
    inst.cy = y
    inst.damage = entityClass.damage
    inst.direction = 0
    inst.step = 1
    inst.stepFrac = 0
    inst.flipped = {false, false, false}
    inst.canBeControlled = true
    inst.isControlled = false
    inst.cmds = {}
    inst.color = {255, 255, 255}

    inst.moveSpeed = entityClass.moveSpeed

    inst.health = entityClass.health

    inst.collision = collider:addRectangle(x - entityClass.colWidth / 2, y - entityClass.colHeight / 2, entityClass.colWidth, entityClass.colHeight)
    inst.collision.instance = inst

    table.insert(world.entities, inst)
    table.insert(world.friendlies, inst)

    return inst
end

function Friendly:attack()
    local ignoreSet = {[self.collision] = 1}
    for i, entity in pairs(world.entities) do
        if entity.className == nil then
            table.insert(ignoreSet, entity)
        elseif entity.className ~= "enemy" then
            table.insert(ignoreSet, entity.collision)
        end
    end
    local startX = self.cx
    local startY = self.cy
    local targetX = startX
    local targetY = startY

    if self.direction == 0 then
        targetY = startY + 50
    elseif self.direction == 1 then
        targetY = startY - 50
    elseif self.direction == 2 then
        targetX = startX + 50
    elseif self.direction == 3 then
        targetX = startX - 50
    end

    local retSet = raycast(startX, startY, targetX, targetY, ignoreSet)
    if #retSet == 0 then
        return
    end
    for e, enemy in pairs(retSet) do
        enemy = enemy.instance
        if enemy ~= nil then
            if enemy.className == "enemy" then
                if(enemy.damageblinkend == nil) then
                    enemy.damageblinkend = 0.10
                    enemy.oldcolor = enemy.color
                    enemy.color = {255, 96, 96}
                end
                local damage = self.damage
                if self == control.selectedEntities[1] then
                    damage = damage * 2
                end
                enemy.health = enemy.health - damage
                if enemy.health < 0 then
                    enemy:delete()
                    world.audioMgr:playSound("die")
                else
                    world.audioMgr:playSound("hit")
                end
            end
        end
    end
end

return Friendly
