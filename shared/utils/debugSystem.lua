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
    Print(3, "^1" .. ... .. " ^0")
end
