local resourceName = GetCurrentResourceName()

EventLogic = EventLogic or {}
CallbackLogic = CallbackLogic or {}

local USE_ALLOWED_FUNCTIONS = true -- if you want the extra security or the comfort

local AllowedFunctions = {         --for events and callbacks, both the same table
    ["myEventName"] = true,
    ["myCallbackName"] = true
}

local function isAllowed(key)
    if not USE_ALLOWED_FUNCTIONS then
        return true
    end

    return AllowedFunctions[key] == true
end

local function validateKey(key, src)
    if type(key) ~= "string" or key == "" then
        WarnPrint("[Router] Invalid function key received")

        if src then
            UserNotification("Invalid request", "error", 4000, src)
        end

        return false
    end

    return true
end


local eventRouterName = resourceName .. ":serverRouter"

RegisterNetEvent(eventRouterName)
AddEventHandler(eventRouterName, function(action, data)
    local src = source
    local key = action

    if not validateKey(key, src) then
        return
    end

    if not isAllowed(key) then
        WarnPrint("[Router] Blocked unauthorized event: " .. key .. " Triggering Player: " .. GetPlayerName(src))
        UserNotification("Triggered not allowed event", "error", 4000, src)
        return
    end

    local logicFunction = EventLogic[key]

    if type(logicFunction) ~= "function" then
        WarnPrint("[Router] No EventLogic found for key: " .. key)
        UserNotification("Triggered non-existing event", "error", 4000, src)
        return
    end

    DebugPrint("[Router] Executing Event: " .. key)
    JsonPrint(data)

    local success, err = pcall(function()
        logicFunction(src, data)
    end)

    if not success then
        WarnPrint("[Router] Event error in " .. key .. ": " .. tostring(err))
    end
end)

local callbackRouterName = resourceName .. ":serverCallbackRouter"

lib.callback.register(callbackRouterName, function(source, action, data)
    local key = action

    if not validateKey(key, source) then
        return { success = false, error = "Invalid Key" }
    end

    if not isAllowed(key) then
        WarnPrint("[Router] Blocked unauthorized callback: " .. key .. " Triggering Player: " .. GetPlayerName(src))
        UserNotification("Triggered not allowed callback", "error", 4000, source)
        return { success = false, error = "Not Allowed" }
    end

    local logicFunction = CallbackLogic[key]
    if type(logicFunction) ~= "function" then
        WarnPrint("[Router] No CallbackLogic found for key: " .. key)

        UserNotification(string.format("No Callback Logic defined for %s", key), "error", 4000, source)

        return { success = false, error = "Action Not Found" }
    end

    local success, result = pcall(function()
        return logicFunction(source, data)
    end)

    if not success then
        WarnPrint("[Router] Callback error in " .. key .. ": " .. tostring(result))

        return { success = false, error = "Callback Failed" }
    end

    DebugPrint("[Router] Returning callback data for: " .. key)
    JsonPrint(result)

    return result
end)
