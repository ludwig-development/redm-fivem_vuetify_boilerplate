<template>
  <v-container class="fill-height fill-width d-flex align-center bg-black" max-width="900">
    <div>
      <div class="d-flex flex-column align-center w-100">
        <v-img class="mb-4" height="150" width="150" src="@/assets/logo.webp" rounded="circle" cover />
      </div>

      <div class="mb-8 text-center">
        <div class="text-body-2 font-weight-light mb-n1">Welcome to</div>
        <h1 class="text-h2 my-0 font-weight-bold">Vuetify Boilerplate by Ludwig Development!</h1>
        <h1 class="text-h3 my-0" :class="store.getValue('header') ? 'text-primary' : 'text-white'">
          {{ store.getValue('header') || 'I haven\'t pressed the Event button yet!' }}
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
              <h2 class="text-h5 font-weight-bold">Get started</h2>
            </template>

            <template #subtitle>
              <div class="text-subtitle-1">
                Change this page by updating <v-kbd>{{ `
                  <HelloWorld />` }}
                </v-kbd>
                in <v-kbd>components/HelloWorld.vue</v-kbd>.
              </div>
            </template>
          </v-card>
        </v-col>

        <v-col v-for="link in links" :key="link.title" cols="6">
          <v-card append-icon="$next" class="py-4" color="surface-variant" :prepend-icon="link.icon" rounded="lg"
            :text="link.text" :title="link.title" variant="elevated" @click="link.action" />
        </v-col>

        <v-col cols="12">
          <v-alert v-if="store.getValue('status')" type="info" class="mb-4">
            Current Status: {{ store.getValue('status') }}
          </v-alert>

          <v-text-field label="Type something to store it dynamically" v-model="tempInput" />

          <v-btn color="primary" @click="testGeneralStore">Save to Store</v-btn>
        </v-col>
      </v-row>
    </div>
  </v-container>
</template>

<script setup>
import { useGlobalStore } from '@/stores/useGlobalStore'
import { useSnackbarStore } from '@/stores/snackbar';
import { postNUI } from '@/utils/nui';

const store = useGlobalStore()
const snackbar = useSnackbarStore();

const tempInput = ref('');

const testSnackbar = function () {
  snackbar.info("This is an info message");

  snackbar.success("This was successful!", 8000);

  snackbar.showSnackbar({
    text: "Manually triggered with custom config",
    color: "secondary", // Or any Vuetify color like "warning" or "red-darken-3" see colors at https://vuetifyjs.com/en/styles/colors/#material-colors
    timeout: 2000
  });

  snackbar.warning("Queue test 1");
  snackbar.error("Queue test 2");
};

const testServerRouter = async () => {
  await postNUI('ServerRouter', { event: 'myRessourceName:myEventName', data: { data1: "Provided By Ludwig Development", data2: "your Testdate" } });
};

const changeTheTitle = async () => {
  await postNUI('setHeadder');
  // Feedback from Post is now handled in a central function with handlers in the File App.vue !
};

const testGeneralStore = () => {
  store.setValue('status', tempInput.value || "Make an Input below and press again!")
  store.setValue('lastUpdated', new Date().toLocaleTimeString())

  console.log(store.data)
}

const links = [
  {
    icon: '$info', //these icon aliases are defined in plugins/myIcons.ts look there if you want to define new once
    text: 'Style your snackbar in components/snackbar.vue',
    title: 'Test Snackbar',
    action: testSnackbar
  },
  {
    icon: '$marker',
    text: 'Test the Serverrouter, view your Serverconsole for detailed information',
    title: 'NUI -> Serverrouter',
    action: testServerRouter
  },
  {
    icon: '$upload',
    text: 'See how the Globalstore stores your input below!',
    title: 'Global Storage',
    action: testGeneralStore
  },
  {
    icon: '$loading',
    text: 'Change the Header of the Script to see the Events in Action',
    title: 'Events in Action',
    action: changeTheTitle
  }
] 
</script>
