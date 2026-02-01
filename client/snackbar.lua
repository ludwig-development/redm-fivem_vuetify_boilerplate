local eventName = tostring(GetCurrentResourceName()) .. ":SendUserMessage"

RegisterNetEvent(eventName)
AddEventHandler(eventName, function(message, action, time)
    local payload = {
        text = message,
        color = action,
        timeout = time
    }

    SendNUIMessage { action = 'UserMessage', data = payload }
end)
