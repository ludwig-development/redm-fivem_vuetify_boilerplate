import { defineStore } from 'pinia'

const LOCALE_MAP = {
    de: 'de-DE',
    en: 'en-US',
    fr: 'fr-FR',
    es: 'es-ES',
    it: 'it-IT',
    pt: 'pt-PT'
}

export const useLangStore = defineStore('lang', {
    state: () => ({
        lang: 'en',
        locale: 'en-US',
        table: {}
    }),

    getters: {
        t: (state) => (key, ...args) => {
            let text = state.table[key] ?? key

            let i = 0
            text = text.replace(/%[sd]/g, () => {
                const value = args[i++]
                return value !== undefined ? value : ''
            })

            return text
        }
    },

    actions: {
        setLang(lang) {
            this.lang = lang
            this.locale = LOCALE_MAP[lang] || `${lang}-${lang.toUpperCase()}`
        },

        setTable(table) {
            this.table = table || {}
        },

        setLangData({ lang, table }) {
            console.log("now setting langData");
            if (lang) this.setLang(lang)
            if (table) this.setTable(table)
        },

        clear() {
            this.table = {}
        }
    }
})
