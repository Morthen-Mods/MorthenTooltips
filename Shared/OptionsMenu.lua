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
    Settings.CreateCheckbox(category, Setting(key), addon.lang[key .. "_desc"])
end

local function AddCheckboxDropdown(checkKey, dropKey, options)
    local init = CreateSettingsCheckboxDropdownInitializer(
            Setting(checkKey), addon.lang[checkKey], addon.lang[checkKey .. "_desc"],
            Setting(dropKey), options, addon.lang[dropKey], addon.lang[dropKey .. "_desc"]
    )
    layout:AddInitializer(init)
end

local function AddCheckboxSlider(checkKey, sliderKey, min, max, step, suffix)
    local options = Settings.CreateSliderOptions(min, max, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
    function(value) return value .. (suffix or "") end)

    local init = CreateSettingsCheckboxSliderInitializer(
            Setting(checkKey), addon.lang[checkKey], addon.lang[checkKey .. "_desc"],
            Setting(sliderKey), options, addon.lang[sliderKey], addon.lang[sliderKey .. "_desc"]
    )

    layout:AddInitializer(init)
end

local function AddMultiSelect(key, entryTable, addDescription)
    --TODO: implement
end

local function AnchorOptions()
    local c = Settings.CreateControlTextContainer()

    c:Add("ANCHOR_CURSOR_LEFT", addon.lang.anchor_left)
    c:Add("ANCHOR_CURSOR_CENTER", addon.lang.anchor_center)
    c:Add("ANCHOR_CURSOR_RIGHT", addon.lang.anchor_right)
end

function addon.InitSettings()
    category, layout = Settings.RegisterVerticalLayoutCategory(addon)

    AddHeader("header_general")
    AddCheckbox("hideHealthbar")
    AddCheckbox("tooltipColor")
    AddCheckboxDropdown("toggleAnchor", "anchorPosition", AnchorOptions)
    AddCheckboxSlider("toggleScaling", "tooltipScale", 5, 300, 5, "%")
    AddMultiSelect("hideInCombat")

    AddHeader("header_info")
    AddMultiSelect("showIds")
    AddMultiSelect("showPlayerInfo", true)

    Settings.RegisterAddOnCategory(category)
end