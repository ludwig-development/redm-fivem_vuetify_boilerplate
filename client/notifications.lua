local eventName = tostring(GetCurrentResourceName()) .. ":SendUserMessage"

RegisterNetEvent(eventName)
AddEventHandler(eventName, function(payload)
    -- Legacy guard for: TriggerEvent(eventName, message, action, time) !DONT USE ANYMORE!
    if type(payload) == "string" then
        payload = { message = payload, color = "info", time = 4000, type = "normal" }
    end

    SendNUIMessage {
        action = 'UserMessage',
        data   = {
            text      = payload.message or "",
            color     = payload.color or "info",
            timeout   = payload.time or 4000,
            title     = payload.title,            -- nil -> frontend derives from color
            imagePath = payload.imagePath,        -- nil -> frontend derives from color
            type      = payload.type or "normal", -- "normal" | "multi" | "fullscreen"
        }
    }
end)
