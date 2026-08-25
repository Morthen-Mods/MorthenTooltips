local _, ns = ...

local Visible, AddLine = ns.Visible, ns.AddLine
local issecretvalue = issecretvalue
local db, L

local CACHE_TTL = 300 -- how long a fetched item level is trusted
local THROTTLE  = 1   -- seconds between two requests of our own
local TIMEOUT   = 3   -- seconds before an unanswered request is given up

local levels, stamps = {}, {}

local pending, pendingLine
local lastRequest = 0

local function InspectInUse()
    return InspectFrame ~= nil and InspectFrame:IsShown()
end

local function ReleaseInspect()
    pending = nil

    if not InspectInUse() then
        ClearInspectPlayer()
    end
end

local function FillPlaceholder(guid)
    if not pendingLine or not GameTooltip:IsShown() then return end
    if pendingLine > GameTooltip:NumLines() then return end

    local hovered = UnitGUID("mouseover")
    if not Visible(hovered) or hovered ~= guid then return end

    local line = _G["GameTooltipTextRight" .. pendingLine]
    if line then
        line:SetText(levels[guid])
    end
end

local function OnInspectReady(guid)
    if not Visible(guid) then
        if pending then ReleaseInspect() end
        return
    end

    local unit = UnitTokenFromGUID(guid)
    if Visible(unit) then
        local level = C_PaperDollInfo.GetInspectItemLevel(unit)

        if Visible(level) and level > 0 then
            levels[guid] = format("%d", level)
            stamps[guid] = GetTime()
            FillPlaceholder(guid)
        end
    end

    if guid == pending then
        ReleaseInspect()
    end
end

---@return boolean onItsWay true while an answer can still be expected
local function RequestItemLevel(guid, unit)
    if InspectInUse() then return false end

    local canInspect = CanInspect(unit, false)
    if not Visible(canInspect) or not canInspect then return false end

    if not pending and (GetTime() - lastRequest) >= THROTTLE then
        pending, lastRequest = guid, GetTime()
        NotifyInspect(unit)

        C_Timer.After(TIMEOUT, function()
            if pending == guid then ReleaseInspect() end
        end)
    end

    return true
end

local function AddItemLevel(tooltip, unit, guid)
    if not Visible(guid) then return end

    if levels[guid] and (GetTime() - stamps[guid]) < CACHE_TTL then
        AddLine(tooltip, L.itemLevel, levels[guid])
        return true
    end

    if RequestItemLevel(guid, unit) then
        AddLine(tooltip, L.itemLevel, L.loading)

        if tooltip == GameTooltip then
            pendingLine = tooltip:NumLines()
        end

        return true
    end
end

local function AddMount(tooltip, unit)
    for i = 1, 10 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
        if not Visible(aura) then return end

        local spellID, name = aura.spellId, aura.name

        if Visible(spellID) and Visible(name) and Visible(C_MountJournal.GetMountFromSpell(spellID)) then
            AddLine(tooltip, L.mount, name)
            return true
        end
    end
end

local function AddScore(tooltip, unit)
    local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
    if not Visible(summary) then return end

    local score = summary.currentSeasonScore
    if not Visible(score) or score == 0 then return end

    local color = C_ChallengeMode.GetDungeonScoreRarityColor(score)
    if Visible(color) then
        AddLine(tooltip, L.score, score, color.r, color.g, color.b)
    else
        AddLine(tooltip, L.score, score)
    end

    return true
end

local function AddTarget(tooltip, unit)
    local target = unit .. "target"

    local name = UnitName(target)
    if not Visible(name) then return end

    local isPlayer = UnitIsPlayer(target)
    if not Visible(isPlayer) then return end

    if not isPlayer then
        AddLine(tooltip, L.target, name .. " (" .. L.npc .. ")")
        return true
    end

    local _, class = UnitClass(target)
    local color = Visible(class) and RAID_CLASS_COLORS[class] or nil

    AddLine(tooltip, L.target, name, color and color.r, color and color.g, color and color.b)
    return true
end

local function AddLanguage(tooltip, unit)
    local _, realm = UnitFullName(unit)

    if issecretvalue(realm) then return end

    if realm == nil or realm == "" then
        realm = GetNormalizedRealmName()
        if realm == nil then return end
    end

    local language = ns.RealmLanguage(realm)
    if not language then return end

    AddLine(tooltip, L.language, language)
    return true
end

local function Recolor(tooltip, index, r, g, b)
    if index > tooltip:NumLines() then return end

    local line = _G["GameTooltipTextLeft" .. index]
    if line then
        line:SetTextColor(r, g, b)
    end
end

local function ClassColor(tooltip, unit, guilded)
    local _, class = UnitClass(unit)
    if not Visible(class) then return end

    local color = RAID_CLASS_COLORS[class]
    if not color then return end

    Recolor(tooltip, 1, color.r, color.g, color.b)

    if guilded then
        Recolor(tooltip, 2, 0.6, 0.6, 1)
    end

    Recolor(tooltip, guilded and 4 or 3, color.r, color.g, color.b)
end

local function AppendRank(rank)
    local line = _G.GameTooltipTextLeft2
    local text = line and line:GetText()

    if Visible(text) then
        line:SetText(text .. " - " .. rank)
    end
end

local function TooltipUnit(tooltip)
    if tooltip.GetUnit then
        local _, unit = tooltip:GetUnit()
        if Visible(unit) then return unit end
    end

    if UnitExists("mouseover") then return "mouseover" end
end

local function AddCreatureID(tooltip, unit, guid)
    local id = UnitCreatureID(unit)

    if not Visible(id) and Visible(guid) then
        id = select(6, strsplit("-", guid))
    end

    if not Visible(id) then return end

    AddLine(tooltip, L.unit, id)
    return true
end

local function OnUnitTooltip(tooltip, data)
    pendingLine = nil

    local unit = TooltipUnit(tooltip)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)

    if not Visible(isPlayer) then
        if ns.hide.player and ns.hide.unit and InCombatLockdown() then
            tooltip:Hide()
        end
        return
    end

    local guid
    if Visible(data) then guid = data.guid end

    if not isPlayer then
        if ns.hide.unit and InCombatLockdown() then
            tooltip:Hide()
            return
        end

        if ns.ids.unit and AddCreatureID(tooltip, unit, guid) then
            tooltip:Show()
        end

        return
    end

    if ns.hide.player and InCombatLockdown() then
        tooltip:Hide()
        return
    end

    local guild, rank = GetGuildInfo(unit)
    local guilded = Visible(guild)
    local own = tooltip == GameTooltip

    if db.tooltipColor and own then
        ClassColor(tooltip, unit, guilded)
    end

    if guilded and own and ns.info.rank and Visible(rank) then
        AppendRank(rank)
    end

    local added = false
    if ns.info.itemLevel then added = AddItemLevel(tooltip, unit, guid) or added end
    if ns.info.score    then added = AddScore(tooltip, unit) or added end
    if ns.info.target   then added = AddTarget(tooltip, unit) or added end
    if ns.info.mount    then added = AddMount(tooltip, unit) or added end
    if ns.info.language then added = AddLanguage(tooltip, unit) or added end

    if added then
        tooltip:Show()
    end
end

function ns.InitUnit()
    db, L = ns.db, ns.L

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnUnitTooltip)

    local f = CreateFrame("Frame")
    f:RegisterEvent("INSPECT_READY")
    f:SetScript("OnEvent", function(_, _, guid) OnInspectReady(guid) end)
end
