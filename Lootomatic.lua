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
            rules = {
                {
                    condition = {
                        type = 'EqualTo',
                        left = { name = 'itemType', value = 48 },
                        right = { name = '', value = '' }
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
-- Displays text in the chat window
--
-- @param string  text
-- @param integer level
--]]
function Lootomatic.Log(text, level)
    local logLevel = Lootomatic.db.config.logLevel
    if nil == level then
        level = LootomaticLogger.INFO
    end

    -- logger is disabled
    if 0 == logLevel then
        return
    end

    if nil ~= logLevel and level >= logLevel then
        d('[Lootomatic] ' .. LootomaticLogger.levels[level] .. ' ' .. tostring(text))
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
    local lootItem = LootomaticItem.LoadByBagAndSlot(bagId, slotId)
    --[[
    -- Check filters and mark item as junk if it matches
    -- a filter
    --]]
    for i,v in ipairs(Lootomatic.db.filters) do
        local filter = LootomaticFilter.New(v)
        if filter:IsMatch(lootItem) then
            Lootomatic.Log('Matched filter, marking item ' .. lootItem.name .. ' as Junk', LootomaticLogger.INFO)
            SetItemIsJunk(bagId, slotId, true)
            break
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

    -- /lootomatic filters list
    if 'list' == cmd then
        LootomaticCommands.FiltersList()
        return
    end

    -- /lootomatic filters clear
    if 'clear' == cmd then
        Lootomatic.db.filters = {}
        Lootomatic.Log('Filters have been cleared', LootomaticLogger.INFO)
        return
    end

    -- /lootomatic delete 1
    if string.match(cmd, '^delete%s%d+') then
        local i = string.match(cmd, '^delete%s(%d+)')
        local filter = Lootomatic.db.filters[tonumber(i)]
        if nil == filter then
            Lootomatic.Log('There is no filter on that index', LootomaticLogger.WARN)
            return
        end
        table.remove(Lootomatic.db.filters, i)
        Lootomatic.Log('Filter has been deleted, please run /lootomatic filters list for new indexes', LootomaticLogger.INFO)
        return
    end

    -- /lootomatic filters add name:Trash enabled:true condition.type:EqualTo condition.name:itemType condition.value:48
    if string.match(cmd, '^add%s.*') then
        local filter = {
            name = nil,
            enabled = true,
            rules = {
                {
                    condition = {
                        type = nil,
                        left = { name = nil, value = nil }
                    }
                }
            }
        }
        for k,v in string.gmatch(cmd, '%s([%w\.]+):?([%w]+)%s-') do
            -- Good place for a filter builder
            if 'name' == k then
                filter.name = v
            elseif 'enabled' == k then
                filter.enabled = toboolean(v)
            elseif 'condition.type' == k then
                filter.rules[1].condition.type = v
            elseif 'condition.name' == k then
                filter.rules[1].condition.left.name = v
            elseif 'condition.value' == k then
                filter.rules[1].condition.left.value = v
            end
        end
        table.insert(Lootomatic.db.filters, filter)
        Lootomatic.Log('Added new filter', LootomaticLogger.INFO)
        return
    end

    -- /lootomatic filters modify 1 name:Trash enabled:true condition.type:EqualTo condition.name:itemType condition.value:48
    if string.match(cmd, '^modify%s%d+%s.*') then
        local i = string.match(cmd, '^modify%s(%d+)')
        local filter = Lootomatic.db.filters[tonumber(i)]
        if nil == filter then
            Lootomatic.Log('There is no filter on that index', LootomaticLogger.WARN)
            return
        end
        for k,v in string.gmatch(cmd, '%s([%w\.]+):?([%w]+)%s-') do
            -- Good place for a filter builder
            if 'name' == k then
                filter.name = v
            elseif 'enabled' == k then
                filter.enabled = toboolean(v)
            elseif 'condition.type' == k then
                filter.rules[1].condition.type = v
            elseif 'condition.name' == k then
                filter.rules[1].condition.left.name = v
            elseif 'condition.value' == k then
                filter.rules[1].condition.left.value = v
            end
        end
        Lootomatic.Log('Modified filter', LootomaticLogger.INFO)
        return
    end

    -- /lootomatic filters show 1
    if string.match(cmd, '^show%s.*') then
        local i = string.match(cmd, '^show%s(%d+)')
        local filter = Lootomatic.db.filters[tonumber(i)]
        if nil == filter then
            Lootomatic.Log('There is no filter on that index', LootomaticLogger.WARN)
            return
        end
        filter = LootomaticFilter.New(filter)
        Lootomatic.Log('Name: ' .. filter:GetName(), LootomaticLogger.INFO)
        local enabled = 'No'
        if filter:IsEnabled() then
            enabled = 'Yes'
        end
        Lootomatic.Log('Enabled: ' .. enabled, LootomaticLogger.INFO)
        Lootomatic.Log('Rules: ', LootomaticLogger.INFO)
        for i,v in pairs(filter:GetRules()) do
            local c = v.condition
            Lootomatic.Log('['..i..'] ' .. c.left.name .. ' is ' .. c.type .. ' ' .. c.left.value, LootomaticLogger.INFO)
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
        local f = LootomaticFilter.New(v)
        Lootomatic.Log('[' .. i .. '] ' .. f:GetName(), LootomaticLogger.INFO)
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
        return
    end

    -- Want to manage filters
    if options[1] == 'filters' then
        LootomaticCommands.Filters(options[2])
        return
    end

    if options[1] == 'test' then
        local var1 = Ruler.Variable.New('Filter.itemType', 48)
        local var2 = Ruler.Variable.New('itemType')
        local o = Ruler.Operator.EqualTo.New(var1, var2)
        local r = Ruler.Rule.New(o)
        local context = {
            itemType = 48
        }
        local e = r:Evaluate(context)
        d(e)
        return
    end

    LootomaticCommands.Help()
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
