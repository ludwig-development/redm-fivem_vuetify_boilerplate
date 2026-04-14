<template>
    <v-card class="normal-notification mb-3" theme="dark" elevation="6">
        <div class="pa-3 d-flex align-center">
            <div v-if="notification.Image && !imageFailed" class="notification-icon mr-3">
                <img :src="notification.Image" alt="icon" @error="imageFailed = true" />
            </div>

            <div class="notification-content">
                <div class="text-subtitle-2 font-weight-bold">{{ notification.Title }}</div>
                <div class="text-body-2 text-grey-lighten-1">{{ notification.Text }}</div>
            </div>
        </div>

        <v-progress-linear :active="true" :color="progressBarColor" v-model="progress" height="4"
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
.normal-notification {
    width: 300px;
    pointer-events: auto;
    position: relative;
}

.notification-icon img {
    width: 32px;
    height: 32px;
    object-fit: contain;
    display: block;
}

.notification-content {
    flex: 1;
    min-width: 0;
}

.notification-progress :deep(.v-progress-linear__determinate) {
    transition: width v-bind('props.notification.Time + "ms"') linear !important;
}
</style>
