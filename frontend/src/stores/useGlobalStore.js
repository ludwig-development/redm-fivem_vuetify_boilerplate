import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useGlobalStore = defineStore('global', () => {
  const data = ref({})

  function setValue(key, value) {
    data.value[key] = value
  }

  function getValue(key) {
    return data.value[key]
  }

  // Bulk-initialize from a config object — only whitelisted keys are accepted
  // so a misconfigured Lua table can't pollute the store with unexpected fields.
  const CONFIG_KEYS = ['itemImagePath']

  function setConfig(config) {
    if (!config || typeof config !== 'object') return
    for (const key of CONFIG_KEYS) {
      if (key in config) data.value[key] = config[key]
    }
  }

  return { data, setValue, getValue, setConfig }
})

