local ADDON, ns = ...

local category, layout, L

local function Setting(key)
    local default = ns.defaults[key]
    local setting = Settings.RegisterAddOnSetting(category, ADDON .. "_" .. key, key,
            ns.db, type(default), L[key], default)

    setting:SetValueChangedCallback(function(_, value)
        ns.db[key] = value
        ns.Refresh()
    end)

    return setting
end

local function AddHeader(key)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L[key], L[key .. "_desc"]))
end

local function AddCheckbox(key)
    Settings.CreateCheckbox(category, Setting(key), L[key .. "_desc"])
end

local function AddCheckboxDropdown(checkKey, dropKey, options)
    layout:AddInitializer(CreateSettingsCheckboxDropdownInitializer(
            Setting(checkKey), L[checkKey], L[checkKey .. "_desc"],
            Setting(dropKey), options, L[dropKey], L[dropKey .. "_desc"]))
end

local function AddCheckboxSlider(checkKey, sliderKey, min, max, step, suffix)
    local options = Settings.CreateSliderOptions(min, max, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return value .. suffix
    end)

    layout:AddInitializer(CreateSettingsCheckboxSliderInitializer(
            Setting(checkKey), L[checkKey], L[checkKey .. "_desc"],
            Setting(sliderKey), options, L[sliderKey], L[sliderKey .. "_desc"]))
end

local function AddMultiSelect(key, describeEntries)
    local list = ns.lists[key]

    local setting = Settings.RegisterProxySetting(category, ADDON .. "_" .. key,
            Settings.VarType.Number, L[key], ns.defaults[key],
            function() return ns.db[key] end,
            function(value)
                ns.db[key] = value
                ns.Expand(key)
            end)

    local function options()
        local container = Settings.CreateControlTextContainer()

        for i = 1, #list do
            local entry = list[i]
            container:AddCheckbox(i, L[entry], describeEntries and L[entry .. "_desc"] or nil)
        end

        return container:GetData()
    end

    local init = Settings.CreateDropdown(category, setting, options, L[key .. "_desc"])

    init.getSelectionTextFunc = function(selections)
        return #selections == 0 and NONE or nil
    end
end

local function AnchorOptions()
    local container = Settings.CreateControlTextContainer()

    container:Add("ANCHOR_CURSOR_LEFT", L.anchor_left)
    container:Add("ANCHOR_CURSOR", L.anchor_center)
    container:Add("ANCHOR_CURSOR_RIGHT", L.anchor_right)

    return container:GetData()
end

function ns.InitOptions()
    L = ns.L
    category, layout = Settings.RegisterVerticalLayoutCategory(ADDON)

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
