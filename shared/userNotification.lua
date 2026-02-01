local notificationEvent = tostring(GetCurrentResourceName()) .. ":SendUserMessage"

function UserNotification(message, type, time, source)
    if source then
        TriggerClientEvent(notificationEvent, source, message, type, time)
    else
        TriggerEvent(notificationEvent, message, type, time)
    end
end
