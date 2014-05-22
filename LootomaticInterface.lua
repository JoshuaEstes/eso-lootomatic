--[[
-- Lootomatic GUI Interface
--]]

LootomaticInterface = {}
LootomaticInterface.__index = LootomaticInterface
local LAM = LibStub( 'LibAddonMenu-1.0' )

function LootomaticInterface.New()
    local self = setmetatable({}, LootomaticInterface)
	self.panel = LAM:CreateControlPanel("LootomaticSettingsPanel", "Lootomatic")
	LAM:AddHeader(self.panel, "Lootomatic_Header_Configuration", "Configuration")
    LAM:AddCheckbox(self.panel, 'debug', 'Debug', 'Tooltip',
        function() return true end,
        function() self:Test() end)
	LAM:AddHeader(self.panel, "Lootomatic_Header_Filters", "Filters")
    return self
end

function LootomaticInterface:Test()
    LAM:AddCheckbox(self.panel, 'another_Filter', 'Debug', 'Tooltip',
        function() return true end,
        function() d('touched') end)
end
