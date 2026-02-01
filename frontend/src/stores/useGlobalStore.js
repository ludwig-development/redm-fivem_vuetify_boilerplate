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

  return { data, setValue, getValue }
})

