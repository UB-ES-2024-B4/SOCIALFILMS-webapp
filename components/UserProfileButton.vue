<script setup lang="ts">
import "primeicons/primeicons.css";

const toast = useToast();
const supabase = useSupabaseClient();
const user = useSupabaseUser();

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
    <!-- <Avatar label="A" size="normal" shape="circle" /> -->
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
  </div>
</template>
