local _, addon = ...
local IsUsable = TooltipUtils.IsUsable

local function GetRealmSlug(realm)
    return realm:gsub("[%s']", ""):lower();
end

local function GetLanguage(slug)
    if slug ~= nil or slug ~= "" then
        local region = addon.Region[slug]
        if not region then return end

        return addon.lang["lang_" .. region.locale]
    end
end

function addon.GetPlayerLanguage(unit)
    local _, realm = UnitFullName(unit)
    if realm ~= nil and not IsUsable(realm) then return end

    local slug = GetRealmSlug(realm or GetNormalizedRealmName())
    return GetLanguage(slug)
end

function addon.GetLangFromApplicant(id, memberIndex)
    local name = C_LFGList.GetApplicantMemberInfo(id, memberIndex)
    if not IsUsable(name) then return end

    if name ~= nil then
        local _, realm = strsplit("-", name)
        local slug = GetRealmSlug(realm or GetNormalizedRealmName())
        if not IsUsable(slug) then return end

        if slug ~= nil then
            local region = addon.Region[slug]

            return "|TInterface\\AddOns\\MorthenTooltips\\Media\\" .. region.locale .. "_flag:10:18|t "
        end
    end
end

function addon.GetLangFromResultID(resultID)
    local result = C_LFGList.GetSearchResultInfo(resultID)
    if not IsUsable(result) then return end

    if result ~= nil and result.leaderName ~= nil then
        local _, realm = strsplit("-", result.leaderName)
        local slug = GetRealmSlug(realm or GetNormalizedRealmName())

        return GetLanguage(slug)
    end
end