<template>
    <v-card class="multi-notification mb-4 mx-auto" theme="dark" elevation="8">
        <div class="d-flex align-center pa-4">
            <img v-if="notification.Image && !imageFailed" :src="notification.Image" @error="imageFailed = true"
                class="multi-image mr-4" alt="Notification Icon" />
            <div>
                <div class="text-h6 font-weight-bold">{{ notification.Title }}</div>
                <div class="text-body-1 text-grey-lighten-1">{{ notification.Text }}</div>
            </div>
        </div>

        <v-progress-linear v-model="progress" :color="progressBarColor" height="4"
            class="notification-progress"></v-progress-linear>
    </v-card>
</template>

<script setup>
const props = defineProps({
    notification: { type: Object, required: true }
})

const imageFailed = ref(false)
const progress = ref(100)

const progressBarColor = computed(() => {
    const img = props.notification.Image?.toLowerCase() || '';
    if (img.includes('success')) return 'success';
    if (img.includes('info')) return 'info';
    if (img.includes('warning')) return 'warning';
    if (img.includes('error')) return 'error';
    return 'primary';
})

onMounted(() => {
    setTimeout(() => {
        progress.value = 0
    }, 50)
})
</script>

<style scoped>
.multi-notification {
    width: 450px;
    overflow: hidden;
    pointer-events: auto;
}

.multi-image {
    width: 48px;
    height: 48px;
    object-fit: contain;
}

.notification-progress :deep(.v-progress-linear__determinate) {
    transition: width v-bind('props.notification.Time + "ms"') linear !important;
}
</style>
