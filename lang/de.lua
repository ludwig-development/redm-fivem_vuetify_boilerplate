L = L or {}

DE = {
    welcome = "Willkommen! Du hast diese Oberfläche am %s geöffnet, frontend Sprache: %s.",
    boilerplate_title = "Vuetify Boilerplate von Ludwig Development!",
    no_event_header = "Ich habe den Event-Button noch nicht gedrückt!",
    get_started = "Los geht's",
    update_instruction = "Ändere diese Seite, indem du",
    update_path = "in components/HelloWorld.vue aktualisierst.",
    current_status = "Aktueller Status:",
    input_label = "Schreib etwas, um es dynamisch zu speichern!",
    save_btn = "Im Store speichern",
    -- Links & Actions
    sb_info_msg = "Dies ist eine Info-Nachricht",
    sb_success_msg = "Das war erfolgreich!",
    sb_manual_msg = "Manuell ausgelöst mit eigener Konfiguration",
    sb_queue_1 = "Warteschlangen-Test 1",
    sb_queue_2 = "Warteschlangen-Test 2",
    link_sb_title = "Snackbar testen",
    link_sb_text = "Gestalte deine Snackbar in components/snackbar.vue",
    link_nui_title = "NUI -> Serverrouter",
    link_nui_text = "Teste den Serverrouter, schau in deine Serverkonsole für Details",
    link_store_title = "Globaler Speicher",
    link_store_text = "Sieh dir an, wie der Globalstore deine Eingabe unten speichert!",
    link_event_title = "Events in Aktion",
    link_event_text = "Ändere den Header des Skripts, um Events in Aktion zu sehen",
    store_fallback = "Mach unten eine Eingabe und drück nochmal!"
}

if Config.Language == "de" then
    L = DE
    return
end
