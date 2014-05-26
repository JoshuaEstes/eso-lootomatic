--[[
--
-- Creates the Lootomatic Settings window.
--
--]]
Lootomatic_Settings = {}
Lootomatic_Settings.__index = Lootomatic_Settings
local LAM = LibStub( 'LibAddonMenu-1.0' )

--[[
-- @param table db
--]]
function Lootomatic_Settings.New(db)
    local self = setmetatable(
        {
            db    = db,
            panel = nil
        },
        Lootomatic_Settings
    )
    self:_Construct()
    return self
end

--[[
-- Returns the value of a setting
--
-- @param string name
-- @return mixed
--]]
function Lootomatic_Settings:GetSetting(name)
    return self.db.config[name];
end

--[[
-- Set a setting
--
-- @param string name
-- @param mixed value
--]]
function Lootomatic_Settings:SetSetting(name, value)
    self.db.config[name] = value
end

--[[
-- This toggles boolean settings
--
-- @param string name
--]]
function Lootomatic_Settings:ToggleSetting(name)
    local s = self.db.config[name]
    if false == s then
        s = true
    else
        s = false
    end
end

--[[
-- Configures the settings window
--]]
function Lootomatic_Settings:_Construct()
	self.panel = LAM:CreateControlPanel("Lootomatic_Settings_Panel", "Lootomatic")
    self:_AddHeader()
    self:_AddSellJunkToggle()
    self:_AddLoggerSlider()
end

--[[
-- Add the section header
--]]
function Lootomatic_Settings:_AddHeader()
	LAM:AddHeader(self.panel, "Lootomatic_Header_Settings", "Settings")
end

--[[
-- Adds checkbox to settings window that allows players to toggle if they
-- want this addon to sell junk when a vendor window opens
--]]
function Lootomatic_Settings:_AddSellJunkToggle()
    LAM:AddCheckbox(
        self.panel,
        'Lootomatic_Settings_SellAllJunk',
        'Sell All Junk?',
        'When you open a vendor store, if enabled, this will sell all items marked as junk.',
        self:GetSetting('sellAllJunk'),
        self:ToggleSetting('sellAllJunk'),
        true,
        'Setting this to enabled WILL SELL ALL ITEMS marked as junk when you open a vendors store.'
    )
end

--[[
-- Adds a slider that allows players to set the verbosity of output
-- by Lootomatic
--]]
function Lootomatic_Settings:_AddLoggerSlider()
    LAM:AddSlider(
        self.panel,
        'Lootomatic_Settings_Logger',
        'Log Level',
        'Log level, set to 0 to disable all output. 100 will output DEBUG, INFO, and WARN messages; 200 will output INFO and WARN messages. 300 only outputs WARN messages.',
        0,
        300,
        100,
        self:GetSetting('logLevel'),
        function (level)
            self.db.config.logLevel = level
        end
    )
end
