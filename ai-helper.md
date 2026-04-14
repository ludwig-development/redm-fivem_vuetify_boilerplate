# AI Helper — RedM/FiveM Vuetify Boilerplate

> Technical Reference for AI Coding Assistants
> Based on actual source code — do not guess or generalize.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [fxmanifest.lua Breakdown](#2-fxmanifestlua-breakdown)
3. [initconfig.lua System](#3-initconfiglua-system)
4. [Client-Side Architecture](#4-client-side-architecture)
5. [Server-Side Architecture](#5-server-side-architecture)
6. [Shared Systems](#6-shared-systems)
7. [Language System](#7-language-system)
8. [Frontend Architecture](#8-frontend-architecture)
9. [Data Flow Architecture](#9-data-flow-architecture)
10. [Notification System Flow](#10-notification-system-flow)
11. [Debug System Flow](#11-debug-system-flow)
12. [Event Naming Conventions](#12-event-naming-conventions)
13. [How To Implement Common Features](#13-how-to-implement-common-features)
14. [Developer Workflow Guide](#14-developer-workflow-guide)
15. [AI-Specific Usage Rules](#15-ai-specific-usage-rules)
16. [Full End-To-End Example](#16-full-end-to-end-example)

---

## 1. Project Overview

### What This Resource Is

This is a **production-ready boilerplate** for RedM (Red Dead Redemption 2 multiplayer) and FiveM (GTA V multiplayer) resources. It provides a full-stack template for building NUI (Native User Interface) panels with a modern Vue 3 + Vuetify 3 frontend connected to Lua server/client scripts.

### Main Purpose

- Eliminate boilerplate setup when starting a new UI-heavy RedM/FiveM resource.
- Provide a clean, proven bridge between Vue frontend and Lua backend.
- Include a working notification system, translation system, debug system, and state management out of the box.

### Architecture Style

**Layered, event-driven architecture:**

```
[Vue Frontend (NUI)]
        ↕  (fetch POST / window.message)
[Lua Client Scripts]
        ↕  (TriggerServerEvent / RegisterNetEvent)
[Lua Server Scripts]
```

The UI never talks directly to the server. **All UI → Server communication goes through the client as a relay.**

### Supported Systems

| System            | Technology                                 | Location                                       |
| ----------------- | ------------------------------------------ | ---------------------------------------------- |
| UI Framework      | Vue 3 + Vuetify 3                          | `frontend/src/`                                |
| State Management  | Pinia                                      | `frontend/src/stores/`                         |
| NUI Communication | fetch POST (HTTP) + window.message         | `frontend/src/utils/nui.js` + `App.vue`        |
| Lua Client        | Standard FiveM/RedM Lua                    | `client/`                                      |
| Lua Server        | Standard FiveM/RedM Lua                    | `server/`                                      |
| Shared Logic      | Loaded on both client and server           | `shared/`                                      |
| Translation       | Lua `L` table → Vue `langStore`            | `lang/` + `stores/langStore.js`                |
| Notifications     | `UserNotification()` → custom notification cards | `shared/userNotification.lua` + `Snackbar.vue` + `utils/useNotify.js` |
| Debug             | `DebugPrint()` / `Print()` / `WarnPrint()` | `shared/debugSystem.lua`                       |
| Dependency        | ox_lib (for `lib.callback`)                | External                                       |

### How UI and Lua Communicate

**UI → Lua (sending data):**
The frontend uses `fetch()` with `POST` to `https://{resourceName}/{callbackName}`. This triggers `RegisterNUICallback` on the Lua client side.

**Lua → UI (sending data):**
The Lua client calls `SendNUIMessage({ action = "...", ... })`. The Vue `App.vue` listens via `window.addEventListener("message", ...)` and dispatches to the correct handler.

---

## 2. fxmanifest.lua Breakdown

### Current State of the File

**Important:** The `fxmanifest.lua` file in this repository is **incomplete/truncated** — it contains only the header lines:

```lua
fx_version 'cerulean'
games { 'rdr3', 'gta5' }

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Ludwig Development
```

The file ends abruptly after `author`. The remainder of the manifest (script entries, ui_page, etc.) is missing from the repository as-cloned.

### What a Complete fxmanifest.lua Must Contain

Based on the code patterns observed across all files, the complete manifest must declare:

**Script load order (shared scripts must load first):**

```lua
fx_version 'cerulean'
games { 'rdr3', 'gta5' }

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Ludwig Development'
description 'RedM/FiveM Vuetify Boilerplate by Ludwig Development'
version '1.1.1'

-- Shared scripts run on BOTH client and server
shared_scripts {
    'initconfig.lua',          -- MUST be first: initializes Config = {}
    'shared/utils/*.lua',      -- debug, translation, notification utilities
    'shared/*.lua',            -- specific_config, userNotification
    'lang/*.lua',              -- language tables
}

-- Client-only scripts
client_scripts {
    'client/snackbar.lua',
    'client/serverRouter.lua',
    'client/client.lua',
}

-- Server-only scripts
server_scripts {
    '@ox_lib/init.lua',        -- ox_lib dependency for lib.callback
    'server/nuiRouter.lua',
    'server/server.lua',
}

-- NUI (frontend) configuration
ui_page 'frontend/dist/index.html'

files {
    'frontend/dist/**',
}

dependency 'ox_lib'
```

### Critical Load Order Rules

1. **`initconfig.lua` must be the very first shared script.** It initializes `Config = {}` before any other shared script tries to write to it. If loaded out of order, `specific_config.lua` will crash trying to assign to a nil table.

2. **`shared/utils/*.lua` before `shared/*.lua`** — utility functions (`DebugPrint`, `UserNotification`, `T`) must exist before `specific_config.lua` uses them.

3. **`lang/*.lua` is loaded as shared** so both client and server have access to the `L` table (used by `T()` and sent to the frontend by the client).

4. **Server scripts must include `@ox_lib/init.lua`** before `nuiRouter.lua`, because `nuiRouter.lua` uses `lib.callback.register(...)`.

5. **`client/serverRouter.lua` must load before `client/client.lua`** is recommended (though both use independent callbacks so order is less critical on the client).

### How to Add New Scripts

- **New shared file:** Add path to `shared_scripts {}`, after `shared/*.lua`.
- **New client file:** Add path to `client_scripts {}` in load order appropriate to dependencies.
- **New server file:** Add path to `server_scripts {}` after `nuiRouter.lua` if it uses `EventLogic` or `CallbackLogic` tables (because `nuiRouter.lua` declares those tables).
- **Never add Lua files that contain server credentials/webhooks to `shared_scripts`** — shared scripts are loaded on the client too.

---

## 3. initconfig.lua System

### File Location

`initconfig.lua` — root of the resource (loaded first among shared scripts).

### What It Does

```lua
-- File is only to ensure the global Config Table before the fxmanifest loads
-- the shared folder in random order
Config = {}

Config.Debug = true
```

It exists for **one critical reason**: FiveM/RedM loads shared script files in an unspecified order. If `specific_config.lua` were to run before any file initializes `Config`, writing `Config.Language = "de"` would crash. This file guarantees `Config` exists as an empty table first.

### Config Values (all defined in `shared/specific_config.lua`)

| Key                | Type                     | Default    | Purpose                                                              |
| ------------------ | ------------------------ | ---------- | -------------------------------------------------------------------- |
| `Config.Debug`     | boolean                  | `true`     | Enables `DebugPrint()` output                                        |
| `Config.Language`  | string                   | `"de"`     | Selects the active language (`"en"` or `"de"` or any added language) |
| `Config.myHeaders` | table (array of strings) | 18 strings | Example array used by client event demo                              |

### How Configuration Is Accessed

```lua
-- Anywhere in shared/client/server Lua:
if Config.Debug then ... end

local lang = Config.Language  -- "de" or "en"

local header = Config.myHeaders[math.random(1, #Config.myHeaders)]
```

The `Config` table is global and available everywhere after the shared scripts load.

### How to Add New Config Options

Add them to `shared/specific_config.lua`, **not** to `initconfig.lua`:

```lua
-- In shared/specific_config.lua
Config.MyNewOption = "value"
Config.MyNewTable = { "a", "b", "c" }
Config.MyFlag = false
```

**Rule:** `initconfig.lua` only ever contains `Config = {}` and `Config.Debug`. All other config goes in `shared/specific_config.lua` or a new file in `shared/`.

---

## 4. Client-Side Architecture

### client/client.lua

**Purpose:** Entry point for client-side logic. Contains NUI callbacks and the UI open/close system.

#### Key Variables

```lua
local display = false  -- tracks current UI visibility state
```

#### Functions

**`SendHeaderToApp(value)`** — Public function. Sends a `setHeader` action to the Vue frontend:

```lua
function SendHeaderToApp(value)
    SendNUIMessage { action = 'setHeader', data = value }
end
```

The frontend handler in `App.vue` catches `setHeader` and calls `store.setValue("header", value)`.

**`sendLanguageToApp()`** — Private function. Sends the Lua language table to the Vue frontend:

```lua
local function sendLanguageToApp()
    SendNUIMessage({
        action = "setLang",
        lang = Config.Language,
        table = L,
    })
end
```

This sends the entire `L` table (the loaded language table from `lang/`) plus the language code to Vue, where `langStore` picks it up.

**`SetDisplay(bool, view)`** — Public function. Opens or closes the NUI panel:

```lua
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
```

- `bool = true` → show UI, give NUI focus and cursor
- `bool = false` → hide UI, release NUI focus
- `view` is an optional string that routes the Vue app to a specific page (matched in `App.vue`'s `openUi` switch)

#### NUI Callbacks Registered

**`closeUi`** — Called by the Vue frontend (e.g., Escape key press):

```lua
RegisterNUICallback('closeUi', function()
    SetDisplay(false)
end)
```

**`setHeadder`** (note: intentional typo in the original code, do not fix it) — Called by Vue to request a new random header:

```lua
RegisterNUICallback('setHeadder', function(data)
    Print("i have received the Data: " .. json.encode(data))
    local randomIndex = math.random(1, #Config.myHeaders)
    local randomHeader = Config.myHeaders[randomIndex]
    SendHeaderToApp(randomHeader)
end)
```

#### Commands Registered

**`openview`** — Console/chat command to toggle the UI:

```lua
RegisterCommand("openview", function()
    sendLanguageToApp()
    SetDisplay(not display)
end, false)
```

The `false` parameter means the command is not restricted to admins.

---

### client/serverRouter.lua

**Purpose:** Provides the NUI-to-Server relay. All frontend → server communication goes through one of two NUI callbacks defined here.

#### How It Works

The file constructs its event names dynamically:

```lua
local eventName = tostring(GetCurrentResourceName()) .. ":serverRouter"
local resourceName = GetCurrentResourceName()
```

#### NUI Callback: `ServerRouter` (fire-and-forget)

```lua
RegisterNUICallback("ServerRouter", function(data, cb)
    DebugPrint "ServerRouter Starts: "
    DebugPrint(json.encode(data))

    if data and data.action then
        TriggerServerEvent(eventName, data.action, data.data or {})
    end

    cb { success = true }
end)
```

- Expects `data.action` (string) and optionally `data.data` (table).
- Fires a server event `{resourceName}:serverRouter` with the action and data.
- Returns `{ success = true }` immediately to the frontend — does NOT wait for server response.
- Used for **fire-and-forget** server events (no return value needed by the UI).

#### NUI Callback: `ServerCallbackRouter` (with response)

```lua
RegisterNUICallback("ServerCallbackRouter", function(data, cb)
    if not data or not data.action then
        return cb({ success = false, error = "Invalid Request" })
    end

    local result = lib.callback.await(resourceName .. ":serverCallbackRouter", false, data.action, data.data)
    cb(result)
end)
```

- Uses `lib.callback.await` from **ox_lib** to synchronously wait for a server response.
- Returns the server's response directly to the Vue frontend via `cb(result)`.
- Used when **the UI needs data back from the server**.
- **Edge case — `data.data` is not guarded:** The event router uses `data.data or {}` but this callback router passes `data.data` directly. If the frontend sends no `data` field, the server callback receives `nil` as its `data` parameter. The frontend utility `requestServerData(action, payload = {})` always passes `{}` as a default, so this is safe when using the utility. If calling `postNUI('ServerCallbackRouter', ...)` directly without a `data` key, server-side code must guard with `data = data or {}`.

---

### client/snackbar.lua

**Purpose:** Receives server-triggered notification events and forwards them to the Vue snackbar UI.

#### Event Name Construction

```lua
local eventName = tostring(GetCurrentResourceName()) .. ":SendUserMessage"
```

#### Event Handler

```lua
RegisterNetEvent(eventName)
AddEventHandler(eventName, function(message, action, time)
    local payload = {
        text = message,
        color = action,
        timeout = time
    }
    SendNUIMessage { action = 'UserMessage', data = payload }
end)
```

**Data mapping:**

- `message` (string) → `payload.text` → displayed as the notification body
- `action` (string) → `payload.color` → notification type (`"success"`, `"error"`, `"info"`, `"warning"`)
- `time` (number, milliseconds) → `payload.timeout` → auto-dismiss duration

The `SendNUIMessage` with `action = 'UserMessage'` is caught in `App.vue` and calls `snackbar.showSnackbar(itemData.data)`, which delegates to `useNotify().show()` to display a custom notification card.

#### Trigger a Notification from Client Lua

```lua
-- From anywhere in client Lua:
TriggerEvent(GetCurrentResourceName() .. ":SendUserMessage", "Hello!", "success", 4000)
```

Or more cleanly, use `UserNotification()` from shared (it handles routing):

```lua
UserNotification("Hello!", "success", 4000)
-- Note: no source argument → fires local client event
```

---

## 5. Server-Side Architecture

### server/server.lua

**Purpose:** Example server event registration showing the intended pattern.

#### Current Content

```lua
RegisterNetEvent("myRessourceName:myEventName")
AddEventHandler("myRessourceName:myEventName", function(source, data)
    local message = "Wow, the nui -> Server Router works ! I am source " .. tostring(source)
    Print(message)
    UserNotification(message, "success", 4000, source)
end)
```

**This code contains Bug 4.** The `AddEventHandler("myRessourceName:myEventName", ...)` pattern is **incompatible with the NUI router**. The router dispatches events via `EventLogic[action]`, not via named net events. This handler is never reached through the router.

Additionally, the frontend demo (HelloWorld.vue) sends `event: 'myRessourceName:myEventName'` (Bug 3) instead of `action: 'myEventName'`, so the full demo chain is doubly broken: wrong field name on the frontend AND wrong registration pattern on the server.

**The correct production pattern** is:

```lua
-- In server/server.lua (or any server file loaded after nuiRouter.lua):
EventLogic["myEventName"] = function(src, data)
    local message = "Router works! Source: " .. tostring(src)
    Print(message)
    UserNotification(message, "success", 4000, src)
end
```

`EventLogic` is a global table declared in `nuiRouter.lua`. Any server file can add to it. `"myEventName"` must also be present in `AllowedFunctions` in `nuiRouter.lua` (it already is in the boilerplate).

---

### server/nuiRouter.lua

**Purpose:** Central router for all UI → Server communication. Provides security whitelisting and dispatches to logic functions.

#### Architecture

The router uses two global tables declared at the top:

```lua
EventLogic = EventLogic or {}
CallbackLogic = CallbackLogic or {}
```

These tables are global so that **any server file** can add handlers to them:

```lua
-- In any server file:
EventLogic["myEventName"] = function(src, data) ... end
CallbackLogic["myCallbackName"] = function(src, data) return {...} end
```

#### Security: Allowlist

```lua
local USE_ALLOWED_FUNCTIONS = true  -- enables whitelist security

local AllowedFunctions = {
    ["myEventName"] = true,
    ["myCallbackName"] = true
}
```

When `USE_ALLOWED_FUNCTIONS = true`, any action name not in `AllowedFunctions` is rejected and triggers a warning + player notification. Set to `false` to disable the allowlist (not recommended in production).

#### Internal Validation

```lua
local function validateKey(key, src)
    if type(key) ~= "string" or key == "" then
        WarnPrint("[Router] Invalid function key received")
        if src then UserNotification("Invalid request", "error", 4000, src) end
        return false
    end
    return true
end
```

#### Event Router (fire-and-forget)

**Event name:** `{resourceName}:serverRouter`

```lua
RegisterNetEvent(eventRouterName)
AddEventHandler(eventRouterName, function(action, data)
    local src = source
    -- validates key → checks allowlist → calls EventLogic[action](src, data)
    -- wraps in pcall for error safety
end)
```

Dispatches to `EventLogic[action](src, data)`.

#### Callback Router (with response)

**Callback name:** `{resourceName}:serverCallbackRouter`

```lua
lib.callback.register(callbackRouterName, function(source, action, data)
    -- validates key → checks allowlist → calls CallbackLogic[action](source, data)
    -- returns result to client
end)
```

Dispatches to `CallbackLogic[action](source, data)` and returns the result. The return value must be a table (serializable to JSON).

**Contains Bug 2:** The allowlist-block branch on line 83 calls `GetPlayerName(src)` but the parameter is named `source`. `src` is undefined in this scope and will be nil, causing a runtime crash when any non-whitelisted callback is attempted.

**Contains Bug 1:** On success, line 108 calls `JsonPrint(result)` which is undefined — this crashes on every successful callback. Fix by defining `JsonPrint` or replacing the call with `DebugPrint(json.encode(result))`.

#### Register a New Server Event Handler

**Step 1:** Add to allowlist in `nuiRouter.lua`:

```lua
local AllowedFunctions = {
    ["myEventName"] = true,
    ["myNewAction"] = true,   -- add here
}
```

**Step 2:** Add logic in `server/server.lua` (or any server file loaded after `nuiRouter.lua`):

```lua
EventLogic["myNewAction"] = function(src, data)
    Print("Received myNewAction from " .. tostring(src))
    -- do server logic
end
```

**Do NOT use `RegisterNetEvent`/`AddEventHandler` for router-dispatched events.** The router only calls functions in the `EventLogic` table; it does not fire named net events (see Bug 4). `EventLogic` is a global table — assign to it from any server file.

#### Register a New Server Callback Handler

**Step 1:** Add to allowlist:

```lua
local AllowedFunctions = {
    ["myCallbackName"] = true,
    ["getPlayerInventory"] = true,  -- add here
}
```

**Step 2:** Add logic:

```lua
CallbackLogic["getPlayerInventory"] = function(src, data)
    local items = { "water", "bread" }  -- fetch real data
    return { success = true, items = items }
end
```

The return value goes directly to the Vue frontend as JSON.

---

## 6. Shared Systems

Shared scripts are loaded on **both client and server**. Do not put server-only secrets here.

### Debug System

**Files:** `shared/debugSystem.lua` (root) AND `shared/utils/debugSystem.lua`

**Critical fact — two files define the same functions.** Both files define `DebugPrint`, `Print`, and `WarnPrint`. Whichever file loads second will overwrite the definitions from the first. The final active behavior depends entirely on manifest load order (which is unknown because the fxmanifest is truncated). Do not rely on which file "wins" — the behavior of `WarnPrint` differs between them (see below).

**Differences between the two files:**

| Feature                | `shared/debugSystem.lua` (root) | `shared/utils/debugSystem.lua` |
| ---------------------- | ------------------------------- | ------------------------------ |
| Line endings           | CRLF                            | LF                             |
| `WarnPrint` color code | `^3` (yellow)                   | `^1` (red)                     |
| `ErrorPrint` defined   | Yes (`^1` red)                  | No                             |
| `DebugPrint`           | Identical                       | Identical                      |
| `Print`                | Identical                       | Identical                      |

#### Available Functions

**`Print(...)`** — Always prints, regardless of `Config.Debug`. Accepts multiple arguments; tables are JSON-encoded, booleans become `"true"`/`"false"`:

```lua
Print("Player logged in")
Print("Data received:", someTable)  -- tables are auto-encoded to JSON
Print("Flag:", someBool)            -- booleans print as "true"/"false"
```

Output format:

```
[resourceName] @resourceName/server/server.lua:12 (functionName) Player logged in
```

**`DebugPrint(...)`** — Only prints when `Config.Debug == true`. Same argument handling as `Print`:

```lua
DebugPrint("Entering callback for action: " .. action)
DebugPrint(3, "...")  -- optional first-arg number = stack level offset
```

**`WarnPrint(singleString)`** — Prints with color. **Accepts exactly one string argument** (see Bug 5 above). Color depends on which file loaded last (`^3` yellow or `^1` red):

```lua
WarnPrint("[Router] Blocked event: " .. key)  -- single string concatenation is safe
```

**`ErrorPrint(singleString)`** — Prints in `^1` red. Only defined in `shared/debugSystem.lua` (root), NOT in `shared/utils/debugSystem.lua`. **Same single-string limitation as `WarnPrint`.**

**`JsonPrint(data)`** — Called in `nuiRouter.lua` but **not defined anywhere** (see Bug 1). Must be added before the router will function.

#### Stack Level Override

All `Print`/`DebugPrint` calls accept an optional leading number as the first argument to adjust which stack frame is reported:

```lua
DebugPrint(3, "This shows the caller's caller in the output")
-- Level 2 = default (direct caller)
-- Level 3 = caller's caller (used by WarnPrint internally)
```

#### Enabling/Disabling Debug

In `initconfig.lua`:

```lua
Config.Debug = true   -- enable DebugPrint output
Config.Debug = false  -- disable (silences all DebugPrint calls; Print/WarnPrint/ErrorPrint are unaffected)
```

---

### Notification System

**Files:** `shared/userNotification.lua` (CRLF) and `shared/utils/userNotification.lua` (LF)

Both files contain **identical Lua logic** but differ only in line endings. Both define the same `UserNotification` function. Whichever loads second overwrites the first; the behavior is the same regardless. This duplication is safe but redundant.

```lua
local notificationEvent = tostring(GetCurrentResourceName()) .. ":SendUserMessage"

function UserNotification(message, type, time, source)
    if source then
        TriggerClientEvent(notificationEvent, source, message, type, time)
    else
        TriggerEvent(notificationEvent, message, type, time)
    end
end
```

**Parameters:**

| Parameter | Type          | Description                                                                                         |
| --------- | ------------- | --------------------------------------------------------------------------------------------------- |
| `message` | string        | The text displayed in the notification card body                                                    |
| `type`    | string        | Notification type: `"success"`, `"error"`, `"info"`, `"warning"` — controls icon image and progress bar color |
| `time`    | number        | Milliseconds before auto-dismiss (e.g., `4000`)                                                     |
| `source`  | number or nil | Player server ID. If provided → sends to that client. If nil → fires local event (client-side only) |

**From server (send to specific player):**

```lua
UserNotification("Item added!", "success", 4000, source)
```

**From client (send to self):**

```lua
UserNotification("Action completed!", "info", 3000)
-- or equivalently:
UserNotification("Action completed!", "info", 3000, nil)
```

---

### Translation System

**File:** `shared/utils/translation.lua`

```lua
function T(key)
    return L?[key] or DE?[key] or "Localisation missing ! Key:" .. tostring(key)
end
```

**Behavior:**

1. Looks up `key` in `L` (the active language table, set by the lang file that matches `Config.Language`)
2. Falls back to `DE` table (always loaded from `lang/de.lua`)
3. Falls back to an error string `"Localisation missing ! Key:keyname"` if neither has the key

**Usage:**

```lua
local text = T("welcome")         -- returns localized "Welcome!" string
local title = T("boilerplate_title")
```

Note: The `?` operator in `L?[key]` is Lua 5.4+ safe-navigation. In FiveM/RedM Lua this is supported.

---

## 7. Language System

### File Structure

```
lang/
  en.lua   -- English translations
  de.lua   -- German translations (always loaded as DE table)
```

### lang/en.lua

```lua
if Config.Language ~= "en" then return end

L = {
    welcome = "Welcome! You opened this interface on %s, frontend language: %s.",
    boilerplate_title = "Vuetify Boilerplate by Ludwig Development!",
    -- ... all keys
}
```

**Conditional guard:** Only sets `L` if the configured language is `"en"`. Otherwise the file returns early.

### lang/de.lua

```lua
L = L or {}

DE = {
    welcome = "Willkommen! Du hast diese Oberfläche am %s geöffnet, frontend Sprache: %s.",
    -- ... all keys
}

if Config.Language == "de" then
    L = DE
    return
end
```

**Key differences:**

- `DE` is always set (used as fallback in `T()`)
- If `Config.Language == "de"`, `L = DE` so `T()` works via the primary `L` table
- The `L = L or {}` guard prevents overwriting a previously set `L`

### Load Order Behavior

Both language files are in `shared_scripts` (loaded by both client and server). The system is deliberately **load-order independent**:

- `de.lua` always sets `DE` (the full German table). The `L = L or {}` guard at the top preserves any existing `L` value. Only if `Config.Language == "de"` does it assign `L = DE` and return.
- `en.lua` only sets `L = {...}` when `Config.Language == "en"`, otherwise returns early.
- If `de.lua` runs before `en.lua` with language "en": `de.lua` sets `DE`, leaves `L` as `{}` (guard), `en.lua` then overwrites `L` with English. Correct.
- If `en.lua` runs before `de.lua` with language "en": `en.lua` sets `L` to English table, `de.lua` sees `L = L or {}` (L is already truthy), keeps `L` as English, sets `DE`. Correct.
- `DE` is **always populated** regardless of language setting. It serves as the fallback in `T()`. This means the German string table is always in memory even when using English.
- After both files load: `L` is the active language table, `DE` is always the German table.

### Key Naming Rules

- Snake_case keys: `welcome`, `boilerplate_title`, `no_event_header`
- Groups separated by underscore: `link_sb_title`, `link_sb_text`
- Button labels: `save_btn`, `get_started`
- No dots, no camelCase

### How to Add a New Language

**Step 1:** Create `lang/fr.lua`:

```lua
L = L or {}

FR = {
    welcome = "Bienvenue! ...",
    boilerplate_title = "Boilerplate Vuetify par Ludwig Development!",
    -- copy all keys from en.lua and translate
}

if Config.Language == "fr" then
    L = FR
    return
end
```

**Step 2:** Add to `shared/specific_config.lua`:

```lua
Config.Language = "fr"
```

**Step 3:** Add the locale to `langStore.js` in `LOCALE_MAP`:

```js
const LOCALE_MAP = {
    de: 'de-DE',
    en: 'en-US',
    fr: 'fr-FR',   -- add this
}
```

**Step 4:** Add `lang/fr.lua` to `fxmanifest.lua` shared_scripts (or keep glob pattern `'lang/*.lua'`).

### How to Add a New Translation Key

**Step 1:** Add to `lang/en.lua`:

```lua
L = {
    -- existing keys...
    my_new_key = "My new translated string",
}
```

**Step 2:** Add same key to `lang/de.lua`:

```lua
DE = {
    -- existing keys...
    my_new_key = "Mein neuer übersetzter String",
}
```

**Step 3 (optional):** Use in Lua with `T("my_new_key")`.

**Step 4:** The key is automatically available in Vue after `sendLanguageToApp()` is called, via `lang.t('my_new_key')`.

---

## 8. Frontend Architecture

### Vue App Startup

**File:** `frontend/src/main.ts`

```ts
import { registerPlugins } from "@/plugins";
import App from "./App.vue";
import { createApp } from "vue";
import "unfonts.css";

const app = createApp(App);
registerPlugins(app);
app.mount("#app");
```

Startup sequence:

1. Create Vue 3 app from `App.vue`
2. `registerPlugins(app)` registers Vuetify, Vue Router, and Pinia
3. Mount to `#app` in `index.html`

---

### Plugin Registration

**File:** `frontend/src/plugins/index.ts`

```ts
import vuetify from "./vuetify";
import pinia from "../stores";
import router from "../router";

export function registerPlugins(app: App) {
  app.use(vuetify).use(router).use(pinia);
}
```

All three plugins are registered in a single call chain.

---

### Routing System

**File:** `frontend/src/router/index.ts`

```ts
import { createRouter, createWebHashHistory } from "vue-router";
import { setupLayouts } from "virtual:generated-layouts";
import { routes } from "vue-router/auto-routes";

const router = createRouter({
  history: createWebHashHistory(),
  routes: setupLayouts(routes),
});
```

**Key facts:**

- Uses **hash history** (`createWebHashHistory`) — required for NUI file:// serving
- Routes are **auto-generated** from `frontend/src/pages/` using `unplugin-vue-router`
- Layouts are **auto-applied** via `vite-plugin-vue-layouts-next`
- **No manual route registration is needed** — just create a `.vue` file in `pages/`

**File → Route mapping:**

```
pages/index.vue          → /
pages/about.vue          → /about
pages/inventory/index.vue → /inventory
pages/inventory/[id].vue  → /inventory/:id
```

**How to add a new page:**

1. Create `frontend/src/pages/mypage.vue`
2. Route `/mypage` is automatically available — no router config changes needed

---

### Layout System

**File:** `frontend/src/layouts/default.vue`

```vue
<template>
  <v-main>
    <router-view />
  </v-main>
</template>
```

- This is the **only layout** and it wraps all pages by default
- `<v-main>` is a Vuetify component that provides correct padding/sizing context
- All pages under `pages/` automatically use this layout unless they specify otherwise

**To use a different layout for a page**, specify it with a route block:

```vue
<!-- In a page file -->
<route lang="yaml">
meta:
  layout: custom
</route>
```

Then create `frontend/src/layouts/custom.vue`.

---

### App.vue — Root Component

**File:** `frontend/src/App.vue`

This is the most critical file for understanding NUI communication.

#### Template Structure

```vue
<template>
  <v-app theme="your_theme">
    <Snackbar />
    <router-view v-show="isVisible" />
  </v-app>
</template>
```

- `<v-app theme="your_theme">` — applies the Vuetify theme; `"your_theme"` matches the theme name in `vuetify.ts`
- `<Snackbar />` — always mounted (outside `v-show`) so notifications display even after UI closes
- `<router-view v-show="isVisible">` — the actual page content, shown/hidden via `isVisible`

#### Visibility Control

```js
const isVisible = ref(false);
```

The `openUi` function toggles visibility and navigates to the correct route:

```js
const openUi = async (view = "") => {
  let targetPath = "/";
  switch (view) {
    case "yourView":
      targetPath = "/yourview";
      break;
    default:
      targetPath = "/";
  }
  await router.push(targetPath);
  isVisible.value = !isVisible.value; // always TOGGLES, never sets
};
```

**Critical behavioral fact — `isVisible` always toggles, it is never set to a specific boolean.** `SetDisplay(true)` in Lua sends `action = 'openUi'`, and `SetDisplay(false)` also sends `action = 'openUi'`. Both trigger the same `openUi()` handler in Vue, which always does `!isVisible.value`. There is no "force show" or "force hide" signal from Lua to Vue.

This means:

- If `SetDisplay(true)` is called when the UI is already visible, `isVisible` becomes `false` (UI hides). This is a desync bug.
- The safe Lua pattern is the one in `client.lua`: `SetDisplay(not display)` — always pass the opposite of the current state, tracking state in the `display` variable.
- Never call `SetDisplay(true)` unconditionally without first checking `display == false`.

**To add a new routable view**, add a case to this switch:

```js
case "inventory":
  targetPath = '/inventory';
  break;
```

#### Message Handler Registry

All NUI messages from Lua are dispatched through this `handlers` object:

```js
const handlers = {
  openUi: (itemData) => { ... },       // toggle visibility, optional route
  UserMessage: (itemData) => { ... },  // show snackbar
  setLang: (itemData) => { ... },      // set language data in langStore
  setHeader: (itemData) => { ... },    // custom: stores header in globalStore
};
```

**To add a new NUI message handler:**

```js
const handlers = {
  // ... existing handlers ...
  myNewAction: (itemData) => {
    // itemData is the full message object { action: "myNewAction", data: ... }
    console.log("Received:", itemData.data);
    store.setValue("myKey", itemData.data);
  },
};
```

Then from Lua client:

```lua
SendNUIMessage({ action = "myNewAction", data = "hello" })
```

#### Event Listener Setup

```js
const handleMessageListener = (event) => {
  const itemData = event?.data;
  if (handlers[itemData.action]) handlers[itemData.action](itemData);
};

onMounted(() => {
  window.addEventListener("message", handleMessageListener);
  window.addEventListener("keydown", handleKeydown);
});
```

#### Escape Key Handling

```js
const handleKeydown = (e) => {
  if (e.key === "Escape") {
    fetch(`https://${GetParentResourceName()}/closeUi`, { method: "POST" });
  }
};
```

Escape sends a `closeUi` NUI callback to Lua, which calls `SetDisplay(false)`.

**Dev-mode crash:** Unlike `nui.js` which guards with `window.GetParentResourceName ? window.GetParentResourceName() : 'your_resource_name'`, this direct call has **no fallback**. Pressing Escape during browser development (`npm run dev`) will throw `ReferenceError: GetParentResourceName is not defined` and the UI will be unclosable via keyboard. This only matters during development; in-game it works correctly.

---

### Store System (Pinia)

#### Pinia Instance

**File:** `frontend/src/stores/index.ts`

```ts
import { createPinia } from "pinia";
export default createPinia();
```

One Pinia instance, registered in `plugins/index.ts`.

---

#### app.ts — Placeholder Store

**File:** `frontend/src/stores/app.ts`

```ts
export const useAppStore = defineStore("app", {
  state: () => ({
    //
  }),
});
```

Currently empty. Provided as a starting point for app-level state that doesn't fit other stores. **Safe to add state here.**

---

#### useGlobalStore.js — General Key-Value Store

**File:** `frontend/src/stores/useGlobalStore.js`

```js
export const useGlobalStore = defineStore("global", () => {
  const data = ref({});

  function setValue(key, value) {
    data.value[key] = value;
  }
  function getValue(key) {
    return data.value[key];
  }

  return { data, setValue, getValue };
});
```

**Usage:**

```js
const store = useGlobalStore();
store.setValue("header", "New Header Text");
const header = store.getValue("header"); // "New Header Text"
```

Used in `HelloWorld.vue` for the header display and status. Any NUI message can write arbitrary key-value pairs here.

**In templates:**

```vue
{{ store.getValue("header") || "Fallback text" }}
```

---

#### langStore.js — Translation Store

**File:** `frontend/src/stores/langStore.js`

```js
const LOCALE_MAP = {
    de: 'de-DE', en: 'en-US', fr: 'fr-FR', es: 'es-ES', it: 'it-IT', pt: 'pt-PT'
}

export const useLangStore = defineStore('lang', {
    state: () => ({
        lang: 'en',       // language code
        locale: 'en-US',  // locale string for Intl APIs
        table: {}         // the full L table from Lua
    }),

    getters: {
        t: (state) => (key, ...args) => {
            const keys = key.split('.');
            let text = keys.reduce((obj, i) => obj?.[i], state.table) ?? key;
            if (typeof text === 'string') {
                let i = 0;
                return text.replace(/%[sd]/g, () => args[i++] ?? '');
            }
            return text;
        }
    },

    actions: {
        setLangData({ lang, table }) { ... }
    }
})
```

**The `t` getter** works exactly like Lua `string.format` with `%s`/`%d` placeholders:

```js
// In Lua: welcome = "Welcome! Opened on %s, language: %s."
lang.t("welcome", formattedDate, lang.locale);
// → "Welcome! Opened on 01/04/26, language: en-US."
```

**Nested key access** uses dot notation:

```js
lang.t("section.nested_key"); // reads table.section.nested_key
```

**Missing key fallback:** If a key is not in `state.table`, the getter returns the key string itself (`?? key`). For example, `lang.t('nonexistent_key')` returns `"nonexistent_key"`, not an error. This differs from Lua `T()` which returns `"Localisation missing ! Key:nonexistent_key"`. There is no console warning.

**Before `setLangData` is called (empty table):** The default `state.table = {}` means all `lang.t('key')` calls return the key name itself. If the UI is somehow rendered before `sendLanguageToApp()` runs, all text will display as raw key names.

**`LOCALE_MAP` includes languages with no Lua files:** The store pre-maps `fr`, `es`, `it`, `pt` to locale strings, but only `lang/en.lua` and `lang/de.lua` exist. These entries are forward-compatibility placeholders. An unknown language code falls back to `${lang}-${lang.toUpperCase()}` (e.g., `"ja"` → `"ja-JA"` instead of the correct `"ja-JP"`).

**Populated by:** `setLang` action in `App.vue` which receives `{ lang, table }` from `SendNUIMessage({ action = "setLang", lang = Config.Language, table = L })`.

**Important sequence requirement:** `sendLanguageToApp()` must be called **before** `SetDisplay(true)`. The `openview` command does this correctly. If you call `SetDisplay(true)` without first calling `sendLanguageToApp()`, the UI opens with an empty translation table and all text shows as key names.

**Usage in Vue components:**

```js
import { useLangStore } from "@/stores/langStore";
const lang = useLangStore();
// In template: {{ lang.t('my_key') }}
// In script:   lang.t('my_key', arg1, arg2)
```

---

#### snackbar.js — Notification Store (Delegates to useNotify)

**File:** `frontend/src/stores/snackbar.js`

The store holds **no state of its own**. It is a thin API adapter that delegates every call to `useNotify()`. This preserves the existing Lua-side event contract (`text`, `color`, `timeout`) while routing all display through the custom notification card system.

```js
export const useSnackbarStore = defineStore('snackbar', {
  actions: {
    showSnackbar(payload) { ... },  // accepts string or { text, color, timeout, title, type, imagePath }
    success(message, timeout = 4000) { ... },
    error(message, timeout = 5000) { ... },
    warning(message, timeout = 4000) { ... },
    info(message, timeout = 4000) { ... },
  }
})
```

**`showSnackbar` accepts two payload formats:**

```js
// String shorthand (defaults: imagePath=info, time=4000, type=normal):
snackbar.showSnackbar("Operation complete!");

// Object — legacy fields (text, color, timeout) are fully supported:
snackbar.showSnackbar({ text: "Custom message", color: "warning", timeout: 2000 });

// Object — extended fields for direct useNotify control:
snackbar.showSnackbar({ title: "Alert", message: "Something happened", imagePath: "warning", time: 3000, type: "multi" });
```

**Shorthand methods:**

```js
snackbar.success("Saved!", 3000);   // success.png icon, "Success" title
snackbar.error("Failed!", 5000);    // error.png icon, "Error" title
snackbar.warning("Check this");     // warning.png icon, "Warning" title
snackbar.info("FYI");               // info.png icon, "Info" title
```

**Color → image mapping:**

| `color` value | Icon image used    |
| ------------- | ------------------ |
| `"success"`   | `assets/success.png` |
| `"error"`     | `assets/error.png`   |
| `"warning"`   | `assets/warning.png` |
| `"info"`      | `assets/info.png`    |

**Queue behavior:** Up to 5 normal notifications can be visible simultaneously (oldest is evicted if the limit is exceeded). Each notification auto-dismisses after its `time` duration. There is no sequential waiting — all queued notifications are rendered at once via `transition-group`.

---

### Notification UI System

**File:** `frontend/src/components/Snackbar.vue` (acts as the NotificationManager)

`Snackbar.vue` is no longer a Vuetify `v-snackbar`. It is a full notification manager that renders all three notification types. The filename is kept as `Snackbar.vue` so `App.vue` requires no changes.

```vue
<template>
  <div class="notification-layer">         <!-- fixed inset:0, pointer-events:none, z-index:9990 -->

    <transition name="fade">
      <FullscreenNotification v-if="fullscreenActive" :notification="fullscreenActive" />
    </transition>

    <div class="multi-container">          <!-- top-center, drops in from above -->
      <transition-group name="slide-down">
        <MultiNotification v-for="n in multiQueue" :key="n.id" :notification="n" />
      </transition-group>
    </div>

    <div class="normal-container">        <!-- top-right, slides in from right -->
      <transition-group name="slide-left">
        <NormalNotification v-for="n in normalQueue" :key="n.id" :notification="n" />
      </transition-group>
    </div>

  </div>
</template>
```

**Sub-components (in `src/components/notifications/`):**

| Component | Description | Max visible | Position |
| --------- | ----------- | ----------- | -------- |
| `NormalNotification.vue` | 300px card with icon + title + text + progress bar | 5 | Top-right, slides from right |
| `MultiNotification.vue` | 450px wider card, same structure | 3 | Top-center, drops from above |
| `FullscreenNotification.vue` | Full `v-overlay` with large image + text | 1 (replaces) | Center overlay |

**useNotify composable (`src/utils/useNotify.js`):**

Module-level singleton — all callers share the same queues. Manages three reactive queues:

```js
const normalQueue = ref([])      // max 5 concurrent
const multiQueue = ref([])       // max 3 concurrent
const fullscreenActive = ref(null)  // single slot

// show() payload fields:
{
  title: string,      // card header (default: 'Notification')
  message: string,    // card body text
  time: number,       // ms before auto-remove (default: 4000)
  imagePath: string,  // 'success' | 'error' | 'warning' | 'info' or custom item name
  type: string,       // 'normal' | 'multi' | 'fullscreen' (default: 'normal')
}
```

**Progress bar color** is derived from the resolved image path (e.g. a path containing `"success"` → `success` Vuetify color). The progress bar CSS transition duration is bound to the notification's `Time` value.

**The component is mounted in `App.vue` outside `v-show="isVisible"`**, so notifications persist even after the UI panel closes.

---

### NUI Communication

**File:** `frontend/src/utils/nui.js`

This is the sole utility for sending data from Vue to Lua.

#### `postNUI(eventName, data)` — Raw NUI POST

```js
export async function postNUI(eventName, data = {}) {
  const resourceName = window.GetParentResourceName
    ? window.GetParentResourceName()
    : "your_resource_name";

  try {
    const response = await fetch(`https://${resourceName}/${eventName}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(data),
    });
    return await response.json();
  } catch (error) {
    console.error(`NUI Callback Error: ${eventName}`, error);
    return null;
  }
}
```

- `eventName` must exactly match the string in `RegisterNUICallback('eventName', ...)` on the Lua side
- Falls back to `'your_resource_name'` when not running inside a resource (dev mode)
- Returns parsed JSON response or `null` on error

**Example — trigger Lua `closeUi` callback:**

```js
await postNUI("closeUi");
```

#### `triggerServerAction(action, payload)` — Fire-and-Forget to Server

```js
export async function triggerServerAction(action, payload = {}) {
  return await postNUI("ServerRouter", {
    action: action,
    data: payload,
  });
}
```

Wraps `postNUI` targeting `ServerRouter`. On the Lua side, this triggers the corresponding `EventLogic[action]` function on the server.

```js
// Example usage:
await triggerServerAction("savePlayerData", { name: "John", level: 5 });
```

#### `requestServerData(action, payload)` — Callback with Response

```js
export async function requestServerData(action, payload = {}) {
  const result = await postNUI("ServerCallbackRouter", {
    action: action,
    data: payload,
  });
  return result;
}
```

Wraps `postNUI` targeting `ServerCallbackRouter`. Waits for server to respond via `lib.callback` and returns the data.

```js
// Example usage:
const inventory = await requestServerData("getInventory", { playerId: 1 });
console.log(inventory.items);
```

---

### Vuetify Setup

**File:** `frontend/src/plugins/vuetify.ts`

#### Theme

The resource defines a single custom theme named `"your_theme"`:

```ts
const your_theme = {
  dark: false,
  colors: {
    background: "#000",
    surface: "#000",
    secondBackground: "#0c0c10",
    "text-primary": "#000",
    "surface-bright": "#FFFFFF",
    "surface-light": "#DAE5E0",
    "surface-variant": "#4A635A",
    "on-surface-variant": "#EEEEEE",
    primary: "#58C9D4",
    "primary-darken-1": "#3DA8B3",
    secondary: "#a00c30",
    "on-secondary": "#ffffff",
    "secondary-darken-1": "#85B850",
    error: "#FF5252",
    info: "#2196F3",
    success: "#4CAF50",
    warning: "#FB8C00",
    "my-grey": "#4c4c4c",
  },
  // ... variables for opacity, border, etc.
};
```

The theme name `"your_theme"` is referenced in `App.vue`:

```vue
<v-app theme="your_theme">
```

**To rename the theme**, change the const name, the `themes` key in `createVuetify`, and the `theme=` attribute in `App.vue` — all three must match.

**To add a new theme color:**

```ts
colors: {
  // ... existing colors ...
  "my-new-color": "#FF6B6B",
}
```

Then use in templates: `color="my-new-color"` or `class="bg-my-new-color"`.

#### Icons Configuration

```ts
icons: {
  defaultSet: "mdi",
  aliases: {
    ...aliases,        // Vuetify built-in aliases ($close, $next, etc.)
    ...customIcons,    // custom aliases from myIcons.ts
  },
  sets: { mdi },
}
```

Icons use SVG paths from `@mdi/js` — not the full icon font CSS. This keeps bundle size small.

---

### Icons System

**File:** `frontend/src/plugins/myIcons.ts`

```ts
import { mdiDeleteForever, mdiMapMarker } from "@mdi/js";

export const customIcons: Record<string, string> = {
  marker: mdiMapMarker, // use as icon="$marker"
  trashcan: mdiDeleteForever, // use as icon="$trashcan"
};
```

**To add a new icon:**

1. Find icon name at `pictogrammers.com/library/mdi/`
2. Import from `@mdi/js`: `import { mdiNewIconName } from "@mdi/js"`
3. Add to `customIcons`: `myAlias: mdiNewIconName`
4. Use in templates: `<v-icon icon="$myAlias" />`

**Built-in Vuetify aliases already available:** `$close`, `$next`, `$info`, `$upload`, `$loading`, `$ratingFull`, etc.

---

### Styles System

**File:** `frontend/src/styles/settings.scss`

```scss
// Currently empty — used for Vuetify SASS variable overrides
// Uncomment to use:
// @use 'vuetify/settings' with (
//   $color-pack: false
// );
```

This file is loaded by `vite.config.mts` as Vuetify's style config file:

```ts
Vuetify({
  styles: { configFile: "src/styles/settings.scss" },
});
```

**To override Vuetify SASS variables:**

```scss
@use "vuetify/settings" with (
  $border-radius-root: 8px,
  $color-pack: false
);
```

Global non-Vuetify styles are defined in `App.vue`'s `<style>` block (scrollbar suppression, html/body sizing).

---

### Auto-Import System

The project uses `unplugin-auto-import` configured in `vite.config.mts`:

```ts
AutoImport({
  imports: [
    "vue", // ref, computed, onMounted, etc. — no import needed
    VueRouterAutoImports, // useRouter, useRoute — no import needed
    { pinia: ["defineStore", "storeToRefs"] },
  ],
});
```

This means in `.vue` files and stores you **do not need to import**:

- `ref`, `computed`, `watch`, `onMounted`, `onUnmounted`
- `useRouter`, `useRoute`
- `defineStore`, `storeToRefs`

These are globally available. Only component-specific imports (stores, utils, other components) need explicit `import` statements.

---

## 9. Data Flow Architecture

### Complete Message Flow: UI → Server → UI

> Note: This flow assumes Bug 1 (JsonPrint) and Bug 2 (src/source) have been fixed. Without fixes, the server crashes on every successful event dispatch.

```
[User clicks button in Vue component]
         ↓
[Component calls triggerServerAction('myAction', { key: 'value' })]
  -- NOT postNUI with 'event:' field (Bug 3 pattern) --
         ↓
[nui.js: postNUI('ServerRouter', { action: 'myAction', data: { key: 'value' } })]
         ↓
[HTTP POST to https://{resourceName}/ServerRouter]
         ↓
[client/serverRouter.lua: RegisterNUICallback('ServerRouter', ...)]
         ↓
[Extracts data.action = 'myAction', data.data = { key: 'value' }]
[TriggerServerEvent('{resourceName}:serverRouter', 'myAction', { key: 'value' })]
[Returns cb({ success = true }) to frontend immediately]
         ↓
[server/nuiRouter.lua: AddEventHandler('{resourceName}:serverRouter', ...)]
[Validates key, checks allowlist, finds EventLogic['myAction']]
  -- EventLogic table, NOT RegisterNetEvent (Bug 4 pattern) --
         ↓
[EventLogic['myAction'](src, data) executes]
[Server does work, sends response to client:]
[UserNotification("Done!", "success", 4000, source)]
         ↓
[client/snackbar.lua: AddEventHandler('{resourceName}:SendUserMessage', ...)]
[Receives message, action="success", time=4000]
[SendNUIMessage({ action = 'UserMessage', data = { text="Done!", color="success", timeout=4000 } })]
         ↓
[App.vue: window.addEventListener("message", ...) fires]
[handlers['UserMessage'] called → snackbar.showSnackbar(itemData.data)]
         ↓
[snackbar.js: maps color→imagePath, delegates to useNotify().show()]
         ↓
[useNotify: pushes notification object into normalQueue (or multi/fullscreen)]
         ↓
[Snackbar.vue: transition-group renders NormalNotification card, auto-removes after Time ms]
```

### Complete Flow: UI Requests Data FROM Server

```
[Component calls requestServerData('getInventory', { slot: 1 })]
         ↓
[nui.js: postNUI('ServerCallbackRouter', { action: 'getInventory', data: { slot: 1 } })]
         ↓
[HTTP POST to https://{resourceName}/ServerCallbackRouter]
         ↓
[client/serverRouter.lua: RegisterNUICallback('ServerCallbackRouter', ...)]
[lib.callback.await('{resourceName}:serverCallbackRouter', false, 'getInventory', data)]
         ↓ (BLOCKS until server responds)
[server/nuiRouter.lua: lib.callback.register('{resourceName}:serverCallbackRouter', ...)]
[CallbackLogic['getInventory'](source, data) executes]
[returns { success = true, items = [...] }]
         ↓
[lib.callback.await returns { success = true, items = [...] }]
[cb(result) returns JSON to frontend]
         ↓
[requestServerData returns { success: true, items: [...] }]
[Component uses result to update UI state]
```

---

## 10. Notification System Flow

### Server → Player → UI

```
-- Server Lua:
UserNotification("You found gold!", "success", 5000, source)
         ↓
-- shared/userNotification.lua:
TriggerClientEvent('{resourceName}:SendUserMessage', source, "You found gold!", "success", 5000)
         ↓
-- client/snackbar.lua:
AddEventHandler('{resourceName}:SendUserMessage', function(message, action, time)
    SendNUIMessage({ action = 'UserMessage', data = { text=message, color=action, timeout=time } })
end)
         ↓
-- App.vue window message listener:
handlers['UserMessage'](itemData)  -- itemData.data = { text, color, timeout }
→ snackbar.showSnackbar(itemData.data)
         ↓
-- snackbar.js:
queue.push({ text: "You found gold!", color: "success", timeout: 5000 })
processQueue() → current = queue.shift(), show = true
         ↓
-- Snackbar.vue:
<v-snackbar v-model="store.show"> renders at top center
```

### Client → UI (local notification without server roundtrip)

```lua
-- client Lua:
UserNotification("Action done!", "info", 3000)
-- → TriggerEvent('{resourceName}:SendUserMessage', "Action done!", "info", 3000)
-- Same path from client/snackbar.lua onwards
```

---

## 11. Debug System Flow

### Where Logs Appear

- **Client `DebugPrint/Print/WarnPrint`** → appears in the **F8 client console** in-game
- **Server `DebugPrint/Print/WarnPrint`** → appears in the **server terminal/console**

### Output Format

```
[resourceName] @resourceName/path/file.lua:LINE (functionName) YOUR MESSAGE
```

Example:

```
[my_resource] @my_resource/server/server.lua:12 (EventLogic[myEventName]) Player 5 triggered action
```

### Debug vs. Always-On

```lua
DebugPrint("Only when Config.Debug = true")  -- conditional
Print("Always prints")                        -- unconditional
WarnPrint("Always prints, in color")          -- unconditional
ErrorPrint("Always prints, in red")           -- unconditional, only in root debugSystem.lua
```

### nuiRouter.lua Debug Points

The router automatically debug-prints:

- `[Router] Executing Event: {key}` before calling EventLogic
- The `data` passed to the event via `JsonPrint(data)`
- `[Router] Returning callback data for: {key}` after CallbackLogic
- The `result` returned via `JsonPrint(result)`

---

## 12. Event Naming Conventions

### Lua Net Events (Client ↔ Server)

**Pattern:** `{resourceName}:{descriptiveName}`

| Event         | Direction     | Actual Name                      |
| ------------- | ------------- | -------------------------------- |
| Server Router | Client→Server | `{resourceName}:serverRouter`    |
| Snackbar      | Server→Client | `{resourceName}:SendUserMessage` |

All dynamic names use `GetCurrentResourceName()` or `tostring(GetCurrentResourceName())`.

```lua
-- Always construct names like this:
local eventName = tostring(GetCurrentResourceName()) .. ":myEvent"
```

### NUI Callback Names (Frontend → Lua Client)

**Pattern:** `PascalCase` or `camelCase` single word describing the action

| Callback               | Purpose                                                  |
| ---------------------- | -------------------------------------------------------- |
| `closeUi`              | Close the UI                                             |
| `ServerRouter`         | Route fire-and-forget events to server                   |
| `ServerCallbackRouter` | Route callback events to server                          |
| `setHeadder`           | Request a new random header (typo intentional in source) |

### Frontend `handlers` Keys / `action` Field Names

**Pattern:** `camelCase` action names in the `handlers` object in `App.vue`

| Action        | Triggered By              | Handler                             |
| ------------- | ------------------------- | ----------------------------------- |
| `openUi`      | Lua `SetDisplay()`        | Toggle visibility, route navigation |
| `UserMessage` | Lua `UserNotification()`  | Show snackbar                       |
| `setLang`     | Lua `sendLanguageToApp()` | Set lang store data                 |
| `setHeader`   | Lua `SendHeaderToApp()`   | Store header in global store        |

### Naming Templates

```lua
-- Lua events:
local MY_EVENT = GetCurrentResourceName() .. ":myDescriptiveEvent"

-- NUI Callbacks (must be globally unique within a resource):
RegisterNUICallback('myCallbackName', function(data, cb) ... end)

-- EventLogic keys:
EventLogic["myActionName"] = function(src, data) ... end

-- CallbackLogic keys:
CallbackLogic["myCallbackName"] = function(src, data) return {...} end
```

```js
// Frontend actions (must match Lua SendNUIMessage action field):
const handlers = {
  myActionName: (itemData) => { ... }
}

// NUI post targets (must match RegisterNUICallback name):
await postNUI('myCallbackName', data)
```

---

## 13. How To Implement Common Features

### Create New UI Page

**Step 1:** Create the Vue page file:

```
frontend/src/pages/inventory.vue
```

```vue
<template>
  <v-container>
    <h1>{{ lang.t("inventory_title") }}</h1>
    <!-- your content -->
  </v-container>
</template>

<script setup>
import { useLangStore } from "@/stores/langStore";
import { useGlobalStore } from "@/stores/useGlobalStore";

const lang = useLangStore();
const store = useGlobalStore();
</script>
```

The route `/inventory` is **automatically created** by `unplugin-vue-router`. No router config changes needed.

**Step 2:** Add route to `App.vue` `openUi` switch if you want Lua to open it directly:

```js
case "inventory":
  targetPath = '/inventory';
  break;
```

**Step 3:** Call from Lua to open on that view:

```lua
SetDisplay(true, "inventory")
-- Sends: SendNUIMessage { action = 'openUi', payload = { "inventory" } }
```

**Step 4:** The default layout wraps the page automatically — nothing else needed.

---

### Add New NUI Action (UI → Lua, no server needed)

**Step 1:** Add the Lua callback in `client/client.lua`:

```lua
RegisterNUICallback('myNewAction', function(data, cb)
    Print("Received myNewAction with: " .. json.encode(data))
    -- do something on client
    cb({ success = true, result = "done" })
end)
```

**Step 2:** Call from Vue using `postNUI`:

```js
import { postNUI } from "@/utils/nui";

const result = await postNUI("myNewAction", { myParam: "value" });
console.log(result); // { success: true, result: "done" }
```

---

### Add New Server Event (fire-and-forget from UI)

**Step 1:** Add to allowlist in `server/nuiRouter.lua`:

```lua
local AllowedFunctions = {
    ["myEventName"] = true,
    ["saveData"] = true,    -- new entry
}
```

**Step 2:** Add handler in `server/server.lua` using the `EventLogic` table (NOT `RegisterNetEvent`):

```lua
EventLogic["saveData"] = function(src, data)
    Print("saveData called by " .. tostring(src))
    -- always guard incoming data from clients
    if not data or not data.name or type(data.name) ~= "string" then
        UserNotification("Invalid name", "error", 4000, src)
        return
    end
    -- do server work
    UserNotification("Data saved!", "success", 3000, src)
end
```

**Step 3:** Call from Vue using `triggerServerAction` (not raw `postNUI` with `event:` field — that is Bug 3):

```js
import { triggerServerAction } from "@/utils/nui";

await triggerServerAction("saveData", { name: "John" });
// Returns { success: true } immediately (fire-and-forget from the client perspective)
```

---

### Add New Server Callback (UI requests data from server)

**Step 1:** Add to allowlist:

```lua
local AllowedFunctions = {
    ["getPlayerStats"] = true,
}
```

**Step 2:** Add handler returning data:

```lua
CallbackLogic["getPlayerStats"] = function(src, data)
    -- fetch data
    local stats = {
        health = GetEntityHealth(GetPlayerPed(src)),
        money = 500
    }
    return { success = true, stats = stats }
end
```

**Step 3:** Call from Vue and use result:

```js
import { requestServerData } from "@/utils/nui";

const response = await requestServerData("getPlayerStats");
if (response?.success) {
  console.log(response.stats.health);
}
```

---

### Show Notification

**From Server Lua:**

```lua
UserNotification("Operation successful!", "success", 4000, source)
UserNotification("Something failed!", "error", 5000, source)
UserNotification("Notice this", "info", 3000, source)
UserNotification("Be careful", "warning", 4000, source)
```

**From Client Lua:**

```lua
UserNotification("Client message", "info", 3000)
-- No source argument = fires on the local client
```

**From Vue (no Lua roundtrip):**

```js
import { useSnackbarStore } from "@/stores/snackbar";
const snackbar = useSnackbarStore();

snackbar.success("Saved!");
snackbar.error("Failed!", 5000);
snackbar.info("FYI", 3000);
snackbar.warning("Watch out");
snackbar.showSnackbar({ text: "Custom", color: "secondary", timeout: 2000 });
```

---

### Add Translation

**Step 1:** Add key to `lang/en.lua`:

```lua
L = {
    -- existing...
    inventory_title = "Player Inventory",
    inventory_empty = "Your inventory is empty.",
    inventory_item_count = "You have %s items.",
}
```

**Step 2:** Add same key to `lang/de.lua`:

```lua
DE = {
    -- existing...
    inventory_title = "Spieler-Inventar",
    inventory_empty = "Dein Inventar ist leer.",
    inventory_item_count = "Du hast %s Gegenstände.",
}
```

**Step 3 — Use in Lua:**

```lua
local title = T("inventory_title")
local msg = string.format(T("inventory_item_count"), 5)
```

**Step 4 — Use in Vue (after `sendLanguageToApp()` has been called):**

```js
lang.t("inventory_title"); // "Player Inventory"
lang.t("inventory_item_count", itemCount); // "You have 5 items."
lang.t("inventory_empty");
```

The translation becomes available in Vue as soon as the UI is opened (because `sendLanguageToApp()` is called in the `openview` command handler).

---

### Add New Store

**Step 1:** Create `frontend/src/stores/myStore.js`:

```js
import { defineStore } from "pinia";

export const useMyStore = defineStore("myStore", {
  state: () => ({
    items: [],
    loading: false,
  }),

  getters: {
    itemCount: (state) => state.items.length,
  },

  actions: {
    setItems(newItems) {
      this.items = newItems;
    },
    addItem(item) {
      this.items.push(item);
    },
    clear() {
      this.items = [];
    },
  },
});
```

**Step 2:** No registration needed — Pinia auto-discovers stores when first imported.

**Step 3:** Import and use in any component:

```js
import { useMyStore } from "@/stores/myStore";
const myStore = useMyStore();
myStore.setItems([{ name: "Bread" }]);
```

**Step 4 (optional):** To populate from Lua, add a handler in `App.vue`:

```js
const handlers = {
  // ...
  setInventoryItems: (itemData) => {
    myStore.setItems(itemData.data);
  },
};
```

Then from Lua:

```lua
SendNUIMessage({ action = "setInventoryItems", data = items })
```

---

### Add New Snackbar Message

**From Vue component directly:**

```js
snackbar.success("Item purchased!");
snackbar.error("Insufficient funds!");
```

**From Lua server (recommended for server feedback):**

```lua
UserNotification("Transaction complete!", "success", 4000, source)
```

**Custom snackbar with theme color:**

```js
snackbar.showSnackbar({
  text: "Special event triggered!",
  color: "secondary", // uses theme's secondary color (#a00c30)
  timeout: 6000,
});
```

---

### Send Data From UI To Server (Step-by-Step)

**Scenario:** User clicks "Buy Item" button in Vue; server validates and charges.

**Step 1 — Vue Component Button:**

```vue
<v-btn @click="buyItem('bread', 1)">Buy Bread</v-btn>
```

**Step 2 — Vue Component Script:**

```js
import { requestServerData } from "@/utils/nui";
import { useSnackbarStore } from "@/stores/snackbar";
const snackbar = useSnackbarStore();

const buyItem = async (itemName, quantity) => {
  const result = await requestServerData("buyItem", {
    item: itemName,
    qty: quantity,
  });
  if (result?.success) {
    snackbar.success(`Bought ${quantity}x ${itemName}!`);
  } else {
    snackbar.error(result?.error || "Purchase failed");
  }
};
```

**Step 3 — Server allowlist:**

```lua
local AllowedFunctions = {
    ["buyItem"] = true,
}
```

**Step 4 — Server logic:**

```lua
CallbackLogic["buyItem"] = function(src, data)
    if not data.item or not data.qty then
        return { success = false, error = "Invalid data" }
    end

    local playerMoney = 500 -- fetch real money
    local cost = 10 * data.qty

    if playerMoney < cost then
        return { success = false, error = "Not enough money" }
    end

    -- deduct money, add item to inventory...

    return { success = true }
end
```

---

## 14. Developer Workflow Guide

### Typical Development Workflow

#### 1. Start Development Server

```bash
cd frontend
npm run dev
```

Opens at `http://localhost:3000` with hot-reload. Note: NUI callbacks won't work outside the game, but UI layout can be developed freely. The `window.GetParentResourceName` fallback in `nui.js` returns `'your_resource_name'` so fetch calls won't crash.

#### 2. Add UI Feature

1. Create/modify Vue page in `pages/` or component in `components/`
2. Add new store state if needed
3. Add `handlers` entry in `App.vue` if Lua will push data to this view
4. Use `lang.t('key')` for all user-visible strings

#### 3. Add Translation Keys

1. Add to `lang/en.lua`
2. Add to `lang/de.lua`
3. Test with both `Config.Language = "en"` and `Config.Language = "de"`

#### 4. Add NUI → Server Action

1. Add action to `AllowedFunctions` in `server/nuiRouter.lua`
2. Add `EventLogic["action"]` or `CallbackLogic["action"]` in `server/server.lua`
3. Call from Vue with `triggerServerAction()` or `requestServerData()`

#### 5. Build for Production

```bash
cd frontend
npm run build
```

Output goes to `frontend/dist/`. This is what the resource serves via `ui_page`.

#### 6. Test In-Game

1. Start resource: `start your_resource_name`
2. Type in console: `openview`
3. Test all interactions
4. Check F8 (client) and server console for debug output

---

## 15. AI-Specific Usage Rules

### Where to Add New Files

| Purpose                | Location                     |
| ---------------------- | ---------------------------- |
| New Vue page           | `frontend/src/pages/`        |
| New Vue component      | `frontend/src/components/`   |
| New Pinia store        | `frontend/src/stores/`       |
| New client Lua feature | `client/` (new .lua file)    |
| New server Lua feature | `server/` (new .lua file)    |
| New shared utility     | `shared/` or `shared/utils/` |
| New language           | `lang/{code}.lua`            |
| New config values      | `shared/specific_config.lua` |

### Files That Must NOT Be Modified

| File                                | Reason                                                                                                |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `initconfig.lua`                    | Must only contain `Config = {}` and `Config.Debug`. All other config in `shared/specific_config.lua`. |
| `frontend/src/stores/index.ts`      | Just creates Pinia instance; no changes needed.                                                       |
| `frontend/src/plugins/index.ts`     | Plugin registration; only modify to add new plugins.                                                  |
| `frontend/src/router/index.ts`      | Routes are auto-generated; do not manually add routes here.                                           |
| `shared/utils/debugSystem.lua`      | Debug utilities; extend don't replace.                                                                |
| `shared/utils/userNotification.lua` | Notification system; extend don't replace.                                                            |
| `shared/utils/translation.lua`      | Translation resolver; extend don't replace.                                                           |

### Naming Rules to Follow

1. **Lua events:** Always `{GetCurrentResourceName()}:{descriptiveName}` — never hardcoded resource names in production code.
2. **NUI callback names:** Must exactly match between `RegisterNUICallback('name', ...)` and `postNUI('name', ...)`.
3. **`handlers` keys in App.vue:** Must exactly match the `action` field in `SendNUIMessage({ action = "name" })`.
4. **EventLogic/CallbackLogic keys:** Must exactly match `AllowedFunctions` entries and the `action` field sent from the frontend.
5. **Vue page files:** Use snake_case or lowercase for filenames in `pages/` — they become the URL path.
6. **Store files:** Use camelCase. Export store as `useStoreName` (convention: `use` prefix + PascalCase name + `Store` suffix).
7. **Translation keys:** snake_case, descriptive, grouped by feature prefix (e.g., `inventory_title`, `inventory_empty`).

### How to Extend Existing Systems

**Extend notifications:** Just call `UserNotification()` from any Lua context — no changes to the system needed.

**Extend translations:** Add keys to both `lang/en.lua` and `lang/de.lua`. They're automatically sent to the frontend.

**Extend the router (server):** Add entries to `AllowedFunctions` and add functions to `EventLogic` or `CallbackLogic` tables. Do not touch the router dispatch logic itself.

**Extend App.vue handlers:** Add new entries to the `handlers` object. Do not modify `handleMessageListener` itself.

**Extend the snackbar:** Use `snackbar.showSnackbar()` directly. Do not modify `Snackbar.vue` unless changing the UI appearance.

### How to Avoid Breaking Structure

1. **Never register NUI callbacks in `serverRouter.lua`** for application logic — that file only handles the two routers. Add application callbacks in `client/client.lua` or a new client file.

2. **Never call `TriggerServerEvent` directly from application client code** — always go through `TriggerServerEvent(resourceName .. ":serverRouter", action, data)` or use the NUI router pattern to keep security centralized.

3. **Never skip the allowlist** for production features — `USE_ALLOWED_FUNCTIONS = true` is a security requirement. Add every new action to `AllowedFunctions`.

4. **Never put server secrets in shared scripts** — `Config.Language`, `Config.myHeaders` are safe in shared. Discord webhooks, database credentials, API keys must be in server-only scripts.

5. **Never modify the `<v-app theme="your_theme">` theme attribute in `App.vue`** without also updating the theme name in `vuetify.ts`.

6. **Always use `lang.t('key')` in Vue components** — never hardcode user-visible strings.

7. **Always use `T('key')` in Lua** — never hardcode user-visible strings in Lua either.

8. **The Snackbar component must remain outside `v-show="isVisible"`** in `App.vue` — if you move it inside, notifications sent after UI close won't display.

9. **Do not use `createWebHistory()`** in the router — NUI is served as a local file and requires hash history.

10. **After adding new client/server Lua files**, add them to `fxmanifest.lua` in the correct section (`client_scripts` or `server_scripts`).

11. **Do not use `RegisterNetEvent`/`AddEventHandler` for server logic triggered by the UI** — use `EventLogic["actionName"] = function(src, data) ... end` (Bug 4 in the boilerplate demonstrates this mistake).

12. **Do not use raw `postNUI` with an `event:` field to trigger the ServerRouter** — use `triggerServerAction('actionName', data)` instead. The ServerRouter checks `data.action`, not `data.event` (Bug 3 in the boilerplate demonstrates this mistake).

13. **Do not call `SetDisplay` with a hardcoded boolean without tracking state.** Always use `SetDisplay(not display)` or compare against the current `display` value first. Calling `SetDisplay(true)` when the UI is already showing will toggle it closed (Bug: isVisible toggle behavior).

14. **Fix `JsonPrint` before going to production.** Add the function to `shared/debugSystem.lua` or replace the two calls in `nuiRouter.lua` with `DebugPrint(json.encode(...))`. Without this fix, every successful server event dispatch and callback will crash (Bug 1).

15. **Fix the `src`/`source` typo in `nuiRouter.lua` line 83** before using `USE_ALLOWED_FUNCTIONS = true` in a real resource. Blocking an unauthorized callback will crash the callback router (Bug 2).

16. **`WarnPrint` and `ErrorPrint` accept only one string** — always pass a single concatenated string, never multiple arguments (Bug 5).

17. **Always call `sendLanguageToApp()` before `SetDisplay(true)`** — otherwise the UI opens with all translation keys showing as their own names.

---

## 16. Full End-To-End Example

### Feature: "Add Inventory Panel"

This example implements a full inventory panel where the player can view their items and drop an item.

---

#### Step 1 — Translation Keys

**`lang/en.lua`** — add to the `L = { ... }` table:

```lua
inventory_title = "My Inventory",
inventory_empty = "Your inventory is empty.",
inventory_drop_btn = "Drop",
inventory_drop_success = "Item dropped successfully!",
inventory_drop_error = "Could not drop item.",
inventory_fetch_error = "Failed to load inventory.",
```

**`lang/de.lua`** — add to the `DE = { ... }` table:

```lua
inventory_title = "Mein Inventar",
inventory_empty = "Dein Inventar ist leer.",
inventory_drop_btn = "Wegwerfen",
inventory_drop_success = "Gegenstand erfolgreich weggeworfen!",
inventory_drop_error = "Konnte Gegenstand nicht wegwerfen.",
inventory_fetch_error = "Inventar konnte nicht geladen werden.",
```

---

#### Step 2 — Pinia Store

**`frontend/src/stores/inventoryStore.js`**:

```js
import { defineStore } from "pinia";

export const useInventoryStore = defineStore("inventory", {
  state: () => ({
    items: [],
    loading: false,
    error: null,
  }),

  getters: {
    isEmpty: (state) => state.items.length === 0,
    itemCount: (state) => state.items.length,
  },

  actions: {
    setItems(items) {
      this.items = items || [];
    },
    removeItem(itemId) {
      this.items = this.items.filter((i) => i.id !== itemId);
    },
    setLoading(val) {
      this.loading = val;
    },
    setError(msg) {
      this.error = msg;
    },
    clear() {
      this.items = [];
      this.loading = false;
      this.error = null;
    },
  },
});
```

---

#### Step 3 — Vue Page

**`frontend/src/pages/inventory.vue`**:

```vue
<template>
  <v-container class="fill-height" max-width="800">
    <div class="w-100">
      <h1 class="text-h4 mb-4 text-primary">{{ lang.t("inventory_title") }}</h1>

      <v-progress-circular
        v-if="inventory.loading"
        indeterminate
        color="primary"
      />

      <v-alert v-else-if="inventory.isEmpty" type="info">
        {{ lang.t("inventory_empty") }}
      </v-alert>

      <v-row v-else>
        <v-col v-for="item in inventory.items" :key="item.id" cols="6" md="4">
          <v-card color="surface-variant" rounded="lg" class="pa-3">
            <v-card-title>{{ item.name }}</v-card-title>
            <v-card-subtitle>x{{ item.count }}</v-card-subtitle>
            <v-card-actions>
              <v-btn
                color="error"
                variant="tonal"
                size="small"
                @click="dropItem(item.id)"
              >
                {{ lang.t("inventory_drop_btn") }}
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </div>
  </v-container>
</template>

<script setup>
import { useLangStore } from "@/stores/langStore";
import { useInventoryStore } from "@/stores/inventoryStore";
import { useSnackbarStore } from "@/stores/snackbar";
import { requestServerData, triggerServerAction } from "@/utils/nui";

const lang = useLangStore();
const inventory = useInventoryStore();
const snackbar = useSnackbarStore();

// Load inventory when the page mounts
onMounted(async () => {
  inventory.setLoading(true);
  const result = await requestServerData("getInventory");
  inventory.setLoading(false);

  if (result?.success) {
    inventory.setItems(result.items);
  } else {
    snackbar.error(lang.t("inventory_fetch_error"));
  }
});

const dropItem = async (itemId) => {
  const result = await requestServerData("dropItem", { itemId });
  if (result?.success) {
    inventory.removeItem(itemId);
    snackbar.success(lang.t("inventory_drop_success"));
  } else {
    snackbar.error(lang.t("inventory_drop_error"));
  }
};
</script>
```

The route `/inventory` is auto-created. No router changes needed.

---

#### Step 4 — App.vue: Add Route Case

In `App.vue`, add to the `openUi` switch:

```js
case "inventory":
  targetPath = '/inventory';
  break;
```

---

#### Step 5 — Server Allowlist

In `server/nuiRouter.lua`, add to `AllowedFunctions`:

```lua
local AllowedFunctions = {
    ["myEventName"] = true,
    ["myCallbackName"] = true,
    ["getInventory"] = true,    -- new
    ["dropItem"] = true,        -- new
}
```

---

#### Step 6 — Server Logic

In `server/server.lua`, add:

```lua
-- Mock inventory data (replace with real database calls)
local playerInventories = {}

CallbackLogic["getInventory"] = function(src, data)
    DebugPrint("[Inventory] getInventory called by " .. tostring(src))

    -- Fetch player's inventory (replace with actual data source)
    local items = playerInventories[src] or {
        { id = 1, name = "Water Canteen", count = 3 },
        { id = 2, name = "Dried Beef",    count = 10 },
        { id = 3, name = "Revolver",      count = 1 },
    }

    return { success = true, items = items }
end

CallbackLogic["dropItem"] = function(src, data)
    DebugPrint("[Inventory] dropItem called by " .. tostring(src))

    if not data or not data.itemId then
        WarnPrint("[Inventory] dropItem: missing itemId from " .. tostring(src))
        return { success = false, error = "Invalid data" }
    end

    -- Remove item from player inventory (replace with actual logic)
    local itemId = tonumber(data.itemId)
    if not itemId then
        return { success = false, error = "Invalid item ID" }
    end

    -- Perform drop logic here...
    Print("[Inventory] Player " .. tostring(src) .. " dropped item " .. tostring(itemId))

    return { success = true }
end
```

---

#### Step 7 — Open Inventory from Lua

In `client/client.lua`, optionally add a command or keybind:

```lua
RegisterCommand("inventory", function()
    sendLanguageToApp()
    SetDisplay(true, "inventory")
end, false)
```

Or trigger from server event:

```lua
-- From server, tell client to open inventory:
TriggerClientEvent(GetCurrentResourceName() .. ":openInventory", source)
```

```lua
-- In client.lua:
RegisterNetEvent(GetCurrentResourceName() .. ":openInventory")
AddEventHandler(GetCurrentResourceName() .. ":openInventory", function()
    sendLanguageToApp()
    SetDisplay(true, "inventory")
end)
```

---

#### Step 8 — Register fxmanifest Entries

No new files need to be added to the manifest since `server/server.lua` already handles the logic. But if you created a new server file (e.g., `server/inventory.lua`), add it:

```lua
server_scripts {
    '@ox_lib/init.lua',
    'server/nuiRouter.lua',  -- must load first (declares EventLogic, CallbackLogic globals)
    'server/server.lua',
    'server/inventory.lua',  -- any file after nuiRouter.lua can use EventLogic/CallbackLogic
}
```

#### Step 9 — Fix the Boilerplate Bugs Before Testing

Before this feature can work end-to-end, apply these fixes to the boilerplate:

**Fix Bug 1 (JsonPrint undefined):** Add to `shared/debugSystem.lua`:

```lua
function JsonPrint(data)
    DebugPrint(json.encode(data))
end
```

**Fix Bug 2 (src vs source):** In `server/nuiRouter.lua` line 83, change `GetPlayerName(src)` to `GetPlayerName(source)`.

Without these two fixes, the inventory feature will crash on the server side.

---

#### Complete Inventory Feature Data Flow

```
Player opens game → types /inventory
→ client.lua: sendLanguageToApp() + SetDisplay(true, "inventory")
→ Lua sends: SendNUIMessage({ action="setLang", lang="en", table=L })
→ Lua sends: SendNUIMessage({ action="openUi", payload={"inventory"} })
→ App.vue handlers["setLang"] → lang.setLangData(...)
→ App.vue handlers["openUi"] → router.push('/inventory'), isVisible=true
→ pages/inventory.vue mounts
→ onMounted: requestServerData('getInventory')
→ postNUI('ServerCallbackRouter', { action:'getInventory', data:{} })
→ HTTP POST → client serverRouter.lua → lib.callback.await
→ server nuiRouter.lua → CallbackLogic["getInventory"](src, {})
→ returns { success:true, items:[...] }
→ lib.callback returns → cb(result) → fetch response
→ inventory.setItems(result.items)
→ Vue renders item cards

Player clicks "Drop" on item with id=2
→ dropItem(2) called
→ requestServerData('dropItem', { itemId: 2 })
→ HTTP POST → server → CallbackLogic["dropItem"](src, { itemId: 2 })
→ returns { success: true }
→ inventory.removeItem(2) → item disappears from UI
→ snackbar.success("Item dropped successfully!")
→ Snackbar.vue shows green pill notification at top center
→ After 4000ms, snackbar auto-closes
```

---

_This documentation was generated from actual source code inspection. All code examples reflect real patterns found in the repository._
