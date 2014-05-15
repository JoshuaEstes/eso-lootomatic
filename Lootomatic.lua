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
lootomatic.name = 'Lootomatic'
lootomatic.defaults = {}

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
-- @param integer eventCode
--]]
function lootomatic.onLootClosed(eventCode)
    d('onLootClosed')
end

--[[
-- @param integer eventCode
-- @param integer reason
-- @param string  itemName
--]]
function lootomatic.onLootItemFailed(eventCode, reason, itemName)
    d('onLootItemFailed')
    d('reason: ' .. reason)
    d('itemName' .. itemName)
end

--[[
-- @param integer eventCode
-- @param string  lootedBy
-- @param string  itemName
-- @param integer quantity
-- @param integer itemSound
-- @param integer lootType
-- @param boolean isSelf
--]]
function lootomatic.onLootReceived(eventCode, lootedBy, itemName, quantity, itemSound, lootType, isSelf)
    d('onLootReceived')
    if (not isSelf) then return end
    local i = LootItem.New(itemName)
    --d(i)
    --[[
	local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo(itemName)
    d('itemName: ' .. i.GetName())
    d('lootedBy: ' .. lootedBy)
    d('quantity: ' .. quantity)
    d('itemSound: ' .. itemSound)
    d('lootType: ' .. lootType)
    --]]
end

--[[
-- @param integer eventCode
--]]
function lootomatic.onLootUpdated(eventCode)
    d('onLootUpdated')
end

--[[
-- @param integer eventCode
--]]
function lootomatic.onCloseStore(eventCode)
    d('onCloseStore')
end

--[[
-- @param integer eventCode
--]]
function lootomatic.onOpenStore(eventCode)
    d('onOpenStore')
    SellAllJunk()
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
    d('onInventorySingleSlotUpdate')
    if (not isNewItem) then
        return
    end
    local i = LootItem.LoadByBagAndSlot(bagId, slotId)
    if i.itemType == ITEMTYPE_TRASH then
        SetItemIsJunk(bagId, slotId, true)
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
end

EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_ADD_ON_LOADED, lootomatic.onAddOnLoaded)
