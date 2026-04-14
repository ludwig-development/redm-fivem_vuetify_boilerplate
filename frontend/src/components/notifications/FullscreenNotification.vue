<template>
    <v-overlay :model-value="true" class="align-center justify-center" z-index="9999" persistent>
        <div class="fullscreen-content text-center text-white pa-10">
            <img v-if="notification.Image && !imageFailed" :src="notification.Image" @error="imageFailed = true"
                class="fullscreen-image mb-6" alt="Fullscreen Alert Image" />

            <h1 class="text-h2 font-weight-black mb-4">{{ notification.Title }}</h1>
            <p class="text-h5 text-grey-lighten-2">{{ notification.Text }}</p>
        </div>
    </v-overlay>
</template>

<script setup>
const props = defineProps({
    notification: { type: Object, required: true }
})

const imageFailed = ref(false)
</script>

<style scoped>
.fullscreen-content {
    background: rgba(0, 0, 0, 0.85);
    border-radius: 16px;
    max-width: 80vw;
    animation: slightScale 0.4s ease-out forwards;
}

.fullscreen-image {
    max-width: 250px;
    max-height: 250px;
    object-fit: contain;
    filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.2));
}

@keyframes slightScale {
    0% {
        transform: scale(0.9);
        opacity: 0;
    }

    100% {
        transform: scale(1);
        opacity: 1;
    }
}
</style>
