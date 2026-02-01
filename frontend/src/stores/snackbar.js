import { defineStore } from 'pinia';

const snackbarColors = {
  success: 'success',
  error: 'error',
  info: 'info',
  warning: 'warning'
};

export const useSnackbarStore = defineStore('snackbar', {
  state: () => ({
    queue: [],   
    current: null,  
    show: false,  
    activeTimeout: null,
  }),

  getters: {
    text: (state) => state.current?.text || '',
    color: (state) => state.current?.color || 'success',
    timeout: (state) => state.current?.timeout || 4000,
  },

  actions: {
    showSnackbar(payload) {
      const message = typeof payload === 'string' 
        ? { text: payload, color: 'success', timeout: 4000 }
        : { ...payload, color: payload.color || 'success', timeout: payload.timeout || 4000 };

      this.queue.push(message);
      if (!this.show) this.processQueue();
    },

    processQueue() {
      if (this.queue.length === 0) return;

      this.current = this.queue.shift();
      this.show = true;

      if (this.activeTimeout) clearTimeout(this.activeTimeout);

      this.activeTimeout = setTimeout(() => {
        this.close();
      }, this.current.timeout);
    },

    close() {
      this.show = false;
      if (this.activeTimeout) clearTimeout(this.activeTimeout);
      
      setTimeout(() => {
        this.processQueue();
      }, 500); 
    },
  

    success(message, timeout = 4000) {
      this.showSnackbar({ text: message, color: snackbarColors.success, timeout });
    },
    
    error(message, timeout = 5000) {
      this.showSnackbar({ text: message, color: snackbarColors.error, timeout });
    },

    warning(message, timeout = 4000) {
      this.showSnackbar({ text: message, color: snackbarColors.warning, timeout });
    },

    info(message, timeout = 4000) {
      this.showSnackbar({ text: message, color: snackbarColors.info, timeout });
    }
  }
});