<template>
  <v-container class="fill-height py-8 bg-gradient rounded-xl" width="60vw">
    <v-row class="w-100" justify="center">

      <!-- Hero -->
      <v-col cols="12" class="text-center mb-2">
        <v-avatar class="mb-5 avatar-ring" size="100">
          <v-img src="@/assets/ld_avatar_big.png" cover />
        </v-avatar>
        <p class="text-body-2 text-medium-emphasis mb-2">{{ strings.welcome }}</p>
        <h1 class="text-h3 font-weight-bold text-white">{{ strings.title }}</h1>
      </v-col>

      <!-- Server info  (myCallbackName) -->
      <v-col cols="12">
        <v-card class="server-card pa-5" rounded="xl" variant="outlined">
          <div class="d-flex align-center justify-space-between flex-wrap gap-3">
            <div class="d-flex align-center gap-4">
              <v-icon color="primary" size="32">$ratingFull</v-icon>
              <div>
                <div class="text-overline text-medium-emphasis lh-1 mb-1">{{ strings.serverTitle }}</div>
                <div class="text-h6 font-weight-bold">
                  <span v-if="serverFetching" class="text-medium-emphasis">{{ strings.serverFetching }}</span>
                  <span v-else-if="serverName" class="text-primary">{{ serverName }}</span>
                  <span v-else class="text-error">{{ strings.serverError }}</span>
                </div>
              </div>
            </div>
            <v-btn :loading="serverFetching" color="primary" prepend-icon="$next" rounded="lg" variant="tonal"
              @click="fetchServerName">{{ strings.serverRefresh }}</v-btn>
          </div>
        </v-card>
      </v-col>

      <!-- Live event header -->
      <v-col cols="12">
        <v-card class="pa-5" color="surface-variant" rounded="xl" variant="tonal">
          <div class="d-flex align-center justify-space-between flex-wrap gap-3">
            <div class="d-flex align-center gap-4">
              <v-icon size="28">$marker</v-icon>
              <div>
                <div class="text-overline text-medium-emphasis lh-1 mb-1">{{ strings.headerLabel }}</div>
                <div class="text-h6 font-weight-bold"
                  :class="store.getValue('header') ? 'text-primary' : 'text-medium-emphasis'">{{
                    store.getValue('header') || strings.noHeader }}</div>
              </div>
            </div>
            <v-btn color="secondary" prepend-icon="$upload" rounded="lg" variant="tonal" @click="changeTheTitle">{{
              strings.headerTrigger }}</v-btn>
          </div>
        </v-card>
      </v-col>

      <!-- Get started -->
      <v-col cols="12">
        <v-card image="https://cdn.vuetifyjs.com/docs/images/one/create/feature.png" prepend-icon="$ratingFull"
          rounded="xl">
          <template #image><v-img position="top right" /></template>
          <template #title>
            <h2 class="text-h6 font-weight-bold">{{ strings.gsTitle }}</h2>
          </template>
          <template #subtitle>
            {{ strings.gsInstruction }} <v-kbd>{{ `
              <HelloWorld />` }}
            </v-kbd> {{ strings.gsPath }}
          </template>
        </v-card>
      </v-col>

      <!-- Feature cards -->
      <v-col v-for="link in links" :key="link.title" cols="12" sm="6">
        <v-card append-icon="$next" class="feature-card" color="surface-variant" :prepend-icon="link.icon" rounded="xl"
          :text="link.text" :title="link.title" variant="elevated" @click="link.action" />
      </v-col>

      <!-- Global store -->
      <v-col cols="12">
        <v-card class="pa-6" color="surface-variant" rounded="xl" variant="tonal">
          <div class="d-flex align-center gap-2 mb-5">
            <v-icon>$loading</v-icon>
            <span class="text-h6 font-weight-bold">{{ strings.storeTitle }}</span>
          </div>
          <v-text-field v-model="tempInput" class="mb-4" hide-details="auto" :label="strings.storeInput" rounded="lg"
            variant="outlined" />
          <div class="d-flex align-center justify-space-between flex-wrap gap-3">
            <v-btn color="primary" prepend-icon="$info" rounded="lg" @click="saveToStore">
              {{ strings.storeSave }}
            </v-btn>
            <v-chip v-if="store.getValue('status')" color="info" prepend-icon="$info" size="large" variant="elevated">{{
              strings.storeStatus }} {{ store.getValue('status') }}</v-chip>
          </div>
        </v-card>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useGlobalStore } from '@/stores/useGlobalStore';
import { useSnackbarStore } from '@/stores/snackbar';
import { useLangStore } from '@/stores/langStore';
import { postNUI, triggerServerAction, requestServerData } from '@/utils/nui';

const store = useGlobalStore();
const snackbar = useSnackbarStore();
const lang = useLangStore();

const tempInput = ref('');
const serverName = ref('');
const serverFetching = ref(false);

const formattedDate = computed(() =>
  new Intl.DateTimeFormat(lang.locale, { dateStyle: 'short', timeStyle: 'short' }).format(new Date())
)

const strings = computed(() => {
  const T = (key, ...args) => lang.t(key, ...args)
  return {
    // hero
    welcome: T('ui.welcome', formattedDate.value, lang.locale),
    title: T('ui.boilerplate_title'),
    noHeader: T('ui.no_event_header'),
    // server callback card
    serverTitle: T('server.title'),
    serverFetching: T('server.fetching'),
    serverError: T('server.error'),
    serverRefresh: T('server.refresh_btn'),
    // event header card
    headerLabel: T('header.label'),
    headerTrigger: T('header.trigger_btn'),
    // get started card
    gsTitle: T('cards.get_started.title'),
    gsInstruction: T('cards.get_started.instruction'),
    gsPath: T('cards.get_started.path'),
    // store section
    storeTitle: T('store.section_title'),
    storeInput: T('store.input_label'),
    storeSave: T('store.save_btn'),
    storeStatus: T('store.current_status'),
    storeFallback: T('store.fallback'),
    // feature card labels
    lnkSbTitle: T('links.snackbar.title'),
    lnkSbText: T('links.snackbar.text'),
    lnkNuiTitle: T('links.nui.title'),
    lnkNuiText: T('links.nui.text'),
    lnkStoreTitle: T('links.store.title'),
    lnkStoreText: T('links.store.text'),
    lnkEvtTitle: T('links.events.title'),
    lnkEvtText: T('links.events.text'),
    // snackbar messages (consumed in script, not template)
    sbInfo: T('snackbar.info'),
    sbSuccess: T('snackbar.success'),
    sbQueue1: T('snackbar.queue_1'),
    sbQueue2: T('snackbar.queue_2'),
    sbMultiTitle: T('snackbar.multi.title'),
    sbMultiMsg: T('snackbar.multi.message'),
    sbFsTitle: T('snackbar.fullscreen.title'),
    sbFsMsg: T('snackbar.fullscreen.message'),
    image: T('snackbar.image'),
    appleImage: T('snackbar.appleImage'),
  }
})


const links = computed(() => [
  { icon: '$info', title: strings.value.lnkSbTitle, text: strings.value.lnkSbText, action: testSnackbar },
  { icon: '$marker', title: strings.value.lnkNuiTitle, text: strings.value.lnkNuiText, action: testServerRouter },
  { icon: '$upload', title: strings.value.lnkStoreTitle, text: strings.value.lnkStoreText, action: saveToStore },
  { icon: '$loading', title: strings.value.lnkEvtTitle, text: strings.value.lnkEvtText, action: changeTheTitle },
])

const delay = (ms) => new Promise(r => setTimeout(r, ms));

const fetchServerName = async () => {
  serverFetching.value = true;
  serverName.value = '';
  const result = await requestServerData('myCallbackName');
  serverName.value = typeof result === 'string' ? result : '';
  serverFetching.value = false;
};

const testSnackbar = async () => {
  const s = strings.value;
  snackbar.info(s.sbInfo, 3000); await delay(3500);
  snackbar.success(s.sbSuccess, 3000); await delay(3500);
  snackbar.warning(s.sbQueue1, 3000); await delay(3500);
  snackbar.error(s.sbQueue2, 3000); await delay(3500);
  snackbar.showSnackbar({ title: s.image, message: s.appleImage, imagePath: 'apple', time: 5000 });
  await delay(5500);
  snackbar.showSnackbar({ title: s.sbMultiTitle, message: s.sbMultiMsg, imagePath: 'info', time: 3000, type: 'multi' });
  await delay(3500);
  snackbar.showSnackbar({ title: s.sbFsTitle, message: s.sbFsMsg, imagePath: 'warning', time: 8000, type: 'fullscreen' });
};

const testServerRouter = async () => {
  await triggerServerAction('myEventName', { data1: 'Provided By Ludwig Development', data2: 'your Testdata' });
};

const changeTheTitle = async () => {
  await postNUI('setHeadder');
};

const saveToStore = () => {
  store.setValue('status', tempInput.value || strings.value.storeFallback);
  store.setValue('lastUpdated', new Date().toLocaleTimeString());
  console.log(store.data);
};

onMounted(fetchServerName);
</script>

<style scoped>
.bg-gradient {
  background: radial-gradient(circle at top left, #1a1c2c, #0d0e14);
}

.avatar-ring {
  border: 3px solid rgb(var(--v-theme-primary));
  box-shadow: 0 0 28px rgba(var(--v-theme-primary), 0.35);
}

.server-card {
  border-color: rgb(var(--v-theme-primary)) !important;
  background: rgba(var(--v-theme-primary), 0.05);
}

.feature-card {
  cursor: pointer;
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}

.feature-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 28px rgba(0, 0, 0, 0.35) !important;
}

.lh-1 {
  line-height: 1;
}
</style>
