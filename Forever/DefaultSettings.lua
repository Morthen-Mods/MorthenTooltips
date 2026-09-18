local _, addon = ...

addon.db = addon.db or {}

addon.db.defaults = {
    TooltipSettings = {
        hideHealthbar  = true,
        tooltipColor   = true,
        toggleAnchor   = true,
        anchorPosition = "ANCHOR_CURSOR_RIGHT",
        toggleScaling  = false,
        tooltipScale    = 125,  --percent
        hideInCombat   = 2025, -- player, mount, item, toy, currency, quest, macro, achievement
        showIds        = 2047, -- show all ids
        showPlayerInfo = 63,    -- show all playerInfo
    },
    Lists = {
        hideInCombat   = { "player", "unit", "spell", "mount", "unitaura", "item", "toy", "currency", "quest", "macro", "achievement" },
        showIds        = { "unit", "spell", "mount", "unitaura", "item", "toy", "currency", "quest", "macro", "achievement", "icon" },
        showPlayerInfo = { "mount", "target", "rank", "itemLevel" },
    }
}