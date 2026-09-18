local addonName, addon = ...

local category, layout
local tableName = "TooltipSettings"

addon.hide, addon.ids, addon.info = {}, {}, {}
local unpack = { hideInCombat = addon.hide, showIds = addon.ids, showPlayerInfo = addon.info }

local function Setting(key)
    local default = DataHandler.GetDefault(tableName, key)
    local setting = Settings.RegisterAddOnSetting(category,
            addonName .. "_" .. key, key, addon.db[tableName],
            type(default), addon.lang[key], default)

    setting:SetValueChangedCallback(function(_, value) DataHandler.SetSetting(tableName, key, value) end)

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
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return value .. suffix
    end)

    layout:AddInitializer(CreateSettingsCheckboxSliderInitializer(
            Setting(checkKey), addon.lang[checkKey], addon.lang[checkKey .. "_desc"],
            Setting(sliderKey), options, addon.lang[sliderKey], addon.lang[sliderKey .. "_desc"]))
end

local function AddMultiSelect(key, addDescription)
    local list = addon.db.Lists[key]
    local default = DataHandler.GetDefault(tableName, key)

    local proxy = Settings.RegisterProxySetting(category, addonName .. "_" .. key,
            Settings.VarType.Number, addon.lang[key], default,
            function() return DataHandler.GetSetting(tableName, key) end,
            function(value)
                DataHandler.SetSetting(tableName, key, value)
                local bitTable = unpack[key]

                for i = 1, #list do
                    bitTable[list[i]] = bit.band(value, bit.lshift(1, i - 1)) ~= 0
                end
            end)

    local function options()
        local c = Settings.CreateControlTextContainer()

        for i = 1, #list do
            local entry = list[i]
            c:AddCheckbox(i, addon.lang[entry], addDescription and addon.lang[entry .. "_desc"] or nil)
        end

        return c:GetData()
    end

    local init = Settings.CreateDropdown(category, proxy, options, addon.lang[key .. "_desc"])

    init.getSelectionTextFunc = function(selections)
        return #selections == 0 and NONE or nil
    end
end

local function AnchorOptions()
    local c = Settings.CreateControlTextContainer()

    c:Add("ANCHOR_CURSOR_LEFT", addon.lang.anchor_left)
    c:Add("ANCHOR_CURSOR_CENTER", addon.lang.anchor_center)
    c:Add("ANCHOR_CURSOR_RIGHT", addon.lang.anchor_right)

    return c:GetData()
end

function addon.PopulateBitTables()
    for name, list in pairs(addon.db.Lists) do
        local bitTable = unpack[name]
        local value = DataHandler.GetSetting(tableName, name)

        for i = 1, #list do
            bitTable[list[i]] = bit.band(value, bit.lshift(1, i - 1)) ~= 0
        end
    end
end

function addon.InitSettings()
    category, layout = Settings.RegisterVerticalLayoutCategory(addonName)

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