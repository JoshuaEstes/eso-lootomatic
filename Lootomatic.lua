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
Lootomatic.version = 1

-- Defaults
Lootomatic.defaults = {
    logLevel    = 100,
    debug       = true,
    sellAllJunk = true,
    filters     = {}
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
-- eso Item class, helps to get information about an item
--]]
LootItem = {}
LootItem.__index = LootItem

--[[
-- @param string itemName
--]]
function LootItem.New(itemName)
    local self = setmetatable({}, LootItem)
    self.name,  self.color,
    self.n3,  self.id,
    self.n5,  self.n6,
    self.n7,  self.n8,
    self.n9,  self.n10,
    self.n11, self.n12,
    self.n13, self.n14,
    self.n15, self.n16,
    self.n17, self.n18,
    self.n19, self.n20,
    self.n21, self.n22,
    self.n23, self.n24 = ZO_LinkHandler_ParseLink(itemName)
    self.icon, self.sellPrice, self.meetsUsageRequirement, self.equipType, self.itemStyle = GetItemLinkInfo(itemName)
    return self
end

--[[
-- Loads an item based on where it is based on the slot in a bag
--
-- @param integer bagId
-- @param integer slotId
--]]
function LootItem.LoadByBagAndSlot(bagId, slotId)
    local i = LootItem.New(GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT))
    i.itemType = GetItemType(bagId, slotId)
    return i
end

--[[
-- Displays text in the chat window
--
-- @param string  text
-- @param integer level
--]]
function Lootomatic.Log(text, level)
    local defaultLogLevel = Lootomatic.db.logLevel
    -- if logLevel not set, set to default
    if nil ~= level then
        level = defaultLogLevel
    end
    -- disabled logger
    if 0 == level then
        return
    end
    -- Print DEBUG messages
    if 100 >= level then
        d('[Lootomatic] ' .. LootomaticLogger.levels[level] .. ' ' .. text)
        return
    end
    -- Print INFO messages
    if 200 >= level then
        d('[Lootomatic] ' .. LootomaticLogger.levels[level] .. ' ' .. text)
        return
    end
    -- Print WARN messages
    if 300 >= level then
        d('[Lootomatic] ' .. LootomaticLogger.levels[level] .. ' ' .. text)
        return
    end
end

--[[
-- Event trigger when loot window is closed
--
-- @param integer eventCode
--]]
function Lootomatic.OnLootClosed(eventCode)
    Lootomatic.Log('onLootClosed', LootomaticLogger.DEBUG)
end

--[[
-- @param integer eventCode
-- @param integer reason
-- @param string  itemName
--]]
function Lootomatic.OnLootItemFailed(eventCode, reason, itemName)
    Lootomatic.Log('onLootItemFailed', LootomaticLogger.DEBUG)
    Lootomatic.Log('reason: ' .. reason, LootomaticLogger.DEBUG)
    Lootomatic.Log('itemName' .. itemName, LootomaticLogger.DEBUG)
end

--[[
-- Event that is triggered for every loot item received
--
-- @param integer eventCode
-- @param string  lootedBy
-- @param string  itemName
-- @param integer quantity
-- @param integer itemSound
-- @param integer lootType
-- @param boolean isSelf
--]]
function Lootomatic.OnLootReceived(eventCode, lootedBy, itemName, quantity, itemSound, lootType, isSelf)
    if (not isSelf) then return end
    Lootomatic.Log('onLootReceived', LootomaticLogger.DEBUG)
    local i = LootItem.New(itemName)
    Lootomatic.Log('Obtained Item: ' .. i.name, LootomaticLogger.DEBUG)
end

--[[
-- @param integer eventCode
--]]
function Lootomatic.OnLootUpdated(eventCode)
    Lootomatic.Log('onLootUpdated', LootomaticLogger.DEBUG)
end

--[[
-- @param integer eventCode
--]]
function Lootomatic.OnCloseStore(eventCode)
    Lootomatic.Log('onCloseStore', LootomaticLogger.DEBUG)
end

--[[
-- @param integer eventCode
--]]
function Lootomatic.OnOpenStore(eventCode)
    Lootomatic.Log('onOpenStore', LootomaticLogger.DEBUG)
    if Lootomatic.db.sellAllJunk then
        Lootomatic.Log('Auto selling junk enabled', LootomaticLogger.DEBUG)
        SellAllJunk()
        Lootomatic.Log('All junk items sold', LootomaticLogger.DEBUG)
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
    local i = LootItem.LoadByBagAndSlot(bagId, slotId)
    --[[
    -- Check filters and mark item as junk if it matches
    -- a filter
    --]]
    if i.itemType == ITEMTYPE_TRASH then
        Lootomatic.Log('Obtained Item is Trash, marking as Junk', LootomaticLogger.INFO)
        SetItemIsJunk(bagId, slotId, true)
    end
end

--[[
--
--]]
function LootomaticCommands.Help()
    Lootomatic.Log('debug [true OR false]', LootomaticLogger.INFO)
    Lootomatic.Log('filters [list OR add OR delete]', LootomaticLogger.INFO)
end

--[[
--]]
function LootomaticCommands.Debug(toggle)
    if nil == toggle then
        LootomaticCommands.Help()
        return
    end
    if 'true' == toggle then
        Lootomatic.db.debug = true
    elseif 'false' == toggle then
        lootomatic.db.debug = false
    else
        LootomaticCommands.Help()
        return
    end
    Lootomatic.Log('Updated setting', LootomaticLogger.DEBUG)
end

--[[
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
end

function LootomaticCommands.FiltersList()
    d(lootomatic.db.filters)
    --[[
    for i,v in pairs(Lootomatic.db.filters) do
        d(i)
        d(v)
    end
    --]]
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

    if options[1] == 'debug' then
        LootomaticCommands.Debug(options[2])
    end

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

    -- Loot events
    EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_LOOT_CLOSED, Lootomatic.OnLootClosed)
    EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_LOOT_ITEM_FAILED, Lootomatic.OnLootItemFailed)
    EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_LOOT_RECEIVED, Lootomatic.OnLootReceived)
    EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_LOOT_UPDATED, Lootomatic.OnLootUpdated)

    -- Vendor events
    EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_CLOSE_STORE, Lootomatic.OnCloseStore)
    EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_OPEN_STORE, Lootomatic.OnOpenStore)

    -- Inventory Events
    EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Lootomatic.OnInventorySingleSlotUpdate)

    -- Initialize slash command
    SLASH_COMMANDS['/lootomatic'] = Lootomatic.Command
end

EVENT_MANAGER:RegisterForEvent(Lootomatic.name, EVENT_ADD_ON_LOADED, Lootomatic.OnAddOnLoaded)
