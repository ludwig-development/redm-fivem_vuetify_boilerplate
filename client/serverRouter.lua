local eventName = tostring(GetCurrentResourceName()) .. ":serverRouter"


RegisterNUICallback("ServerRouter", function(data, cb)
    DebugPrint "ServerRouter Starts: "
    DebugPrint(json.encode(data))

    if data and data.event then
        TriggerServerEvent(eventName, data.event, data.data or {})
    end

    cb { success = true }
end)
