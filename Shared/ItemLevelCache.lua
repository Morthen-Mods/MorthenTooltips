local _, addon = ...

local CACHE_TTL = 600   -- 10m for fetched itemLevels
local THROTTLE  = 2     -- seconds between two requests
local TIMEOUT   = 3     -- seconds before a request is thrown away

local IsUsable = TooltipUtils.IsUsable
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

local function FillPlaceholderLine(guid)
    if not pendingLine or not GameTooltip:IsShown() then return end
    if pendingLine > GameTooltip:NumLines() then return end

    local hovered = UnitGUID("mouseover")
    if not IsUsable(hovered) or hovered ~= guid then return end

    local line = _G["GameTooltipTextRight" .. pendingLine]
    if line then line:SetText(levels[guid]) end
end

local function OnInspectReady(guid)
    if not IsUsable(guid) then
        if pending then ReleaseInspect() end
        return
    end

    local unit = UnitTokenFromGUID(guid)
    if IsUsable(unit) then
        local level = C_PaperDollInfo.GetInspectItemLevel(unit)

        if IsUsable(level) and level > 0 then
            levels[guid] = format("%d", level)
            stamps[guid] = GetTime()
            FillPlaceholderLine(guid)
        end
    end
end

local function RequestItemLevel(guid, unit)
    if InspectInUse() then return false end

    local canInspect = CanInspect(unit, false)
    if not IsUsable(canInspect) or not canInspect then return false end

    if not pending and (GetTime() - lastRequest) >= THROTTLE then
        pending, lastRequest = guid, GetTime()
        NotifyInspect(unit)

        C_Timer.After(TIMEOUT, function()
            if pending == guid then ReleaseInspect() end
        end)
    end
end

function addon.AddItemLevel(tooltip, unit, guid)
    if not IsUsable(guid) then return end

    if levels[guid] and (GetTime() - stamps[guid]) < CACHE_TTL then
        TooltipUtils.AddLine(tooltip, addon.lang.itemLevel, levels[guid])
        return true
    end

    if RequestItemLevel(guid, unit) then
        TooltipUtils.AddLine(tooltip, addon.lang.itemLevel, addon.lang.loading)

        if tooltip == GameTooltip then
            pendingLine = tooltip:NumLines()
        end

        return true
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("INSPECT_READY")
f:SetScript("OnEvent", function(_, _, guid) OnInspectReady(guid) end)