local eventName = tostring(GetCurrentResourceName()) .. ":serverRouter"

-- Security measure to only allow certain events through the serverRouter
local allowedEvents = {
    ["myRessourceName:myEventName"] = true
}

RegisterNetEvent(eventName)
AddEventHandler(eventName, function(event, data)
    local src = source
    DebugPrint("The Event " .. tostring(event) .. " will now work with following Data: " .. json.encode(data))

    if not event or type(event) ~= "string" then
        WarnPrint "Problem with the eventName!"
        return
    end

    if allowedEvents[event] then
        TriggerEvent(event, src, data)
    else
        UserNotification("triggered not allowed Event", "error", 4000, src)
        WarnPrint "unallowed Event was Triggered by User!"
        -- it is recommended to log some sort of "cheater Notification" to a Discord or similar
    end
end)
