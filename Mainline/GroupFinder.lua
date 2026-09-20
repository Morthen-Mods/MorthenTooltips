local _, addon = ...
local IsUsable = TooltipUtils.IsUsable
local AddLine = TooltipUtils.AddLine

local function AddTooltipLanguage(tooltip, resultId)
    local language = addon.GetLangFromResultID(resultId)
    if tooltip ~= nil and language ~= nil then
        AddLine(tooltip, addon.lang.language, language)
        tooltip:Show()
    end
end

local function AddSearchEntryLanguage(member, appID, index)
    local flag = addon.GetLangFromApplicant(appID, index)

    if member.Name ~= nil and flag ~= nil then
        member.Name:SetText(flag .. member.Name:GetText())
    end
end

function addon.InitGroupFinder()
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", AddTooltipLanguage)
    hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", AddSearchEntryLanguage)
end