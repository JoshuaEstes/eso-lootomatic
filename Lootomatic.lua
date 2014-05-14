--[[
--
-- Lootomatic
--
--]]

local lootomatic = {}
lootomatic.name = 'Lootomatic'
lootomatic.defaults = {}

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
    if (not isSelf) then return end
    d('onLootReceived')
    --[[
    d('lootedBy: ' .. lootedBy)
    d('itemName: ' .. itemName)
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
end

EVENT_MANAGER:RegisterForEvent(lootomatic.name, EVENT_ADD_ON_LOADED, lootomatic.onAddOnLoaded)
