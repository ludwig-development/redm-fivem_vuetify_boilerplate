<p align="center">
    <a href="https://github.com/ludwig-development/redm-fivem_vuetify_boilerplate">
        <img src="https://i.imgur.com/LcHft8q.jpeg" alt="REDM FIVEM VUETIFY BOILERPLATE BY LUDWIG"/>
    </a>
</p>

<h4 align="center">High-performance, aesthetically pleasing UI boilerplate for RedM resources. Built with Vue 3, Vuetify 3, and Pinia and a lot of experience.</h4>

<p align="center">
    <img alt="GitHub package.json version" src="https://img.shields.io/github/package-json/v/ludwig-development/redm-fivem_vuetify_boilerplate?filename=frontend%2Fpackage.json">
    <img alt="GitHub" src="https://img.shields.io/github/license/ludwig-development/redm-fivem_vuetify_boilerplate">
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/ludwig-development/redm-fivem_vuetify_boilerplate">
    <img alt="Maintenance" src="https://img.shields.io/maintenance/yes/2026">
</p>

<p align="center">
    <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/ludwig-development/redm-fivem_vuetify_boilerplate?style=social">
    <img alt="GitHub forks" src="https://img.shields.io/github/forks/ludwig-development/redm-fivem_vuetify_boilerplate?style=social">
    <a href="https://www.paypal.com/paypalme/LudwigRahm">
        <img src="https://img.shields.io/badge/Donate-PayPal-blue.svg?style=social&logo=paypal" alt="Donate with PayPal">
    </a>
</p>

<hr>

## Overview

**Vuetify RedM Boilerplate** by **Ludwig Development** bridges the gap between complex NUI interactions and beautiful, performant interfaces. Skip the setup hassle and dive straight into creating.

## 📦 Requirements

- **Node.js:** version 22 or higher on your development environment.

## ✨ Key Features

- **Modern UI Components:** Fully integrated **Vuetify 3** frontend framework.
- **Global State Management:** Powered by **Pinia** to keep your UI data synced across components.
- **Advanced Snackbar System:** \* Shorthand helpers (`info`, `success`, `error`).
  - Automatic message queueing & custom timeouts.
- **📡 NUI ↔ Server Bridge:** Built-in `postNUI` utility with a dedicated **ServerRouter** to handle events from UI to Client / Server-Lua effortlessly.

### 🛠 Advanced Printing System

Powered by [Roschy](https://github.com/JulianLegler), this system eliminates the guesswork in debugging.

- **Automatic Metadata:** Tracks **FileName**, **Line Number**, and **Function Name** automatically.
- **Functions:**
  - **Print:** Standard output with automated metadata.
  - **WarnPrint:** High-visibility red output with automated metadata.
  - **DebugPrint:** Output with metadata, active only if `Config.Debug == true`.

> **Example Output:**
> `[ludwig_crafting] @ludwig_crafting/server/recipes.lua:344 (getLearnedRecipes) Kein Rezept in RecipeServerCache für ID 344`

---

## 🛠 Getting Started

### 1. Installation

Clone the repository into your RedM resources folder by bash or just download the zip and extract it to your projectFolder.
Enter your folder in bash and run `npm install`

```bash
cd your-resource-name/frontend
npm install

```

### 2. Development

Run the Vite development server for hot-reloads (you still need to restart the resource):

```bash
npm run dev

```

### 3. Production

Build the project for use inside RedM:

```bash
npm run build

```

---

## 📖 Usage

Comprehensive examples for the NUI bridge and Printing system can be found within `HelloWorld.vue` and `Client.lua`.

## Feedback

Im always on the hunt for an even better startingpoint, if you have suggestions open a pullrequest or contact me via Discord !

## ☕ Support

If this boilerplate saved you time or helped your project, consider gifting me a coffee!
**[Donate via PayPal](https://www.paypal.com/paypalme/LudwigRahm)**

---

**Developed with ❤️ by [Ludwig Development](https://github.com/imLudwig) If you want to have a chat feel free to [join my Discord](https://discord.gg/sMM9FAcjCb)**

> **Acknowledgments:** A big thanks to [alenvalek](https://github.com/alenvalek/) for the [boilerplate](https://github.com/alenvalek/fivem-vuejs-boilerplate) that started my Journey with Vuetify and inspired me to build an Updated Version with builtin Vuetify and other Utils with Focus on performance.

---

# Showcase:

after building and starting the resource go ingame and execute the command "openview" now you see this menu and can test the functionalities of this Boilerplate:

<p align="center">
    <a href="https://github.com/ludwig-development/redm-fivem_vuetify_boilerplate">
        <img src="https://i.imgur.com/6cnwpHe.jpeg" alt="REDM FIVEM VUETIFY BOILERPLATE BY LUDWIG"/>
    </a>
</p>
