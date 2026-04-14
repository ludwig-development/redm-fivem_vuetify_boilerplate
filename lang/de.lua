L = L or {}

local DE = {
    ui = {
        welcome          = "Willkommen! Du hast diese Oberfläche am %s geöffnet, frontend Sprache: %s.",
        boilerplate_title = "Vuetify Boilerplate von Ludwig Development!",
        no_event_header  = "Ich habe den Event-Button noch nicht gedrückt!",
    },

    cards = {
        get_started = {
            title       = "Los geht's",
            instruction = "Ändere diese Seite, indem du",
            path        = "in components/HelloWorld.vue aktualisierst.",
        },
    },

    server = {
        title       = "Server-Info",
        fetching    = "Server-Info wird geladen...",
        error       = "Server nicht erreichbar",
        refresh_btn = "Aktualisieren",
    },

    header = {
        label       = "Live-Event-Header",
        trigger_btn = "Event auslösen",
    },

    store = {
        section_title  = "Globaler Store",
        current_status = "Status:",
        input_label    = "Schreib etwas, um es dynamisch zu speichern!",
        save_btn       = "Im Store speichern",
        fallback       = "Mach unten eine Eingabe und drück nochmal!",
    },

    snackbar = {
        info    = "Dies ist eine Info-Nachricht",
        success = "Das war erfolgreich!",
        manual  = "Manuell ausgelöst mit eigener Konfiguration",
        queue_1 = "Warteschlangen-Test 1",
        queue_2 = "Warteschlangen-Test 2",
        image      = "Hier ein Apfel!",
        appleImage = "Diese Snackbar zeigt das Apfel-Item-Bild.",
        multi = {
            title   = "Multi-Benachrichtigung",
            message = "Dies ist eine Benachrichtigung vom Typ Multi.",
        },
        fullscreen = {
            title   = "Vollbild-Alarm",
            message = "Dies ist eine persistente Vollbild-Benachrichtigung.",
        },
    },

    links = {
        snackbar = {
            title = "Snackbar testen",
            text  = "Gestalte deine Snackbar in components/snackbar.vue",
        },
        nui = {
            title = "NUI -> Serverrouter",
            text  = "Teste den Serverrouter, schau in deine Serverkonsole für Details",
        },
        store = {
            title = "Globaler Speicher",
            text  = "Sieh dir an, wie der Globalstore deine Eingabe unten speichert!",
        },
        events = {
            title = "Events in Aktion",
            text  = "Ändere den Header des Skripts, um Events in Aktion zu sehen",
        },
    },
}

if Config.Language == "de" then
    L = DE
    return
end
