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
        hideInCombatActive = {},
        showIds        = 2047, -- show all ids
        showIdsActive = {},
        showPlayerInfo = 63,    -- show all playerInfo
        showPlayerInfoActive = {}
    },
    Lists = {
        hideInCombat   = { "player", "unit", "spell", "mount", "unitaura", "item", "toy", "currency", "quest", "macro", "achievement" },
        showIds        = { "unit", "spell", "mount", "unitaura", "item", "toy", "currency", "quest", "macro", "achievement", "icon" },
        showPlayerInfo = { "mount", "target", "score", "rank", "language", "itemLevel" },
    }
}