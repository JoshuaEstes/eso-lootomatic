--[[
--
-- Lootomatic
--
-- Manages loot by allowing you to set filters on what you
-- want to keep and what you want to mark as junk to sell
-- at your friendly vendor.
--
--]]
local lootomatic = {}
LootomaticCommands = {} -- Container for slash commands
lootomatic.name = 'Lootomatic'
-- Used for keeping track of current filters
lootomatic.filters = {
    filterType = true
}
lootomatic.defaults = {
    debug       = true,
    sellAllJunk = true,
    filters     = lootomatic.filters
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
function lootomatic.log(text, level)
    if lootomatic.data.debug then
        d('[Lootomatic] Debug: ' .. text)
        return
    end

    d('[Lootomatic]: ' .. text)
end

--[[
-- Event trigger when loot window is closed
--
-- @param integer eventCode
--]]
function lootomatic.onLootClosed(eventCode)
    lootomatic.log('onLootClosed')
end

--[[
-- @param integer eventCode
-- @param integer reason
-- @param string  itemName
--]]
function lootomatic.onLootItemFailed(eventCode, reason, itemName)
    lootomatic.log('onLootItemFailed')
    lootomatic.log('reason: ' .. reason)
    lootomatic.log('itemName' .. itemName)
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
function lootomatic.onLootReceived(eventCode, lootedBy, itemName, quantity, itemSound, lootType, isSelf)
    if (not isSelf) then return end
    lootomatic.log('onLootReceived')
    local i = LootItem.New(itemName)
    lootomatic.log('Obtained Item: ' .. i.name)
end

--[[
-- @param integer eventCode
--]]
function lootomatic.onLootUpdated(eventCode)
    lootomatic.log('onLootUpdated')
end

--[[
-- @param integer eventCode
--]]
function lootomatic.onCloseStore(eventCode)
    lootomatic.log('onCloseStore')
end

--[[
-- @param integer eventCode
--]]
function lootomatic.onOpenStore(eventCode)
    lootomatic.log('onOpenStore')
    if lootomatic.data.sellAllJunk then
        lootomatic.log('Auto selling junk enabled')
        SellAllJunk()
        lootomatic.log('All junk items sold')
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
function lootomatic.onInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    if (not isNewItem) then return end
    lootomatic.log('onInventorySingleSlotUpdate')
    local i = LootItem.LoadByBagAndSlot(bagId, slotId)
    --[[
    -- Check filters and mark item as junk if it matches
    -- a filter
    --]]
    if i.itemType == ITEMTYPE_TRASH then
        lootomatic.log('Obtained Item is Trash, marking as Junk')
        SetItemIsJunk(bagId, slotId, true)
    end
end

--[[
--
--]]
function LootomaticCommands.Help()
    lootomatic.log('debug [true OR false]')
    lootomatic.log('filters [list OR add OR delete]')
end

--[[
--]]
function LootomaticCommands.Debug(toggle)
    if nil == toggle then
        LootomaticCommands.Help()
        return
    end
    if 'true' == toggle then
        lootomatic.data.debug = true
    elseif 'false' == toggle then
        lootomatic.data.debug = false
    else
        LootomaticCommands.Help()
        return
    end
    lootomatic.log('Updated setting')
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
    d(lootomatic.data.filters)
    --[[
    for i,v in pairs(lootomatic.data.filters) do
        d(i)
        d(v)
    end
    --]]
end

--[[
-- Used for parsing slash commands
--]]
function lootomatic.Command(parameters)
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
function lootomatic.onAddOnLoaded(eventCode, addOnName)
    if (addOnName ~= lootomatic.name) then
        return
    end
    lootomatic.data = ZO_SavedVars:New('Lootomatic_Data', 1, nil, lootomatic.defaults)

    -- Loot events
    EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_LOOT_CLOSED, lootomatic.onLootClosed)
    EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_LOOT_ITEM_FAILED, lootomatic.onLootItemFailed)
    EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_LOOT_RECEIVED, lootomatic.onLootReceived)
    EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_LOOT_UPDATED, lootomatic.onLootUpdated)

    -- Vendor events
    EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_CLOSE_STORE, lootomatic.onCloseStore)
    EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_OPEN_STORE, lootomatic.onOpenStore)

    -- Inventory Events
    EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, lootomatic.onInventorySingleSlotUpdate)

    -- Initialize slash command
    SLASH_COMMANDS['/lootomatic'] = lootomatic.Command
end

EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_ADD_ON_LOADED, lootomatic.onAddOnLoaded)
