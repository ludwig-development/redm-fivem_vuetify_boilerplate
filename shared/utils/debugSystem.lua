--[[
Special Thanks to Roschy (https://github.com/JulianLegler) for Providing the Code for this Debug System.
 Without him i wouldn´t  understand half of what i know now and this Project wouldn´t be possible
]]

function DebugPrint(...)
    if not Config.Debug then
        return
    end
    local args = { ... }
    local level = 2 -- Default stack level is 2 if not provided

    if type(args[1]) == "number" then
        level = table.remove(args, 1) -- Remove the first argument and use it as the stack level
    end

    for i, v in ipairs(args) do
        if type(v) == "table" then
            args[i] = json.encode(v)
        elseif type(v) == "boolean" then
            args[i] = v and "true" or "false"
        end
    end

    local info = debug.getinfo(level, "Sl")
    local src = info.short_src
    local line = info.currentline
    local funcName = debug.getinfo(level, "n").name or "unknown"
    print(string.format("[%s] %s:%d (%s) %s", GetCurrentResourceName(), src, line, funcName, table.concat(args, " ")))
end

function Print(...)
    local args = { ... }
    local level = 2 -- Default stack level is 2 if not provided

    if type(args[1]) == "number" then
        level = table.remove(args, 1) -- Remove the first argument and use it as the stack level
    end

    for i, v in ipairs(args) do
        if type(v) == "table" then
            args[i] = json.encode(v)
        elseif type(v) == "boolean" then
            args[i] = v and "true" or "false"
        end
    end

    local info = debug.getinfo(level, "Sl")
    local src = info.short_src
    local line = info.currentline
    local funcName = debug.getinfo(level, "n").name or "unknown"
    print(string.format("[%s] %s:%d (%s) %s", GetCurrentResourceName(), src, line, funcName, table.concat(args, " ")))
end

function WarnPrint(...)
    Print(3, "^3" .. ... .. " ^0")
end

function ErrorPrint(...)
    Print(3, "^1" .. ... .. " ^0")
end

function JsonPrint(table)
    Print(3, json.encode(table, { indent = true }))
end

local function dump(o, depth)
    depth = depth or 0
    local spacing = string.rep("  ", depth)

    if type(o) == 'table' then
        if depth > 10 then return "{ ... High Depth ... }" end

        local s = '{\n'
        local foundData = false

        for k, v in pairs(o) do
            if type(v) ~= 'function' then
                foundData = true
                local key = (type(k) ~= 'number') and '"' .. k .. '"' or k
                s = s .. spacing .. "  [" .. key .. "] = " .. dump(v, depth + 1) .. ",\n"
            end
        end

        if not foundData then return "{ }" end
        return s .. spacing .. '}'
    elseif type(o) == 'string' then
        return '"' .. o .. '"'
    else
        return tostring(o)
    end
end

function ObjectPrint(object)
    DebugPrint(4, dump(object))
end
