--[[
--
-- Filter Schema
-- {
--     name    = 'Display Name',
--     enabled = true,
--     rules   = { Condition, ... }
-- }
--
-- Condition Schema
-- {
--     type  = 'EqualTo',
--     left  = { Variable },
--     right = { Variable }
-- }
--
-- Variable Schame
-- {
--     name  = 'itemType',
--     value = 'value'
-- }
--
--]]

LootomaticFilter = {}
LootomaticFilter.__index = LootomaticFilter

--[[
-- @param table defaults
--
-- @return Lootomatic.Filter
--]]
function LootomaticFilter.New(defaults)
    local self = setmetatable(defaults, LootomaticFilter)
    return self
end

--[[
-- @return string
--]]
function LootomaticFilter:GetName()
    return self.name
end

--[[
-- @return boolean
--]]
function LootomaticFilter:IsEnabled()
    return self.enabled
end

--[[
-- @return table
--]]
function LootomaticFilter:GetRules()
    return self.rules
end

--[[
-- Checks to see if item matches a filter
--
-- @param LootItem lootItem
--
-- @return boolean
--]]
function LootomaticFilter:IsMatch(lootItem)
    if not self:IsEnabled() then
        return false
    end
    for i,v in pairs(self:GetRules()) do
        local o
        local c = v.condition
        --Lootomatic.Log('['..i..'] ' .. c.left.name .. ' is ' .. c.type .. ' ' .. c.left.value, LootomaticLogger.INFO)
        local var1 = Ruler.Variable.New('filter.' .. c.left.name, c.left.value)
        local var2 = Ruler.Variable.New(c.left.name)
        if 'EqualTo' == c.type then
            o = Ruler.Operator.EqualTo.New(var1, var2)
        end
        if nil ~= 0 then
            local r = Ruler.Rule.New(o)
            local e = r:Evaluate(lootItem)
            d(e)
            return e
        end
    end

    return false
end
