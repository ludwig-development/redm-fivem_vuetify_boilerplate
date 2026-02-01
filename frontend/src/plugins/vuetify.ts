/**
 * plugins/vuetify.ts
 *
 * Framework documentation: https://vuetifyjs.com`
 */

// Styles
// import '@mdi/font/css/materialdesignicons.css' // only add if you really want all mdi icons, esle use my icons.ts for certain icons you want to use.
import "vuetify/styles";
import { aliases, mdi } from "vuetify/iconsets/mdi-svg";

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
  variables: {
    "border-color": "#FFFFFF",
    "border-opacity": 0.15,
    "high-emphasis-opacity": 0.95,
    "medium-emphasis-opacity": 0.7,
    "disabled-opacity": 0.4,
    "idle-opacity": 0.05,
    "hover-opacity": 0.08,
    "focus-opacity": 0.15,
    "selected-opacity": 0.12,
    "activated-opacity": 0.15,
    "pressed-opacity": 0.18,
    "dragged-opacity": 0.1,

    "theme-kbd": "#162521",
    "theme-on-kbd": "#FFFFFF",
    "theme-code": "#1E312B",
    "theme-on-code": "#A0D468",
  },
};

// Composables
import { createVuetify } from "vuetify";
import { customIcons } from "./myIcons";

// https://vuetifyjs.com/en/introduction/why-vuetify/#feature-guides
export default createVuetify({
  theme: {
    defaultTheme: "your_theme",
    themes: {
      your_theme,
    },
  },
  icons: {
    defaultSet: "mdi",
    aliases: {
      ...aliases,
      ...customIcons,
    },
    sets: {
      mdi,
    },
  },
});
