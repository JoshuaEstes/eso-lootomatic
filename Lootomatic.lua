--[[
--
-- Lootomatic
--
-- Manages loot by allowing you to set filters on what you
-- want to keep and what you want to mark as junk to sell
-- at your friendly vendor.
--
--]]
local Lootomatic   = {}
Lootomatic.name    = 'Lootomatic'
Lootomatic.version = 2

Lootomatic.RulesEngine = {}
Lootomatic.RulesEngine.Rule = {}
Lootomatic.RulesEngine.Rule.__index = Lootomatic.RulesEngine.Rule
--[[
-- @param table condition
-- @return Rule
--]]
function Lootomatic.RulesEngine.Rule.New(condition)
    local self = setmetatable({['condition'] = condition}, Lootomatic.RulesEngine.Rule)
    return self
end

--[[
-- @param table context
-- @return boolean
--]]
function Lootomatic.RulesEngine.Rule:Evaluate(context)
    return self.condition.evaluate(context)
end
Lootomatic.RulesEngine.Value = {}
Lootomatic.RulesEngine.Value.__index = Lootomatic.RulesEngine.Value
--[[
-- @param mixed value
-- @return Value
--]]
function Lootomatic.RulesEngine.Value.New(value)
    local self = setmetatable({['value'] = value}, Lootomatic.RulesEngine.Value)
    return self
end
--[[
-- @return mixed
--]]
function Lootomatic.RulesEngine.Value:GetValue()
    return self.value
end
--[[
-- @param Value value
-- @return boolean
--]]
function Lootomatic.RulesEngine.Value:EqualTo(value)
    return (self.value == value:GetValue())
end
--[[
-- @param Value value
-- @return boolean
--]]
function Lootomatic.RulesEngine.Value:Contains(value)
end
--[[
-- @param Value value
-- @return boolean
--]]
function Lootomatic.RulesEngine.Value:GreaterThan(value)
    return (self.value > value:GetValue())
end
--[[
-- @param Value value
-- @return boolean
--]]
function Lootomatic.RulesEngine.Value:LessThan(value)
    return (self.value < value:GetValue())
end
Lootomatic.RulesEngine.Variable = {}
Lootomatic.RulesEngine.Variable.__index = Lootomatic.RulesEngine.Variable
--[[
-- @param string name
-- @param mixed value
-- @return Variable
--]]
function Lootomatic.RulesEngine.Variable.New(name, value)
    local self = setmetatable({['name'] = name, ['value'] = value}, Lootomatic.RulesEngine.Variable)
    return self
end
--[[
-- @return string
--]]
function Lootomatic.RulesEngine.Variable:GetName()
    return self.name
end
--[[
-- @return mixed
--]]
function Lootomatic.RulesEngine.Variable:GetValue()
    return self.value
end
--[[
-- @param table context
-- @return Value
--]]
function Lootomatic.RulesEngine.Variable:PrepareValue(context)
    if nil ~= self.name and nil ~= context[self.name] then
        value = context[self.value]
    else
        value = self.value
    end

    return Lootomatic.RulesEngine.Value.New(value)
end
Lootomatic.RulesEngine.ComparisonOperator = {}
Lootomatic.RulesEngine.ComparisonOperator.__index = Lootomatic.RulesEngine.ComparisonOperator
--[[
-- @param Variable
-- @param Variable
-- @return ComparisonOperator
--]]
function Lootomatic.RulesEngine.ComparisonOperator.New(left, right)
    local self = setmetatable({['left'] = left, ['right'] = right}, Lootomatic.RulesEngine.ComparisonOperator)
    return self
end
Lootomatic.RulesEngine.EqualTo = {}
Lootomatic.RulesEngine.EqualTo.__index = Lootomatic.RulesEngine.ComparisonOperator
--[[
-- @param table context
-- @return boolean
--]]
function Lootomatic.RulesEngine.EqualTo:Evaluate(context)
    return (self.left:PrepareValue(context):EqualTo(self.right))
end
Lootomatic.RulesEngine.Contains = {}
Lootomatic.RulesEngine.Contains.__index = Lootomatic.RulesEngine.ComparisonOperator
--[[
-- @param table context
-- @return boolean
--]]
function Lootomatic.RulesEngine.Contains:Evaluate(context)
    return (self.left:PrepareValue(context):Contains(self.right))
end

-- Defaults
Lootomatic.defaults = {
    config = {
        logLevel    = 200, -- Default is to only show INFO messages
        sellAllJunk = true
    },
    filters = {
        {
            name = 'Trash',
            enabled = true,
            rule = {
                condition = {
                    type = 'EqualTo',
                    variable = {
                        name = 'itemType',
                        value = ITEMTYPE_TRASH
                    }
                }
            }
        }
    }
}

-- Container for slash commands
LootomaticCommands = {}

-- Used for logging output to console
LootomaticLogger = {
    DEBUG = 100,
    INFO  = 200,
    WARN  = 300,
    levels = { [100] = 'DEBUG', [200] = 'INFO', [300] = 'WARN' }
}

--[[
-- @param mixed v
-- @return boolean
--]]
function toboolean(v)
    if (type(v) == 'string') then
        if ('yes' == v or 'y' == v or 'true' == v) then
            return true
        else
            return false
        end
    end

    if (type(v) == 'number') then
        if 0 == v then
            return false
        else
            return true
        end
    end

    if (type(v) == 'boolean') then
        return v
    end

    error('Cannot convert value to boolean')
end

--[[
-- eso Item class, helps to get information about an item
--]]
LootItem = {}
LootItem.__index = LootItem

--[[
-- @param string itemName
-- @return LootItem
--]]
function LootItem.New(itemName)
    local self = setmetatable({}, LootItem)
    self.name,  self.color, self.n3,  self.id,
    self.n5,  self.n6, self.n7,  self.n8,
    self.n9,  self.n10, self.n11, self.n12,
    self.n13, self.n14, self.n15, self.n16,
    self.n17, self.n18, self.n19, self.n20,
    self.n21, self.n22, self.n23, self.n24 = ZO_LinkHandler_ParseLink(itemName)
    self.icon, self.sellPrice, self.meetsUsageRequirement, self.equipType, self.itemStyle = GetItemLinkInfo(itemName)
    return self
end

--[[
-- Loads an item based on where it is based on the slot in a bag
--
-- @param integer bagId
-- @param integer slotId
-- @return LootItem
--]]
function LootItem.LoadByBagAndSlot(bagId, slotId)
    local i = LootItem.New(GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT))
    i.itemType = GetItemType(bagId, slotId)
    return i
end

-- Loot filter, help class to find matches when loot obtained
LootFilter = {}
LootFilter.__index = LootFilter

--[[
-- @param table defaults
-- @return LootFilter
--]]
function LootFilter.New(defaults)
    local self = setmetatable(defaults, LootFilter)
    return self
end

--[[
-- Checks to see if item matches a filter
--
-- @param LootItem lootItem
-- @return boolean
--]]
function LootFilter:IsMatch(lootItem)
    if (self.itemType == lootItem.itemType) then
        return true
    end

    return false
end

--[[
-- Displays text in the chat window
--
-- @param string  text
-- @param integer level
--]]
function Lootomatic.Log(text, level)
    local logLevel = Lootomatic.db.config.logLevel

    -- logger is disabled
    if 0 == logLevel then
        return
    end

    if level >= logLevel then
        d('[Lootomatic] ' .. LootomaticLogger.levels[level] .. ' ' .. text)
        return
    end
end

--[[
-- @param integer eventCode
--]]
function Lootomatic.OnOpenStore(eventCode)
    Lootomatic.Log('onOpenStore', LootomaticLogger.DEBUG)
    if Lootomatic.db.config.sellAllJunk then
        SellAllJunk()
        Lootomatic.Log('All junk items sold', LootomaticLogger.INFO)
    end
end

--[[
-- @param integer eventCode
-- @param integer bagId
-- @param integer slotId
-- @param boolean isNewItem
-- @param integer itemSoundCategory
-- @param integer updateReason
--]]
function Lootomatic.OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    if (not isNewItem) then return end
    Lootomatic.Log('onInventorySingleSlotUpdate', LootomaticLogger.DEBUG)
    local lootItem = LootItem.LoadByBagAndSlot(bagId, slotId)
    --[[
    -- Check filters and mark item as junk if it matches
    -- a filter
    --]]
    for i,v in ipairs(Lootomatic.db.filters) do
        local lootFilter = LootFilter.New(v)
        if lootFilter:IsMatch(lootItem) then
            Lootomatic.Log('Matched filter, marking item ' .. lootItem.name .. ' as Junk', LootomaticLogger.INFO)
            SetItemIsJunk(bagId, slotId, true)
        end
    end
end

--[[
-- Display help
--]]
function LootomaticCommands.Help(cmd)
    Lootomatic.Log('config <key> <value>', LootomaticLogger.INFO)
    Lootomatic.Log('filters [list OR add OR delete OR show]', LootomaticLogger.INFO)
end

--[[
-- Manage configuration settings
--
-- @param string cmd
--]]
function LootomaticCommands.Config(cmd)
    if 'list' == cmd then
        d(Lootomatic.db.config)
        return
    end

    local options = { string.match(cmd,"^(%S*)%s*(.*)$") }

    if nil == options[1] or nil == options[2] then
        LootomaticCommands.Help()
        return
    end

    local config = Lootomatic.db.config

    if 'loglevel' == options[1] then
        newLogLevel = tonumber(options[2])
        -- @TODO check to make sure newLogLevel is valid value
        config.logLevel = newLogLevel
        Lootomatic.Log('Updated configuration', LootomaticLogger.INFO)
        return
    end

    if 'sellalljunk' == options[1] then
        config.sellAllJunk = toboolean(options[2])
        Lootomatic.Log('Updated configuration', LootomaticLogger.INFO)
        return
    end

    LootomaticCommands.Help()
end

--[[
-- What filter command to run
--
-- @param string cmd
--]]
function LootomaticCommands.Filters(cmd)
    if nil == cmd then
        LootomaticCommands.Help()
        return
    end

    if 'list' == cmd then
        LootomaticCommands.FiltersList()
        return
    end

    if 'clear' == cmd then
        Lootomatic.db.filters = {}
        -- @TODO remove this filter
        local f = LootFilter.New({itemType = ITEMTYPE_TRASH, displayName = 'Trash'})
        table.insert(Lootomatic.db.filters, f)
        Lootomatic.Log('Filters have been cleared', LootomaticLogger.INFO)
        return
    end

    if string.match(cmd, '^add%s.*') then
        local filter = {itemType = nil, displayName = nil}
        for k,v in string.gmatch(cmd, '%s([%w]+):?([%w]+)%s-') do
            if 'itemtype' == k then
                filter['itemType'] = tonumber(v)
            elseif 'displayname' == k then
                filter['displayName'] = v
            else
                filter[k] = v
            end
        end
        table.insert(Lootomatic.db.filters, filter)
        Lootomatic.Log('Added new filter', LootomaticLogger.INFO)
        return
    end

    if string.match(cmd, '^modify%s.*') then
        return
    end

    if string.match(cmd, '^show .*') then
        local i = string.match(cmd, '^show (%d+)')
        local filter = Lootomatic.db.filters[tonumber(i)]
        for i,v in pairs(filter) do
            Lootomatic.Log(i .. ': ' .. v, LootomaticLogger.INFO)
        end
        return
    end

    LootomaticCommands.Help()
end

--[[
-- List all known filters
--]]
function LootomaticCommands.FiltersList()
    for i,v in pairs(Lootomatic.db.filters) do
        local displayName = ''
        if v.displayName then
            displayName = v.displayName
        end
        Lootomatic.Log('[' .. i .. '] ' .. displayName, LootomaticLogger.INFO)
    end
end

--[[
-- Used for parsing slash commands
--]]
function Lootomatic.Command(parameters)
    local options = {}
    local searchResult = { string.match(parameters,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
    if #options == 0 or options[1] == "help" then
        LootomaticCommands.Help()
        return
    end

    if options[1] == 'config' then
        LootomaticCommands.Config(options[2])
    end

    -- Want to manage filters
    if options[1] == 'filters' then
        LootomaticCommands.Filters(options[2])
    end
end

--[[
-- @param integer eventCode
-- @param string  addOnName
--]]
function Lootomatic.OnAddOnLoaded(eventCode, addOnName)
    if (addOnName ~= Lootomatic.name) then
        return
    end
    Lootomatic.db = ZO_SavedVars:New('Lootomatic_Data', 1, nil, Lootomatic.defaults)

    -- Vendor events
    EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_OPEN_STORE, Lootomatic.OnOpenStore)

    -- Inventory Events
    EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Lootomatic.OnInventorySingleSlotUpdate)

    -- Initialize slash command
    SLASH_COMMANDS['/lootomatic'] = Lootomatic.Command
end

EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_ADD_ON_LOADED, Lootomatic.OnAddOnLoaded)
