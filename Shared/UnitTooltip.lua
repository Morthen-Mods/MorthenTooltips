local _, addon = ...

local IsUsable = TooltipUtils.IsUsable

local IsRestricted = C_RestrictedActions.IsAddOnRestrictionActive
local Restriction = Enum.AddOnRestrictionType
local GetSetting = DataHandler.GetSetting
local tableName = "TooltipSettings"

local function AurasRestricted()
    return IsRestricted(Restriction.Combat)
            or IsRestricted(Restriction.Encounter)
            or IsRestricted(Restriction.ChallengeMode)
            or IsRestricted(Restriction.PvPMatch)
end

-- Base Info Modifications
local function Recolor(tooltip, index, r, g, b)
    if index > tooltip:NumLines() then return end

    local line = _G["GameTooltipTextLeft" .. index]
    if line then line:SetTextColor(r, g, b) end
end

local function ApplyColor(tooltip, unit, hasGuild)
    local _, class = UnitClass(unit)
    if not IsUsable(class) then return end

    local color = RAID_CLASS_COLORS[class]
    if not color then return end

    -- Playername
    Recolor(tooltip, 1, color.r, color.g, color.b)

    -- Guildline
    if hasGuild then Recolor(tooltip, 2, 0.6, 0.6, 1) end

    -- Playerclass
    Recolor(tooltip, hasGuild and 4 or 3, color.r, color.g, color.b)
end

local function AppendGuildRank(rank)
    local line = _G.GameTooltipTextLeft2
    local text = line and line:GetText()

    if IsUsable(text) then
        line:SetText(text .. " - " .. rank)
    end
end

-- Extra Unit Info
local function AddCreatureID(tooltip, unit, guid)
    local id = UnitCreatureID(unit)

    if not IsUsable(id) and IsUsable(guid) then
        id = select(6, strsplit("-", guid))
    end

    if not IsUsable(id) then return end

    TooltipUtils.AddLine(tooltip, addon.lang.unit, id)
    return true
end

-- Extra PlayerInfo
local function AddPlayerTarget(tooltip, unit)
    local target = unit .. "target"

    local name = UnitName(target)
    if not IsUsable(name) then return end

    local isPlayer = UnitIsPlayer(target)
    if not IsUsable(isPlayer) then return end

    if not isPlayer then
        TooltipUtils.AddLine(tooltip, addon.lang.target, name .. " (" .. addon.lang.npc .. ")")
        return true
    end

    local _, class = UnitClass(target)
    local color = IsUsable(class) and RAID_CLASS_COLORS[class] or nil

    TooltipUtils.AddLine(tooltip, addon.lang.target, name, color and color.r, color and color.g, color and color.b)
    return true
end

local function AddPlayerMount(tooltip, unit)
    if AurasRestricted() then return end

    for i = 1, 10 do
        local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, "HELPFUL")
        if not ok or not IsUsable(aura) then return end

        local spellID, name = aura.spellId, aura.name

        if IsUsable(spellID) and IsUsable(name) then
            TooltipUtils.AddLine(tooltip, addon.lang.mount, name)
            return true
        end
    end
end

local function GetTooltipUnit(tooltip)
    if tooltip.GetUnit then
        local _, unit = tooltip:GetUnit()
        if IsUsable(unit) then return unit end
    end
    
    if UnitExists("mouseover") then return "mouseover" end
end

function addon.InitUnitTooltip()
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
        local unit = GetTooltipUnit(tooltip)
        if not IsUsable(unit) then return end

        local isPlayer = UnitIsPlayer(unit)

        -- When isPlayer is a secret value it only hides the tooltip
        if not IsUsable(isPlayer) then
            if addon.hide.player and addon.hide.unit and InCombatLockdown() then
                tooltip:Hide()
            end
            return
        end

        local guid
        if IsUsable(data) then guid = data.guid end

        -- Apply Unit Tooltip logic
        if not isPlayer then
            if addon.hide.unit and InCombatLockdown() then
                tooltip:Hide()
                return
            end

            if addon.ids.unit and AddCreatureID(tooltip, unit, guid) then
                tooltip:Show()
            end

            return
        end

        -- Apply Player Tooltip Logic
        local guild, rank = GetGuildInfo(unit)
        local hasGuild = IsUsable(guild)
        local own = tooltip == GameTooltip

        if GetSetting(tableName, "tooltipColor") and own then
            ApplyColor(tooltip, unit, hasGuild)
        end

        if hasGuild and own and addon.info.rank and IsUsable(rank) then
            AppendGuildRank(rank)
        end

        local added = false
        if addon.info.itemLevel then added = addon.AddItemLevel(tooltip, unit, guid) end
        if addon.info.score then added = UnitTooltipExtensions.AddMythicScore(tooltip, unit) end
        if addon.info.target then added = AddPlayerTarget(tooltip, unit) end
        if addon.info.mount then added = AddPlayerMount(tooltip, unit) end
        if addon.info.language then added = UnitTooltipExtensions.AddPlayerLanguage(tooltip, unit) end

        if added then tooltip:Show() end
    end)
end