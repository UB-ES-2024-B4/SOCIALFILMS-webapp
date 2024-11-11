<script setup lang="ts">
import "primeicons/primeicons.css";
import { useToast } from "primevue/usetoast";

const toast = useToast();
const supabase = useSupabaseClient();

const searchQuery = ref("");

const items = ref([
  {
    label: "Home",
    icon: "pi pi-home",
  },
]);

const userOptions = [
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
];

const user = useSupabaseUser();

console.log(user);
</script>

<template>
  <div>
    <Menubar :model="items">
      <template #start>
        <div
          class="logo-container mx-20 bg-primary-50 rounded-full flex items-center justify-center h-16 w-16"
        >
          <span class="text-2xl font-bold text-primary-700">LOGO</span>
        </div>
      </template>
      <template #item="{ item, props, hasSubmenu, root }">
        <a v-ripple class="flex items-center" v-bind="props.action">
          <span>{{ item.label }}</span>
          <Badge
            v-if="item.badge"
            :class="{ 'ml-auto': !root, 'ml-2': root }"
            :value="item.badge"
          />
          <i
            v-if="hasSubmenu"
            :class="[
              'pi pi-angle-down ml-auto',
              { 'pi-angle-down': root, 'pi-angle-right': !root },
            ]"
          ></i>
        </a>
      </template>
      <template #end>
        <div class="flex items-center gap-4">
          <InputText placeholder="Search" type="text" class="w-32 sm:w-auto" />
          <Button
            v-if="!user"
            label="Login"
            icon="pi pi-user"
            @click="navigateTo('/login')"
          />
          <SplitButton
            v-if="user"
            icon="pi pi-user"
            label="Compte"
            :model="userOptions"
          ></SplitButton>
          <Avatar label="U" class="mr-2" size="large" shape="circle" />
        </div>
      </template>
    </Menubar>
    <slot />
  </div>
</template>
