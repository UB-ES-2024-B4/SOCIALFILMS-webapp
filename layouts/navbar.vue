<script setup lang="ts">
import "primeicons/primeicons.css";
import UserProfileButton from "~/components/UserProfileButton.vue";
import DialogProfileSettings from "~/components/DialogProfileSettings.vue";
import NotificationCard from "~/components/NotificationCard.vue";

const route = useRoute();
const supabase = useSupabaseClient();
const user = useSupabaseUser();
const searchQuery = ref("");
const notifications = ref();
const seeNotifications = (event) => {
  notifications.value.toggle(event);
}

const handleSubmitSearch = () => {
  if (searchQuery.value.trim()) {
    const formattedQuery = searchQuery.value.trim().replace(/\s+/g, "-");
    navigateTo(`/search/${encodeURIComponent(formattedQuery)}`);
  }
};

const menuItems = ref([
  {
    label: "Home",
    icon: "pi pi-home",
    path: "/",
  },
  {
    label: "Movies",
    icon: "pi pi-video",
    path: "/movies",
  },
]);

const isActive = (path: string) =>
  computed(() => {
    if (path === "/") {
      return route.path === "/";
    }
    return route.path.startsWith(path);
  });

const isNavbarVisible = ref(true);
let lastScrollPosition = 0;

const handleScroll = () => {
  const currentScrollPosition = window.scrollY;
  if (currentScrollPosition > lastScrollPosition) {
    isNavbarVisible.value = false;
  } else {
    isNavbarVisible.value = true;
  }
  lastScrollPosition = currentScrollPosition;
};

onMounted(() => {
  window.addEventListener("scroll", handleScroll);
});

onUnmounted(() => {
  window.removeEventListener("scroll", handleScroll);
});
</script>

<template>
  <div>
    <div
      class="fixed inset-y-4 inset-x-6 max-w-full h-[4.5rem] flex items-center justify-between rounded-full backdrop-blur bg-neutral-600/70 z-50 transition-transform duration-500"
      :class="{ '-translate-y-[125%]': !isNavbarVisible }"
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
            'flex items-center gap-2 font-medium py-3 px-6 rounded-full mr-2 shadow-sm',
            isActive(item.path).value
              ? 'bg-neutral-400/40 text-white font-semibold'
              : 'text-gray-100 hover:bg-neutral-400/40',
          ]"
        >
          <i :class="item.icon"></i>
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
          <Button icon="pi pi-bell" severity="secondary" rounded @click="seeNotifications" />
        </OverlayBadge>
        <Popover ref="notifications" class="no-padding-popover">
          <div class="flex flex-col w-[32rem] h-[calc(100vh-150px)] py-3">
            <div class="flex items-center justify-between pl-6 pr-5">
              <span class="text-xl font-semibold">Notificacions</span>
              <Button label="Marca tot com a llegit" icon="pi pi" severity="info" variant="text">
                <template #icon>
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="size-6">
                    <path d="M1.5 12.5L5.57574 16.5757C5.81005 16.8101 6.18995 16.8101 6.42426 16.5757L9 14" stroke-width="1.5" stroke-linecap="round"/>
                    <path d="M16 7L12 11" stroke-width="1.5" stroke-linecap="round"/>
                    <path d="M7 12L11.5757 16.5757C11.8101 16.8101 12.1899 16.8101 12.4243 16.5757L22 7" stroke-width="1.5" stroke-linecap="round"/>
                  </svg>
                </template>
              </Button>
            </div>
            <div class="border-[1.3px] border-zinc-300/85 mt-1 shadow"></div>
            <ScrollPanel style="width: 100%; height: calc(100% - 40px);">
              <div class="flex flex-col gap-2 pt-2 px-2">
                <NotificationCard sender="sergiomarinn" receiver="teitol"></NotificationCard>
                <NotificationCard sender="sergiomarinn" receiver="teitol"></NotificationCard>
              </div>
            </ScrollPanel>
          </div>
        </Popover>
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

<style>
.no-padding-popover .p-popover-content {
  --p-popover-content-padding: 0;
}
</style>