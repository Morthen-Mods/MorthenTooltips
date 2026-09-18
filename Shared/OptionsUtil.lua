local _, addon = ...

OptionsUtil = {}

function OptionsUtil.CreateGetter(variables, key)
    return function()
        return variables[key] or 0
    end
end

function OptionsUtil.CreateSetter(variables, key, entryTable)
    return function(value)
        variables[key] = value
        local activeTable = variables[key .. "Active"]

        if activeTable == nil then
            activeTable = {}
        end

        for i = #entryTable, 1, -1 do
            if (value - (2^(i-1))) >= 0 then
                activeTable[entryTable[i]] = true
                value = value - 2^(i-1)
            else
                activeTable[entryTable[i]] = false
            end
        end
    end
end