local addonName, addon = ...
local DataHandler = {}

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addonName then DataHandler.OnLoad() end
end)

local function DeepMerge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            DeepMerge(target[key], value)
        else
            target[key] = value
        end
    end
end

function DataHandler.OnLoad()
    for key, _ in pairs(addon.db) do
        local saved = _G[key]
        if saved ~= nil then
            DeepMerge(addon.db[key], saved)
        end

        _G[key] = addon.db[key]
    end
end