TooltipUtils = {}

function TooltipUtils.IsUsable(data)
    if data == nil then return false end

    if type(data) == "table" then
        return not issecrettable(data)
    else
        return not issecretvalue(data)
    end
end

function TooltipUtils.AddLine(tooltip, label, value, r, g, b)
    tooltip:AddDoubleLine(label .. ":", value, 1, 0.82, 0, r or 1, g or 1, b or 1)
end