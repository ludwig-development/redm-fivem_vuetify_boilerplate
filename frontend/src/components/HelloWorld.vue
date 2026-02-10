<template>
  <v-container class="fill-height fill-width d-flex align-center bg-black" max-width="900">
    <div>
      <div class="d-flex flex-column align-center w-100">
        <v-img class="mb-4" height="150" width="150" src="@/assets/logo.webp" rounded="circle" cover />
      </div>

      <div class="mb-8 text-center">
        <div class="text-body-2 font-weight-light mb-n1">
          {{ lang.t('welcome', formattedDate, lang.locale) }}
          <!-- see how formattedDate is automaticly being joined just like "string.format" in lua -->
        </div>
        <h1 class="text-h2 my-0 font-weight-bold">{{ lang.t('boilerplate_title') }}</h1>
        <h1 class="text-h3 my-0" :class="store.getValue('header') ? 'text-primary' : 'text-white'">
          {{ store.getValue('header') || lang.t('no_event_header') }}
        </h1>
      </div>

      <v-row>
        <v-col cols="12">
          <v-card class="py-4" color="surface-variant"
            image="https://cdn.vuetifyjs.com/docs/images/one/create/feature.png" prepend-icon="$ratingFull" rounded="lg"
            variant="tonal">
            <template #image>
              <v-img position="top right" />
            </template>

            <template #title>
              <h2 class="text-h5 font-weight-bold">{{ lang.t('get_started') }}</h2>
            </template>

            <template #subtitle>
              <div class="text-subtitle-1">
                {{ lang.t('update_instruction') }} <v-kbd>{{ `
                  <HelloWorld />` }}
                </v-kbd>
                {{ lang.t('update_path') }}
              </div>
            </template>
          </v-card>
        </v-col>

        <v-col v-for="link in links" :key="link.title" cols="6">
          <v-card append-icon="$next" class="py-4" color="surface-variant" :prepend-icon="link.icon" rounded="lg"
            :text="lang.t(link.textKey)" :title="lang.t(link.titleKey)" variant="elevated" @click="link.action" />
        </v-col>

        <v-col cols="12">
          <v-alert v-if="store.getValue('status')" type="info" class="mb-4">
            {{ lang.t('current_status') }} {{ store.getValue('status') }}
          </v-alert>

          <v-text-field :label="lang.t('input_label')" v-model="tempInput" />

          <v-btn color="primary" @click="testGeneralStore">{{ lang.t('save_btn') }}</v-btn>
        </v-col>
      </v-row>
    </div>
  </v-container>
</template>

<script setup>
import { ref } from 'vue'; // Ensure ref is imported
import { useGlobalStore } from '@/stores/useGlobalStore'
import { useSnackbarStore } from '@/stores/snackbar';
import { useLangStore } from '@/stores/langStore';
import { postNUI } from '@/utils/nui';

const store = useGlobalStore()
const snackbar = useSnackbarStore();
const lang = useLangStore();

const tempInput = ref('');

const testSnackbar = function () {
  snackbar.info(lang.t('sb_info_msg'));
  snackbar.success(lang.t('sb_success_msg'), 8000);

  snackbar.showSnackbar({
    text: lang.t('sb_manual_msg'),
    color: "secondary",
    timeout: 2000
  });

  snackbar.warning(lang.t('sb_queue_1'));
  snackbar.error(lang.t('sb_queue_2'));
};

const testServerRouter = async () => {
  await postNUI('ServerRouter', {
    event: 'myRessourceName:myEventName',
    data: { data1: "Provided By Ludwig Development", data2: "your Testdate" }
  });
};

const changeTheTitle = async () => {
  await postNUI('setHeadder');
};

const testGeneralStore = () => {
  store.setValue('status', tempInput.value || lang.t('store_fallback'))
  store.setValue('lastUpdated', new Date().toLocaleTimeString())
  console.log(store.data)
}

const links = [
  {
    icon: '$info',
    textKey: 'link_sb_text',
    titleKey: 'link_sb_title',
    action: testSnackbar
  },
  {
    icon: '$marker',
    textKey: 'link_nui_text',
    titleKey: 'link_nui_title',
    action: testServerRouter
  },
  {
    icon: '$upload',
    textKey: 'link_store_text',
    titleKey: 'link_store_title',
    action: testGeneralStore
  },
  {
    icon: '$loading',
    textKey: 'link_event_text',
    titleKey: 'link_event_title',
    action: changeTheTitle
  }
]

const formattedDate = computed(() => {
  return new Intl.DateTimeFormat(lang.locale, {
    dateStyle: 'short',
    timeStyle: 'short'
  }).format(new Date())
})
</script>