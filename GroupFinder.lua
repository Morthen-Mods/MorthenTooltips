local _, ns = ...

local Visible = ns.Visible

---@param fullName string
---@return string|nil
local function RealmOf(fullName)
    if not Visible(fullName) then return nil end

    local _, realm = strsplit("-", fullName, 2)
    if realm and realm ~= "" then return realm end

    return GetNormalizedRealmName()
end

local function AddSearchEntryLanguage(tooltip, resultID)
    local result = C_LFGList.GetSearchResultInfo(resultID)
    if not Visible(result) then return end

    local realm = RealmOf(result.leaderName)
    local language = realm and ns.RealmLanguage(realm)
    if not language then return end

    ns.AddLine(tooltip, ns.L.language, language)
    tooltip:Show()
end

local function AddApplicantFlag(member, appID, memberIndex)
    local realm = RealmOf(C_LFGList.GetApplicantMemberInfo(appID, memberIndex))
    local flag = realm and ns.RealmFlag(realm)
    if not flag then return end

    local name = member.Name
    local text = name and name:GetText()

    if Visible(text) then
        name:SetText(flag .. text)
    end
end

local hooked = false

---@return boolean done true when there is nothing left to wait for
function ns.HookGroupFinder()
    if hooked then return true end
    if type(LFGListUtil_SetSearchEntryTooltip) ~= "function" then return false end

    hooked = true
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", AddSearchEntryLanguage)

    if type(LFGListApplicationViewer_UpdateApplicantMember) == "function" then
        hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", AddApplicantFlag)
    end

    return true
end
