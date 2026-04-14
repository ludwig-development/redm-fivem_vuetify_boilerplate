-- Using benchmarking within RedM i found that Localized (the _ functions) are 1.10 ns faster per call, as it is more than nothing lets use it !
local _tostring = tostring
local _format = string.format
local _select = select

function T(key, ...)
    local current = L

    -- Handle Nested Tables (e.g., "menu.welcome.title")
    for segment in string.gmatch(key, "([^.]+)") do
        if type(current) == "table" and current[segment] then
            current = current[segment]
        else
            return key
        end
    end

    if type(current) ~= "string" then
        return key
    end

    if _select('#', ...) == 0 then
        return current
    end

    -- Handles String Interpolation and calls tostring on every arg passed in (so you dont have in the normal code)
    local args = { ... }
    for i = 1, #args do
        args[i] = _tostring(args[i])
    end

    local success, result = pcall(_format, current, table.unpack(args))
    return success and result or current
end
