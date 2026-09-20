local addonName, addon = ...
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, ...)
    local name = ...
    if event == "ADDON_LOADED" and name == addonName then
        addon.InitSettings()
        addon.InitTooltips()
        addon.PopulateBitTables()
        addon.InitUnitTooltip()
    end
end)