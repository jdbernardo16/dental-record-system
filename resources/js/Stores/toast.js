import { defineStore } from 'pinia'

export const useToastStore = defineStore('toast', {
  state: () => ({ message: null, type: 'success' }),
  actions: {
    show(message, type = 'success') {
      clearTimeout(this._timer)
      this.message = message
      this.type = type
      this._timer = setTimeout(() => this.hide(), 3500)
    },
    hide() {
      clearTimeout(this._timer)
      this.message = null
    },
  },
})
