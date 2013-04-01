LCG = {}
LCG.__index = LCG

function LCG.new(seed)
    local inst = {}

    setmetatable(inst, LCG)

    inst.seed = seed
    inst.series = {seed}

    return inst
end

function LCG:seed(seed)
    self.seed = seed
    self.series = {seed}
end

function LCG:random()
    local len = table.getn(self.series)
    local xn = self.series[len]

    table.insert(self.series, (25214903917 * xn + 11) % 281474976710656)

    return self.series[len] / 281474976710656
end

return LCG
