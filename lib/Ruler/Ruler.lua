--[[
--
-- This is a port of a generic rules engine framework
-- @see https://github.com/bobthecow/Ruler
--
--]]

Ruler = {}
Ruler.Rule = {}
Ruler.Rule.__index = Ruler.Rule

--[[
-- @param table condition
-- @return Rule
--]]
function Ruler.Rule.New(condition)
    local self = setmetatable({['condition'] = condition}, Ruler.Rule)
    return self
end

--[[
-- @param table context
-- @return boolean
--]]
function Ruler.Rule:Evaluate(context)
    return self.condition:Evaluate(context)
end

Ruler.Value = {}
Ruler.Value.__index = Ruler.Value

--[[
-- @param mixed value
-- @return Value
--]]
function Ruler.Value.New(value)
    local self = setmetatable({['value'] = value}, Ruler.Value)
    return self
end

--[[
-- @return mixed
--]]
function Ruler.Value:GetValue()
    return self.value
end

--[[
-- @param Value value
-- @return boolean
--]]
function Ruler.Value:EqualTo(value)
    return (self.value == value:GetValue())
end

--[[
-- @param Value value
-- @return boolean
--]]
function Ruler.Value:Contains(value)
end

--[[
-- @param Value value
-- @return boolean
--]]
function Ruler.Value:GreaterThan(value)
    return (self.value > value:GetValue())
end

--[[
-- @param Value value
-- @return boolean
--]]
function Ruler.Value:LessThan(value)
    return (self.value < value:GetValue())
end

Ruler.Variable = Ruler.Variable or {}
Ruler.Variable.__index = Ruler.Variable

--[[
-- @param string name
-- @param mixed value
-- @return Variable
--]]
function Ruler.Variable.New(name, value)
    local self = setmetatable({['name'] = name, ['value'] = value}, Ruler.Variable)
    return self
end

--[[
-- @return string
--]]
function Ruler.Variable:GetName()
    return self.name
end

--[[
-- @return mixed
--]]
function Ruler.Variable:GetValue()
    return self.value
end

--[[
-- @param table context
-- @return Value
--]]
function Ruler.Variable:PrepareValue(context)
    if nil ~= self.name and nil ~= context[self.name] then
        value = context[self.name]
    else
        value = self.value
    end

    return Ruler.Value.New(value)
end

Ruler.Operator = {}
Ruler.Operator.ComparisonOperator = {}
Ruler.Operator.ComparisonOperator.__index = Ruler.Operator.ComparisonOperator

--[[
-- @param Variable
-- @param Variable
-- @return ComparisonOperator
--]]
function Ruler.Operator.ComparisonOperator.New(left, right)
    local self = setmetatable({['left'] = left, ['right'] = right}, Ruler.Operator.ComparisonOperator)
    return self
end

Ruler.Operator.EqualTo = {}
Ruler.Operator.EqualTo.__index = Ruler.Operator.EqualTo
function Ruler.Operator.EqualTo.New(left, right)
    local self = setmetatable({['left'] = left, ['right'] = right}, Ruler.Operator.EqualTo)
    return self
end

--[[
-- @param table context
-- @return boolean
--]]
function Ruler.Operator.EqualTo:Evaluate(context)
    return (self.left:PrepareValue(context):EqualTo(self.right:PrepareValue(context)))
end
