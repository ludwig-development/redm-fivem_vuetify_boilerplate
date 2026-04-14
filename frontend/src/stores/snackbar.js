import { defineStore } from 'pinia';
import { useNotify } from '@/utils/useNotify';

const colorToImage = {
    success: 'success',
    error: 'error',
    warning: 'warning',
    info: 'info',
};

const colorToTitle = {
    success: 'Success',
    error: 'Error',
    warning: 'Warning',
    info: 'Info',
};

export const useSnackbarStore = defineStore('snackbar', {
    actions: {
        showSnackbar(payload) {
            const { show } = useNotify();

            if (typeof payload === 'string') {
                show({ title: 'Info', message: payload, time: 4000, imagePath: 'info', type: 'normal' });
                return;
            }

            const color = payload.color || 'success';
            show({
                title: payload.title || payload.Title || colorToTitle[color] || 'Notification',
                message: payload.text || payload.message || payload.Text || '',
                time: payload.timeout || payload.time || payload.Time || 4000,
                imagePath: payload.imagePath || colorToImage[color] || 'info',
                type: payload.type || payload.Type || 'normal',
            });
        },

        success(message, timeout = 4000) {
            this.showSnackbar({ text: message, color: 'success', timeout });
        },

        error(message, timeout = 5000) {
            this.showSnackbar({ text: message, color: 'error', timeout });
        },

        warning(message, timeout = 4000) {
            this.showSnackbar({ text: message, color: 'warning', timeout });
        },

        info(message, timeout = 4000) {
            this.showSnackbar({ text: message, color: 'info', timeout });
        }
    }
});
