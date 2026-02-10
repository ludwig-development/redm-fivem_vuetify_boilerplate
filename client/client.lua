local display = false

function SendHeaderToApp(value)
    SendNUIMessage { action = 'setHeader', data = value }
end

-- sendLanguageToApp() -> your specific function to send your localized Table to the Frontend!
--                     -> See how in the Frontend also the Date display changes depending on your locale
local function sendLanguageToApp()
    SendNUIMessage({
        action = "setLang",
        lang = Config.Language,
        table = L,
    })
end

-- SetDisplay() -> changes the toggle state of our vue app ( isVisible = !isVisible )
--              -> it can also be used to change the app view
function SetDisplay(bool, view)
    Print "setting display"
    display = bool
    if (not view) then
        SendNUIMessage { action = 'openUi', }
    else
        SendNUIMessage { action = 'openUi', payload = { view } }
    end
    SetNuiFocus(bool, bool)
end

-- Removes the NUI Focus as a reaction of Frontend functions / User input
RegisterNUICallback('closeUi', function()
    SetDisplay(false)
end)

-- Command to open the UI ( you can make the view open on any condition of your choice )
RegisterCommand("openview", function()
    sendLanguageToApp()
    SetDisplay(not display)
end, false)


-- This callback is used as an example of receiving data from the app
RegisterNUICallback('setHeadder', function(data)
    Print("i have received the Data: " .. json.encode(data))

    local randomIndex = math.random(1, #Config.myHeaders)
    local randomHeader = Config.myHeaders[randomIndex]

    SendHeaderToApp(randomHeader)
end)
