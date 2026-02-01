<template>
  <v-app theme="your_theme">
    <!--move the  v-show="isVisible" here if you dont want the snackbar to display AFTER the UI already closed -->
    <Snackbar />

    <router-view v-show="isVisible" />
  </v-app>
</template>

<script setup>
import Snackbar from './components/Snackbar.vue';
import { useGlobalStore } from '@/stores/useGlobalStore'
import { useRouter } from 'vue-router';
import { useSnackbarStore } from '@/stores/snackbar';


const router = useRouter();
const store = useGlobalStore()
const snackbar = useSnackbarStore();
const isVisible = ref(false);


const openUi = async (view = "") => {
  let targetPath = '/';

  switch (view) {
    case "yourView":
      targetPath = '/yourview'; // Replace with your actual route path, / = pages/index.vue  /about would be pages/about.vue or pages/about/index.vue
      break;
    default:
      targetPath = '/';
  }

  await router.push(targetPath);

  isVisible.value = !isVisible.value;
  console.log("UI Visibility is now:", isVisible.value);
};

const handlers = {
  openUi: (itemData) => {
    if (itemData.payload?.length > 0 && itemData.payload[0]) {
      openUi(itemData.payload[0]);
    } else {
      openUi();
    }
  },
  UserMessage: (itemData) => {
    if (itemData.data) {
      snackbar.showSnackbar(itemData.data);
    }
  },
  setHeader: (itemData) => {
    console.log("Now the Data was set: ", itemData.data)
    store.setValue("header", itemData.data)
  }
};

const handleMessageListener = (event) => {
  const itemData = event?.data;
  if (handlers[itemData.action]) handlers[itemData.action](itemData);
};

// close by Escape Key
const handleKeydown = (e) => {
  if (e.key === "Escape") {
    fetch(`https://${GetParentResourceName()}/closeUi`, {
      method: "POST",
    });
  }
};

onMounted(() => {
  window.addEventListener("message", handleMessageListener);
  window.addEventListener("keydown", handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener("message", handleMessageListener);
  window.removeEventListener("keydown", handleKeydown);
});

</script>

<style>
::-webkit-scrollbar {
  width: 0;
  display: inline !important;
}


html,
body {
  width: 100% !important;
  height: 100% !important;
  margin: 0 !important;
  padding: 0 !important;
  overflow: hidden !important;
}


.v-application,
.v-application--wrap {
  min-height: 100vh !important;
  overflow: hidden !important;
  background: rgb(0, 0, 0, 0) !important;
}
</style>
