import { defineStore } from 'pinia'

export const useToastStore = defineStore('toast', {
  state: () => ({ message: null, type: 'success' }),
  actions: {
    show(message, type = 'success') {
      this.message = message
      this.type = type
      setTimeout(() => (this.message = null), 3500)
    },
  },
})
