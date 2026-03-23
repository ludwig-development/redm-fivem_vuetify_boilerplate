local eventName = tostring(GetCurrentResourceName()) .. ":serverRouter"


RegisterNUICallback("ServerRouter", function(data, cb)
    DebugPrint "ServerRouter Starts: "
    DebugPrint(json.encode(data))

    if data and data.action then
        TriggerServerEvent(eventName, data.action, data.data or {})
    end

    cb { success = true }
end)

local resourceName = GetCurrentResourceName()

RegisterNUICallback("ServerCallbackRouter", function(data, cb)
    if not data or not data.action then
        return cb({ success = false, error = "Invalid Request" })
    end

    local result = lib.callback.await(resourceName .. ":serverCallbackRouter", false, data.action, data.data)
    cb(result)
end)
