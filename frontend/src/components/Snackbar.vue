<!-- Docs for the Snackbar model: https://vuetifyjs.com/en/components/snackbars/#api -->
<template>
    <v-snackbar v-model="store.show" :color="store.color" :timeout="-1" location="top center" rounded="pill">
        {{ store.text }}

        <template v-slot:actions>
            <v-btn variant="plain" @click="store.close()" icon="$close" />
        </template>
    </v-snackbar>
</template>

<script setup>
import { useSnackbarStore } from '@/stores/snackbar';
const store = useSnackbarStore();

</script>
