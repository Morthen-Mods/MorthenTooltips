local _, ns = ...

local Visible, AddLine = ns.Visible, ns.AddLine
local db, L

local scaled = { "GameTooltip", "ItemRefTooltip" }

function ns.Refresh()
    local scale = db.toggleScaling and db.tooltipScale / 100 or 1

    for i = 1, #scaled do
        local tooltip = _G[scaled[i]]
        if tooltip then
            tooltip:SetScale(scale)
        end
    end

    if db.hideHealthbar then
        GameTooltipStatusBar:Hide()
    end
end

local Icon = {
    spell    = function(id) local info = C_Spell.GetSpellInfo(id) return info and info.iconID end,
    currency = function(id) local info = C_CurrencyInfo.GetCurrencyInfo(id) return info and info.iconFileID end,
    mount    = function(id) return select(3, C_MountJournal.GetMountInfoByID(id)) end,
    macro    = function(id) return select(2, GetMacroInfo(id)) end,
    item     = function(id) return C_Item.GetItemIconByID(id) end,
}

local sources = {
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

local function OnTooltip(tooltip, data, source)
    local key = source.key

    if ns.hide[key] and InCombatLockdown() then
        tooltip:Hide()
        return
    end

    if not Visible(data) then return end

    local id = data.id
    if not Visible(id) then return end

    local added = false

    if ns.ids[key] then
        AddLine(tooltip, L[key], id)
        added = true
    end

    if ns.ids.icon and source.icon then
        local icon = Icon[source.icon](id)
        if Visible(icon) then
            AddLine(tooltip, L.icon, icon)
            added = true
        end
    end

    if added then
        tooltip:Show()
    end
end

function ns.InitTooltip()
    db, L = ns.db, ns.L

    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if db.toggleAnchor and not tooltip:IsForbidden() then
            tooltip:SetOwner(parent or UIParent, db.anchorPosition)
        end
    end)

    GameTooltipStatusBar:HookScript("OnShow", function(self)
        if db.hideHealthbar then
            self:Hide()
        end
    end)

    for name, source in pairs(sources) do
        local dataType = Enum.TooltipDataType[name]

        if dataType then
            TooltipDataProcessor.AddTooltipPostCall(dataType, function(tooltip, data)
                OnTooltip(tooltip, data, source)
            end)
        end
    end

    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(button)
        if not ns.ids.quest then return end

        local questID = button.questID
        if not Visible(questID) then return end

        AddLine(GameTooltip, L.quest, questID)
        GameTooltip:Show()
    end)

    ns.Refresh()
end
