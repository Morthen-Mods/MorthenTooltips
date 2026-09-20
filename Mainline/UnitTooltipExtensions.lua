local _, addon = ...

UnitTooltipExtensions = {}

local IsUsable = TooltipUtils.IsUsable
local AddLine = TooltipUtils.AddLine

function UnitTooltipExtensions.AddMythicScore(tooltip, unit)
    local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
    if not IsUsable(summary) then return end

    local score = summary.currentSeasonScore
    if not IsUsable(score) or score == 0 then return end

    local color = C_ChallengeMode.GetDungeonScoreRarityColor(score)
    if IsUsable(color) then
        AddLine(tooltip, addon.lang.score, score, color.r, color.g, color.b)
    else
        AddLine(tooltip, addon.lang.score, score)
    end

    return true
end

function UnitTooltipExtensions.AddPlayerLanguage(tooltip, unit)
    local language = addon.GetPlayerLanguage(unit)
    if not language then return end

    AddLine(tooltip, addon.lang.language, language)
    return true
end