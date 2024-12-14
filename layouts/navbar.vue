<script setup lang="ts">
import "primeicons/primeicons.css";
import UserProfileButton from "~/components/UserProfileButton.vue";

const route = useRoute();
const supabase = useSupabaseClient();
const user = useSupabaseUser();
const searchQuery = ref("");

const handleSubmitSearch = () => {
  if (searchQuery.value.trim()) {
    const formattedQuery = searchQuery.value.trim().replace(/\s+/g, "-");
    navigateTo(`/search/${encodeURIComponent(formattedQuery)}`);
  }
};

const menuItems = ref([
  {
    label: "Inici",
    icon: "pi pi-home",
    path: "/",
  },
  {
    label: "Pel·lícules",
    icon: "pi pi-video",
    path: "/movies",
  },
  {
    label: "Perfil",
    icon: "pi pi-user",
    path: `/profile/${user.value?.user_metadata.username}`,
  },
]);

const isActive = (path: string) =>
  computed(() => {
    if (path === "/") {
      return route.path === "/";
    }
    return route.path.startsWith(path);
});

const SCROLL_THRESHOLD = 50;
const HIDE_THRESHOLD = 300;

const isNavbarVisible = ref(true);
const hasBackground = ref(false);
let lastScrollPosition = 0;

const handleScroll = () => {
  const currentScrollPosition = window.scrollY;
  hasBackground.value = currentScrollPosition > SCROLL_THRESHOLD;

  if (currentScrollPosition > HIDE_THRESHOLD) {
    isNavbarVisible.value = currentScrollPosition < lastScrollPosition;
  }
  
  lastScrollPosition = currentScrollPosition;
};

onMounted(() => {
  window.addEventListener("scroll", handleScroll);
});

onUnmounted(() => {
  window.removeEventListener("scroll", handleScroll);
});

watch(
  () => route.path,
  () => {
    hasBackground.value = false;
    isNavbarVisible.value = true;
  }
);

</script>

<template>
  <div>
    <div
      class="fixed inset-x-6 max-w-full h-[4.5rem] flex items-center justify-between rounded-full z-50 transition-transform duration-500"
      :class="[
        isNavbarVisible ? 'translate-y-0' : '-translate-y-[125%]',
        hasBackground ? 'backdrop-blur bg-neutral-600/70 inset-y-4' : 'bg-transparent inset-y-2',
      ]"
      :style="{
        transition: 'background-color 1s ease, inset 0.5s ease, transform 0.5s ease',
      }"
    >
      <div class="flex items-center">
        <img
          src="/logo.png"
          alt="SocialFilms Logo"
          class="h-12 w-auto ml-10 mr-10"
        />
        <button
          v-for="item in menuItems"
          :key="item.path"
          @click="navigateTo(item.path)"
          :class="[
            'flex items-center gap-2 font-medium py-3 px-6 rounded-full mr-2',
            isActive(item.path).value
              ? 'bg-neutral-400/40 text-white font-semibold'
              : 'text-gray-100 hover:bg-neutral-400/40',
          ]"
        > 
          <svg v-if="item.label ==='Movies'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-[1.3rem] h-[1.3rem]">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.375 19.5h17.25m-17.25 0a1.125 1.125 0 0 1-1.125-1.125M3.375 19.5h1.5C5.496 19.5 6 18.996 6 18.375m-3.75 0V5.625m0 12.75v-1.5c0-.621.504-1.125 1.125-1.125m18.375 2.625V5.625m0 12.75c0 .621-.504 1.125-1.125 1.125m1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125m0 3.75h-1.5A1.125 1.125 0 0 1 18 18.375M20.625 4.5H3.375m17.25 0c.621 0 1.125.504 1.125 1.125M20.625 4.5h-1.5C18.504 4.5 18 5.004 18 5.625m3.75 0v1.5c0 .621-.504 1.125-1.125 1.125M3.375 4.5c-.621 0-1.125.504-1.125 1.125M3.375 4.5h1.5C5.496 4.5 6 5.004 6 5.625m-3.75 0v1.5c0 .621.504 1.125 1.125 1.125m0 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125m1.5-3.75C5.496 8.25 6 7.746 6 7.125v-1.5M4.875 8.25C5.496 8.25 6 8.754 6 9.375v1.5m0-5.25v5.25m0-5.25C6 5.004 6.504 4.5 7.125 4.5h9.75c.621 0 1.125.504 1.125 1.125m1.125 2.625h1.5m-1.5 0A1.125 1.125 0 0 1 18 7.125v-1.5m1.125 2.625c-.621 0-1.125.504-1.125 1.125v1.5m2.625-2.625c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125M18 5.625v5.25M7.125 12h9.75m-9.75 0A1.125 1.125 0 0 1 6 10.875M7.125 12C6.504 12 6 12.504 6 13.125m0-2.25C6 11.496 5.496 12 4.875 12M18 10.875c0 .621-.504 1.125-1.125 1.125M18 10.875c0 .621.504 1.125 1.125 1.125m-2.25 0c.621 0 1.125.504 1.125 1.125m-12 5.25v-5.25m0 5.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125m-12 0v-1.5c0-.621-.504-1.125-1.125-1.125M18 18.375v-5.25m0 5.25v-1.5c0-.621.504-1.125 1.125-1.125M18 13.125v1.5c0 .621.504 1.125 1.125 1.125M18 13.125c0-.621.504-1.125 1.125-1.125M6 13.125v1.5c0 .621-.504 1.125-1.125 1.125M6 13.125C6 12.504 5.496 12 4.875 12m-1.5 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125M19.125 12h1.5m0 0c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125m-17.25 0h1.5m14.25 0h1.5" />
          </svg>

          <i v-else :class="item.icon"></i>
          {{ item.label }}
        </button>
      </div>

      <div class="flex items-center gap-4">
        <form @submit.prevent="handleSubmitSearch" class="relative max-w-xs">
          <span
            class="absolute inset-y-0 left-4 flex items-center text-gray-200"
          >
            <i class="pi pi-search"></i>
          </span>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Cerca pel·lícules"
            class="w-full pl-12 pr-4 py-2 rounded-full bg-neutral-400/40 text-white placeholder-gray-200 focus:outline-none focus:ring-1 focus:ring-neutral-400/80 transition-shadow duration-300"
          />
          <button
            v-tooltip.bottom="{
              value: 'Cerca avançada',
              showDelay: 800,
              hideDelay: 300,
            }"
            type="button"
            class="absolute inset-y-0 right-4 flex items-center text-gray-200 hover:text-white"
            @click="navigateTo('/search')"
          >
            <i class="pi pi-filter"></i>
          </button>
        </form>
        <OverlayBadge v-if="user" value="2" severity="danger" size="small">
          <Button icon="pi pi-bell" severity="secondary" rounded />
        </OverlayBadge>
        <UserProfileButton v-if="user" class="mr-2.5"></UserProfileButton>
        <div v-else class="flex gap-2 mr-4">
          <Button
            as="router-link"
            label="Inicia sessió"
            severity="secondary"
            to="/login"
            rounded
          />
          <Button
            as="router-link"
            label="Crea un compte"
            severity="contrast"
            to="/signup"
            rounded
          />
        </div>
      </div>
    </div>
    <slot />
  </div>
</template>
