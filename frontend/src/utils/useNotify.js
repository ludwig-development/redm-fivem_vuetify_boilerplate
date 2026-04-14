import { useGlobalStore } from '@/stores/useGlobalStore'
import warningImg from '@/assets/warning.png'
import successImg from '@/assets/success.png'
import infoImg from '@/assets/info.png'
import errorImg from '@/assets/error.png'

const imageMap = {
    warning: warningImg,
    success: successImg,
    info: infoImg,
    error: errorImg,
}

const normalQueue = ref([])
const multiQueue = ref([])
const fullscreenActive = ref(null)

let notificationIdCounter = 0

export function useNotify() {
    const store = useGlobalStore();

    const getImageUrl = (item) => {
        if (!item) return null
        const basePath = store.getValue('itemImagePath') || ''

        if (!basePath) {
            console.warn('[useNotify] itemImagePath is not set in store — item images will not resolve. Send it via setConfig from the client.')
            return null
        }

        const itemName = typeof item === 'string'
            ? item
            : (item.item || (item.raw ? item.raw.item : 'unknown'))

        return `${basePath}${itemName}.png`
    }

    const show = (payload) => {
        if (!payload || typeof payload !== 'object') return

        let resolvedImage = null
        const incomingImage = payload.imagePath

        if (incomingImage) {
            if (imageMap[incomingImage]) {
                resolvedImage = imageMap[incomingImage]
            } else {
                resolvedImage = getImageUrl(incomingImage) || null
            }
        }

        const notification = {
            id: ++notificationIdCounter,
            Title: payload.title || payload.Title || 'Notification',
            Text: payload.message || payload.Text || '',
            Time: typeof (payload.time || payload.Time) === 'number' ? (payload.time || payload.Time) : 4000,
            Image: resolvedImage,
            Type: ['normal', 'multi', 'fullscreen'].includes(payload.type || payload.Type)
                ? (payload.type || payload.Type)
                : 'normal',
        }

        switch (notification.Type) {
            case 'normal':
                if (normalQueue.value.length >= 5) normalQueue.value.shift()
                normalQueue.value.push(notification)
                scheduleRemoval(notification.id, 'normal', notification.Time)
                break

            case 'multi':
                if (multiQueue.value.length >= 3) multiQueue.value.shift()
                multiQueue.value.push(notification)
                scheduleRemoval(notification.id, 'multi', notification.Time)
                break

            case 'fullscreen':
                fullscreenActive.value = notification
                scheduleRemoval(notification.id, 'fullscreen', notification.Time)
                break
        }
    }

    const remove = (id, type) => {
        if (type === 'normal') {
            normalQueue.value = normalQueue.value.filter(n => n.id !== id)
        } else if (type === 'multi') {
            multiQueue.value = multiQueue.value.filter(n => n.id !== id)
        } else if (type === 'fullscreen') {
            if (fullscreenActive.value?.id === id) fullscreenActive.value = null
        }
    }

    const scheduleRemoval = (id, type, time) => {
        setTimeout(() => {
            remove(id, type)
        }, time)
    }

    return {
        show,
        remove,
        normalQueue,
        multiQueue,
        fullscreenActive
    }
}
