<template>
    <div class="notification-layer">

        <transition name="fade">
            <FullscreenNotification v-if="fullscreenActive" :notification="fullscreenActive" />
        </transition>

        <div class="multi-container">
            <transition-group name="slide-down">
                <MultiNotification v-for="n in multiQueue" :key="n.id" :notification="n" />
            </transition-group>
        </div>

        <div class="normal-container">
            <transition-group name="slide-left">
                <NormalNotification v-for="n in normalQueue" :key="n.id" :notification="n" />
            </transition-group>
        </div>

    </div>
</template>

<script setup>
import { useNotify } from '@/utils/useNotify'
import NormalNotification from '@/components/notifications/NormalNotification.vue'
import MultiNotification from '@/components/notifications/MultiNotification.vue'
import FullscreenNotification from '@/components/notifications/FullscreenNotification.vue'

const { normalQueue, multiQueue, fullscreenActive } = useNotify()
</script>

<style scoped>
.notification-layer {
    position: fixed;
    inset: 0;
    pointer-events: none;
    z-index: 9990;
}

.normal-container {
    position: absolute;
    top: 20px;
    right: 20px;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
}

.multi-container {
    position: absolute;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    flex-direction: column;
    align-items: center;
}

/* Animations */
.slide-left-enter-active,
.slide-left-leave-active,
.slide-down-enter-active,
.slide-down-leave-active {
    transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
}

.slide-left-enter-from,
.slide-left-leave-to {
    opacity: 0;
    transform: translateX(100px);
}

.slide-down-enter-from,
.slide-down-leave-to {
    opacity: 0;
    transform: translateY(-50px);
}

.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.4s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

.slide-left-leave-active,
.slide-down-leave-active {
    position: absolute;
}
</style>
