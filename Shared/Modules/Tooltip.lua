local _, addon = ...
local tableName = "TooltipSettings"

local Icon = {
    spell   = function(id)
        local info = C_Spell.GetSpellInfo(id)
        return info and info.iconID
    end,
    currency = function(id)
        local info = C_CurrencyInfo.GetCurrencyInfo( id)
        return info and info.iconFileID
    end,
    mount = function(id)
        return select(3, C_MountJournal.GetMountInfoByID(id))
    end,
    macro = function(id)
        return select(2, GetMacroInfo(id))
    end,
    item = function(id)
        return C_Item.GetItemIconByID(id)
    end
}

local Sources = {
    Spell              = { key = "spell",    icon = "spell" },
    Item               = { key = "item",     icon = "item" },
    Toy                = { key = "toy",      icon = "spell" },
    Mount              = { key = "mount",    icon = "mount" },
    UnitAura           = { key = "unitaura", icon = "spell" },
    Currency           = { key = "currency", icon = "currency" },
    Macro              = { key = "macro",    icon = "macro" },
    Quest              = { key = "quest" },
    QuestPartyProgress = { key = "quest" },
    Achievement        = { key = "achievement" },
}

function addon.InitTooltips()
    local settings = addon.db[tableName]
    local lang = addon.lang

    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if settings.toggleAnchor and not tooltip:IsForbidden() then
            tooltip:SetOwner(parent or UIParent, settings.anchorPosition)
        end
    end)

    hooksecurefunc(GameTooltip, "Show", function(tooltip)
        if settings.toggleScaling and settings.tooltipScale then
            tooltip:SetScale(settings.tooltipScale / 100)
        else
            tooltip:SetScale(1)
        end
    end)

    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(button)
        if not addon.ids.quest then return end

        local questID = button.questID
        if not TooltipUtils.IsUsable(questID) then return end

        TooltipUtils.AddLine(GameTooltip, lang.quest, questID)
        GameTooltip:Show()
    end)

    GameTooltipStatusBar:HookScript("OnShow", function(self)
        if settings.hideHealthbar then self:Hide() end
    end)

    for name, source in pairs(Sources) do
        local dataType = Enum.TooltipDataType[name]

        if dataType then
            TooltipDataProcessor.AddTooltipPostCall(dataType, function(tooltip, data)
                local key = source.key
                local added = false

                if addon.hide[key] and InCombatLockdown() then
                    tooltip:Hide()
                    return
                end

                local id = data.id

                if addon.ids[key] then
                    TooltipUtils.AddLine(tooltip, lang[key], 1283745)
                    added = true
                end

                if addon.ids.icon and source.icon then
                    local icon = Icon[source.icon](id)
                    if TooltipUtils.IsUsable(icon) then
                        TooltipUtils.AddLine(tooltip, lang.icon, icon)
                        added = true
                    end
                end

                if added then tooltip:Show() end
            end)
        end
    end
end