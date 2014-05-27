--[[
--
-- Lootomatic GUI Interface
--
-- /-------------------\
-- | Name              |
-- | Filter Rules      |
-- | [update] [delete] |
-- |-------------------|
-- | Name              |
-- | Filter Rules      |
-- | [update] [delete] |
-- |-------------------|
-- \-------------------/
--
--]]

local wm = GetWindowManager()
LootomaticGUI = {}

--[[
-- @param string controlName
-- @param 
-- @param ControlType controlType
-- @return 
--]]
function LootomaticGUI:CreateControl(controlName, parent, controlType)
    return wm:CreateControl(controlName, parent, controlType)
end

--[[
-- @param string controlName
-- @return 
--]]
function LootomaticGUI:CreateTopLevelWindow(controlName)
    return wm:CreateTopLevelWindow(controlName)
end

--[[
-- @param string controlName
-- @param 
-- @param string virtualName
-- @return
--]]
function LootomaticGUI:CreateControlFromVirtual(controlName, parent, virtualName)
    return wm:CreateControlFromVirtual(controlName, parent, virtualName)
end

function LootomaticGUI:CreateWindow()
end

function LootomaticGUI:CreateButton()
end

function LootomaticGUI:CreateHeader()
end
