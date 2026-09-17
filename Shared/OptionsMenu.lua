local addonName, addon = ...

local category, layout
local function Setting(key)
    local default = addon.db.defaults[key]
    local setting = Settings.RegisterAddOnSetting(category,
            addonName .. "_" .. key, key, addon.sb,
            type(default), addon.lang[key], default)

    setting:SetValueChangedCallback(function(_, value) addon.db[key] = value end)

    return setting
end

local function AddHeader(key)
    local init = CreateSettingsListSectionHeaderInitializer(addon.lang[key], addon.lang[key .. "_desc"])
    layout:AddInitializer(init)
end

local function AddCheckbox(key)

end