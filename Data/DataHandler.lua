local addonName, addon = ...
local handler = {}
addon.DataHandler = handler

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addonName then handler.OnLoad() end
end)

local function DeepCopy(source)
    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local function DeepMerge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            DeepMerge(target[key], value)
        else
            target[key] = value
        end
    end
end

function handler.OnLoad()
    for key, defaults in pairs(addon.db.defaults) do
        addon.db[key] = DeepCopy(defaults)

        local saved = _G[key]
        if saved ~= nil then
            DeepMerge(addon.db[key], saved)
        end

        _G[key] = addon.db[key]
    end
end

function handler.SetSetting(table, key, value)
    local settings = addon.db[table]
    settings[key] = value
end

function handler.GetSetting(table, key)
    local settings = addon.db[table]
    return settings[key]
end

function handler.GetDefault(table, key)
    local default = addon.db.defaults[table]
    return default[key]
end