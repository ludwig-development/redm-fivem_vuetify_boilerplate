-- Example EventLogic this is just triggered like a serverevent from the client, no return available just a Serverevent triggered fromt the frontend
EventLogic["myEventName"] = function(source, _)
    local message = "Wow, the nui -> Server Router works ! I am source " .. tostring(source)
    Print(message)

    UserNotification({
        message = message,
        title = "myEventName",
        color = "success",
        type = "multi",
    }, source)
end

-- Example Cllbacklogic to send Data directly to the frontend, all middleware is already in place !
local counter = 0

CallbackLogic["myCallbackName"] = function(src, data)
    local hostname  = GetConvar("sv_hostname", "Unknown Server")
    local cleanName = hostname:gsub("%^%d", ""):lower()

    counter         += 1

    return string.format("This Server is the best: %s | Data pull amount: %d", cleanName, counter)
end
