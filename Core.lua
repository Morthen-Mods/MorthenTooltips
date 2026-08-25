local ADDON, ns = ...

local issecretvalue = issecretvalue
local band, lshift = bit.band, bit.lshift

function ns.Visible(value)
    return not issecretvalue(value) and value ~= nil
end

function ns.AddLine(tooltip, label, value, r, g, b)
    tooltip:AddDoubleLine(label .. ":", value, 1, 0.82, 0, r or 1, g or 1, b or 1)
end

ns.defaults = {
    hideHealthbar  = true,
    tooltipColor   = true,
    toggleAnchor   = true,
    anchorPosition = "ANCHOR_CURSOR_RIGHT",
    toggleScaling  = false,
    tooltipScale   = 100,  -- percent
    hideInCombat   = 2025, -- player, mount, item, toy, currency, quest, macro, achievement

    showIds        = 2047,
    showPlayerInfo = 63,
}

ns.lists = {
    hideInCombat   = { "player", "unit", "spell", "mount", "unitaura", "item", "toy", "currency", "quest", "macro", "achievement" },
    showIds        = { "unit", "spell", "mount", "unitaura", "item", "toy", "currency", "quest", "macro", "achievement", "icon" },
    showPlayerInfo = { "mount", "target", "score", "rank", "language", "itemLevel" },
}

ns.hide, ns.ids, ns.info = {}, {}, {}

local unpacked = { hideInCombat = ns.hide, showIds = ns.ids, showPlayerInfo = ns.info }

function ns.Expand(key)
    local mask, list, out = ns.db[key], ns.lists[key], unpacked[key]

    for i = 1, #list do
        out[list[i]] = band(mask, lshift(1, i - 1)) ~= 0
    end
end

local function LoadSettings()
    local db = TooltipSettings or {}

    for key, value in pairs(ns.defaults) do
        if type(db[key]) ~= type(value) then
            db[key] = value
        end
    end

    for key in pairs(db) do
        if ns.defaults[key] == nil then
            db[key] = nil
        end
    end

    TooltipSettings, ns.db = db, db

    for key in pairs(ns.lists) do
        ns.Expand(key)
    end
end

local ready = false

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, _, name)
    if name == ADDON then
        LoadSettings()
        ns.InitTooltip()
        ns.InitUnit()
        ns.InitOptions()
        ready = true
    end

    if ready and ns.HookGroupFinder() then
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
