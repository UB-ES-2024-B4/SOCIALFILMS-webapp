<script setup lang="ts">
import "primeicons/primeicons.css";

const toast = useToast();
const supabase = useSupabaseClient();
const user = useSupabaseUser();
const visibleDialogProfileSettings = ref(false);

const menu = ref();
const toggle = (event) => {
  menu.value.toggle(event);
};

const items = ref([
  {
    label: "Perfil",
    items: [
      {
        label: "Configuració",
        icon: "pi pi-cog",
        command: () => { visibleDialogProfileSettings.value = true },
      },
      {
        label: "Missatges",
        icon: "pi pi-inbox",
      },
      {
        label: "Tancar sessió",
        icon: "pi pi-sign-out",
        command: async () => {
          try {
            const { error } = await supabase.auth.signOut();
            if (error) throw error;
            toast.add({
              severity: "success",
              summary: "Sessió tancada",
              detail: "S'ha tancat la sessió amb exit",
              life: 3000,
            });
          } catch (error) {
            toast.add({
              severity: "error",
              summary: "Sessió no tancada",
              detail: "No s'ha tancat la sessió amb exit",
              life: 3000,
            });
          }
        },
      },
    ],
  },
]);
</script>

<template>
  <div
    class="flex items-center justify-center gap-2 bg-neutral-400/40 p-2 rounded-full shadow-sm w-max"
  >
    <img
      src="https://a.storyblok.com/f/191576/1200x800/a3640fdc4c/profile_picture_maker_before.webp"
      alt="Profile"
      class="w-10 h-10 rounded-full object-cover"
    />
    <div class="text-left">
      <p class="text-white text-sm font-semibold">Arfi Maulana</p>
      <p class="text-gray-300 text-xs">@arfimaulana_</p>
    </div>
    <Button
      icon="pi pi-chevron-down"
      variant="text"
      severity="secondary"
      rounded
      @click="toggle"
      :pt="{
        icon: { class: 'text-white' },
      }"
    />
    <Menu ref="menu" id="overlay_menu" :model="items" :popup="true" />

    <Dialog v-model:visible="visibleDialogProfileSettings" modal header="Profile Settings" :style="{ width: '50rem' }" :draggable="false">
      <template #container>
        <div class="h-32 bg-violet-200 dark:bg-violet-500/10 rounded-t-xl"></div>
        <div class="flex justify-between items-start mx-10">
          <div class="-translate-y-14 flex flex-col">
            <img
              src="https://primefaces.org/cdn/primevue/images/avatar/amyelsner.png"
              alt="Profile"
              class="w-28 h-28 rounded-full border-4 border-white shadow-md object-cover mb-5"
            />
            <h1 class="font-bold text-2xl">Profile Username</h1>
            <h2 class="text-gray-400 text-lg">profile@gmail.com</h2>
          </div>

          <div class="flex justify-center items-center gap-4 mt-4">
            <Button label="Compartir perfil" variant="outlined" icon="pi pi-share-alt" severity="contrast" />
            <Button label="Ver perfil" variant="outlined" severity="contrast" />
          </div>
        </div>

        <div class="-translate-y-10 flex flex-col mx-10">
          <Divider />
          <div class="flex items-start justify-between my-1">
            <h2 class="font-semibold">Nombre de usuario</h2>
            <IconField>
              <InputIcon class="pi pi-at" />
              <InputText class="w-[27rem]" v-model="value1" placeholder="Nombre de usuario" />
            </IconField>
          </div>
          <Divider />
          <div class="flex items-start justify-between my-1">
            <h2 class="font-semibold">Correo electrónico</h2>
            <IconField>
              <InputIcon class="pi pi-envelope" />
              <InputText class="w-[27rem]" v-model="value1" placeholder="Correo electrónico" />
            </IconField>
          </div>
          <Divider />
          <div class="flex items-start justify-between my-1">
            <h2 class="font-semibold">Contraseña</h2>
            <div class="flex items-center gap-4 w-[27rem]">
              <FloatLabel variant="on">
                <Password fluid id="current_password" v-model="value1" :feedback="false" toggleMask />
                <label for="current_password">Contraseña actual</label>
              </FloatLabel>
              <FloatLabel variant="on">
                <Password fluid id="new_password"v-model="value1" :feedback="false" toggleMask />
                <label for="new_password">Nueva contraseña</label>
              </FloatLabel>
            </div>
          </div>
          <Divider />
          <div class="flex items-start justify-between my-1">
            <h2 class="font-semibold">Foto de perfil</h2>
            <div class="flex justify-center items-center gap-4 mt-4">
              <Button label="Cambiar foto" severity="info" />
              <Button label="Eliminar foto" variant="outlined" severity="danger" />
            </div>
          </div>
        </div>



          
      </template>
    </Dialog>
  </div>
</template>
