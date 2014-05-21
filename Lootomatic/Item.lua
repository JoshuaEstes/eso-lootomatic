--[[
-- Represents an item in ESO
--
-- Item Schema
-- {
--     name                  = string,
--     color                 = string,
--     id                    = number,
--     icon                  = string,
--     sellPrice             = number,
--     meetsUsageRequirement = boolean,
--     equipType             = number,
--     itemStyle             = number,
--     itemType              = number
-- }
--
--]]

LootomaticItem = {}
LootomaticItem.__index = LootomaticItem

--[[
-- @param string itemName
--
-- @return LootomaticItem
--]]
function LootomaticItem.New(itemName)
    local self = setmetatable({data={}}, LootomaticItem)
    -- Not sure what all of these are
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
-- @return LootomaticItem
--]]
function LootomaticItem.LoadByBagAndSlot(bagId, slotId)
    local i = LootomaticItem.New(GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT))
    i.itemType = GetItemType(bagId, slotId)
    return i
end
