local notificationEvent = tostring(GetCurrentResourceName()) .. ":SendUserMessage"

function UserNotification(payload, source)
    if source then
        TriggerClientEvent(notificationEvent, source, payload)
    else
        TriggerEvent(notificationEvent, payload)
    end
end
