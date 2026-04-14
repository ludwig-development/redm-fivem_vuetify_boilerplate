if Config.Language ~= "en" then return end

L = {
    ui = {
        welcome          = "Welcome! You opened this interface on %s, frontend language: %s.",
        boilerplate_title = "Vuetify Boilerplate by Ludwig Development!",
        no_event_header  = "I haven't pressed the Event button yet!",
    },

    cards = {
        get_started = {
            title       = "Get started",
            instruction = "Change this page by updating",
            path        = "in components/HelloWorld.vue.",
        },
    },

    server = {
        title       = "Server Info",
        fetching    = "Fetching server info...",
        error       = "Could not reach server",
        refresh_btn = "Refresh",
    },

    header = {
        label       = "Live Event Header",
        trigger_btn = "Trigger Event",
    },

    store = {
        section_title  = "Global Store",
        current_status = "Status:",
        input_label    = "Type something to store it dynamically",
        save_btn       = "Save to Store",
        fallback       = "Make an Input below and press again!",
    },

    snackbar = {
        info    = "This is an info message",
        success = "This was successful!",
        manual  = "Manually triggered with custom config",
        queue_1 = "Queue test 1",
        queue_2 = "Queue test 2",
        image      = "Here's an Apple!",
        appleImage = "This snackbar showcases the apple item image.",
        multi = {
            title   = "Multi Notification",
            message = "This is a multi-type notification.",
        },
        fullscreen = {
            title   = "Fullscreen Alert",
            message = "This is a persistent fullscreen notification.",
        },
    },

    links = {
        snackbar = {
            title = "Test Snackbar",
            text  = "Style your snackbar in components/snackbar.vue",
        },
        nui = {
            title = "NUI -> Serverrouter",
            text  = "Test the Serverrouter, view your Serverconsole for detailed information",
        },
        store = {
            title = "Global Storage",
            text  = "See how the Globalstore stores your input below!",
        },
        events = {
            title = "Events in Action",
            text  = "Change the Header of the Script to see the Events in Action",
        },
    },
}
