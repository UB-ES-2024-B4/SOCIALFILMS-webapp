<script setup lang="ts">
import "primeicons/primeicons.css";
import UserProfileButton from "~/components/UserProfileButton.vue";
import NotificationCard from "~/components/NotificationCard.vue";
import type { Notification, Notifications, Profile } from "~/types"; 

const route = useRoute();
const supabase = useSupabaseClient();
const user = useSupabaseUser();
const toast = useToast();
const searchQuery = ref("");
const notificationsPopover = ref();
const notifications = ref<Notifications>();

try {
  const { data, error } = (await supabase.rpc(
    "get_notifications"
  )) as { data: Notifications; error: any };

  if (error) throw error;

  notifications.value = data;

} catch (error) {
  if (error.code === 'F0001'){
    console.error("User doesn't have notifications");
  }
  else {
    console.error("Error loading notifications:", error);      
  }
}

const seeNotifications = async (event: Event) => {
  notificationsPopover.value.toggle(event);
};

const todayNotifications = computed(() => {
  if (notifications.value) {
    const today = new Date();
    return notifications.value.notifications
      .filter((notification) => {
        const notificationDate = new Date(notification.created_at);
        return (
          notificationDate.getDate() === today.getDate() &&
          notificationDate.getMonth() === today.getMonth() &&
          notificationDate.getFullYear() === today.getFullYear()
        );
      })
      .sort((a, b) => {
        const dateA = new Date(a.created_at);
        const dateB = new Date(b.created_at);
        return dateB.getTime() - dateA.getTime();
      });
  }
  return [];
});

const olderNotifications = computed(() => {
  if (notifications.value) {
    const today = new Date();
    return notifications.value.notifications
      .filter((notification) => {
        const notificationDate = new Date(notification.created_at);
        return (
          notificationDate.getDate() !== today.getDate() ||
          notificationDate.getMonth() !== today.getMonth() ||
          notificationDate.getFullYear() !== today.getFullYear()
        );
      })
      .sort((a, b) => {
        const dateA = new Date(a.created_at);
        const dateB = new Date(b.created_at);
        return dateB.getTime() - dateA.getTime();
      });
  }
  return [];
});

const notificationsRealtime = supabase
  .channel('notification-changes')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'notifications',
      filter: `receiver_id=eq.${user.value?.id}`,
    },
    (payload) => {
      const newNotification = payload.new as Notification;

      if (!notifications.value) {
        notifications.value = { notifications: [], unread_count: 0 };
      }

      notifications.value.notifications.push(newNotification);

      toast.add({
        severity: 'info',
        summary: `Nova notificació de ${newNotification.sender_username}`,
        detail: `${newNotification.sender_username} t'ha compartit una pel·lícula`,
        life: 5000,
      });
    }
  )
  .subscribe()

const setAllNotificationsAsRead = async () => {
  try {
    const { error } = (await supabase.rpc(
      "set_all_is_read",
      { _is_read: true }
    ))

    if (error) throw error;

    if (notifications.value) {
      notifications.value.notifications = notifications.value.notifications.map((notification) => ({
        ...notification,
        is_read: true,
      }));
    }

  } catch (error) {
    console.error("Error setting all notifications as read:", error);      
  }
};

const unreadCount = computed(() => {
  if (notifications.value?.notifications) {
    return notifications.value.notifications.filter((n) => !n.is_read).length;
  }
  return 0;
});

watch(
  () => unreadCount.value,
  (newCount) => {
    if (notifications.value) notifications.value.unread_count = newCount;
  }
);

const deleteNotification = async (notification: Notification) => {
  if (notifications.value) {
    notifications.value.notifications = notifications.value.notifications.filter(
      (n) => n.movie_id !== notification.movie_id || n.sender_id !== notification.sender_id
    );
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

const handleSubmitSearch = () => {
  if (searchQuery.value.trim() && typeOfSearch.value !== "Perfils") {
    const formattedQuery = searchQuery.value.trim().replace(/\s+/g, "-");
    navigateTo(`/search/${encodeURIComponent(formattedQuery)}`);
  }
};

const searchInput = ref<HTMLElement | null>(null);
const typeOfSearch = ref("Pel·lícules");
const menuSearch = ref();
const menuProfiles = ref();
const profiles = ref<Profile[]>([]);
const itemsSearch = ref([
  { label: 'Pel·lícules', command: () => { typeOfSearch.value = "Pel·lícules" } },
  { label: 'Perfils', command: () => { typeOfSearch.value = "Perfils" } }
]);
const toggleMenuSearch = (event: Event) => {
  menuSearch.value.toggle(event);
};

const isLoadingProfiles = ref(false);
const fetchProfiles = async (event: Event) => {
  if (typeOfSearch.value !== "Perfils" || !searchQuery.value.trim()) {
    profiles.value = [];
    return;
  }
  isLoadingProfiles.value = true;
  const { data, error } = await supabase.rpc("search_profiles", {
    _search_term: searchQuery.value,
  }) as { data: Profile[]; error: any }; ;

  if (error) {
    console.error("Error fetching profiles:", error.message);
    profiles.value = [];
  } else {
    console.log(data)
    profiles.value = data || [];
  }

  if (profiles.value.length > 0) {
    menuProfiles.value.show({ currentTarget: searchInput.value });
  } else {
    menuProfiles.value.hide();
  }
  isLoadingProfiles.value = false;
};

const filteredMenuItems = computed(() =>
  profiles.value.map((profile) => ({
    username: profile.username,
    real_name: profile.real_name || "Nom no disponible",
    last_name: profile.last_name || "",
    command: () => navigateTo(`/profile/${profile.username}`),
  }))
);

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
    notificationsPopover.value.hide()
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
      <div class="w-full flex items-center">
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
          <svg v-if="item.label ==='Pel·lícules'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-[1.3rem] h-[1.3rem]">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.375 19.5h17.25m-17.25 0a1.125 1.125 0 0 1-1.125-1.125M3.375 19.5h1.5C5.496 19.5 6 18.996 6 18.375m-3.75 0V5.625m0 12.75v-1.5c0-.621.504-1.125 1.125-1.125m18.375 2.625V5.625m0 12.75c0 .621-.504 1.125-1.125 1.125m1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125m0 3.75h-1.5A1.125 1.125 0 0 1 18 18.375M20.625 4.5H3.375m17.25 0c.621 0 1.125.504 1.125 1.125M20.625 4.5h-1.5C18.504 4.5 18 5.004 18 5.625m3.75 0v1.5c0 .621-.504 1.125-1.125 1.125M3.375 4.5c-.621 0-1.125.504-1.125 1.125M3.375 4.5h1.5C5.496 4.5 6 5.004 6 5.625m-3.75 0v1.5c0 .621.504 1.125 1.125 1.125m0 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125m1.5-3.75C5.496 8.25 6 7.746 6 7.125v-1.5M4.875 8.25C5.496 8.25 6 8.754 6 9.375v1.5m0-5.25v5.25m0-5.25C6 5.004 6.504 4.5 7.125 4.5h9.75c.621 0 1.125.504 1.125 1.125m1.125 2.625h1.5m-1.5 0A1.125 1.125 0 0 1 18 7.125v-1.5m1.125 2.625c-.621 0-1.125.504-1.125 1.125v1.5m2.625-2.625c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125M18 5.625v5.25M7.125 12h9.75m-9.75 0A1.125 1.125 0 0 1 6 10.875M7.125 12C6.504 12 6 12.504 6 13.125m0-2.25C6 11.496 5.496 12 4.875 12M18 10.875c0 .621-.504 1.125-1.125 1.125M18 10.875c0 .621.504 1.125 1.125 1.125m-2.25 0c.621 0 1.125.504 1.125 1.125m-12 5.25v-5.25m0 5.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125m-12 0v-1.5c0-.621-.504-1.125-1.125-1.125M18 18.375v-5.25m0 5.25v-1.5c0-.621.504-1.125 1.125-1.125M18 13.125v1.5c0 .621.504 1.125 1.125 1.125M18 13.125c0-.621.504-1.125 1.125-1.125M6 13.125v1.5c0 .621-.504 1.125-1.125 1.125M6 13.125C6 12.504 5.496 12 4.875 12m-1.5 0h1.5m-1.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125M19.125 12h1.5m0 0c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125m-17.25 0h1.5m14.25 0h1.5" />
          </svg>
          <i v-else :class="item.icon"></i>
          {{ item.label }}
        </button>
      </div>

      <div class="w-full flex items-center justify-end gap-4">
        <form @submit.prevent="handleSubmitSearch" class="relative lg:w-80 sm:w-72">
          <span
            class="absolute inset-y-0 left-4 flex items-center text-gray-200"
          >
            <i :class="isLoadingProfiles ? 'pi pi-spin pi-spinner' : 'pi pi-search'"></i>
          </span>
          <input
            ref="searchInput"
            v-model="searchQuery"
            type="text"
            placeholder="Cerca"
            :class="[ typeOfSearch === 'Perfils' ? 'pr-[7.5rem]' : 'pr-[9rem]',
              'w-full pl-12 py-2 rounded-full bg-neutral-400/40 text-white placeholder-gray-200 focus:outline-none focus:ring-1 focus:ring-neutral-400/80 transition-shadow duration-300'
            ]"
            @input="fetchProfiles"
          />
          <Menu ref="menuProfiles" id="overlay_profiles" :model="filteredMenuItems" :popup="true" class="w-60 max-h-96 overflow-y-auto">
            <template #item="{ item, props }">
              <button v-ripple class="relative overflow-hidden w-full border-0 bg-transparent flex items-center p-2 pl-4 hover:bg-surface-100 dark:hover:bg-surface-800 rounded-none cursor-pointer transition-colors duration-200">
                <Avatar
                  :label="item.username ? item.username[0] : 'T'"
                  class="mr-2.5 cursor-pointer"
                  size="large"
                  shape="circle"
                />
                <span class="inline-flex flex-col items-start">
                  <span class="font-semibold leading-tight">{{ item.username }}</span>
                  <span class="text-gray-500/80 dark:text-gray-400/80 leading-tight">{{ item.real_name + ' ' + item.last_name }}</span>
                </span>
              </button>
            </template>
          </Menu>
          <button
            type="button"
            class="absolute inset-y-0 right-12 flex items-center gap-1 text-[0.9rem] text-gray-200 hover:text-white"
            @click="toggleMenuSearch"
          >
            <i class="pi pi-angle-down mt-[1px] text-[0.9rem]"></i>
            {{ typeOfSearch }}
          </button>
          <Menu ref="menuSearch" id="overlay_menu_search" :model="itemsSearch" :popup="true" />
          <button
            v-tooltip.bottom="{
              value: 'Cerca avançada',
              showDelay: 200,
              hideDelay: 300,
            }"
            type="button"
            class="absolute inset-y-0 right-4 flex items-center text-gray-200 hover:text-white"
            @click="navigateTo('/search')"
          >
            <i class="pi pi-filter"></i>
          </button>
        </form>
        <OverlayBadge v-if="user && notifications?.unread_count !== 0 && notifications" :value="notifications?.unread_count" severity="danger" size="small">
          <Button icon="pi pi-bell" severity="secondary" rounded @click="seeNotifications" />
        </OverlayBadge>
        <Button v-else-if="user && (notifications?.unread_count === 0 || !notifications?.notifications)" icon="pi pi-bell" severity="secondary" rounded @click="seeNotifications" />
        <Popover ref="notificationsPopover" class="no-padding-popover">
          <div class="flex flex-col w-[33rem] h-[calc(100vh-150px)] py-3">
            <div class="flex items-center justify-between pl-6 pr-5 mb-1.5">
              <span class="text-xl font-semibold text-black dark:text-white">Notificacions</span>
              <Button label="Marca tot com a llegit" icon="pi pi" severity="info" variant="text" @click="setAllNotificationsAsRead">
                <template #icon>
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="size-6">
                    <path d="M1.5 12.5L5.57574 16.5757C5.81005 16.8101 6.18995 16.8101 6.42426 16.5757L9 14" stroke-width="1.5" stroke-linecap="round"/>
                    <path d="M16 7L12 11" stroke-width="1.5" stroke-linecap="round"/>
                    <path d="M7 12L11.5757 16.5757C11.8101 16.8101 12.1899 16.8101 12.4243 16.5757L22 7" stroke-width="1.5" stroke-linecap="round"/>
                  </svg>
                </template>
              </Button>
            </div>
            <ScrollPanel style="width: 100%; height: calc(100% - 40px);">
              <div v-if="todayNotifications.length" class="h-10 bg-[#F8F9FD] dark:bg-[#1B1D23] border-y-[1.5px] border-y-[#EBEDF1] dark:border-y-[#2E3037] pl-6 flex items-center text-lg text-zinc-900 dark:text-zinc-200 sticky top-0 z-10">
                Avui
              </div>
              <div class="flex flex-col gap-1 py-1 px-1">
                <NotificationCard
                  v-for="notification in todayNotifications"
                  :key="notification.movie_id"
                  :notification="notification"
                  @delete-notification="deleteNotification"
                ></NotificationCard>
              </div>

              <div v-if="olderNotifications.length" class="h-10 bg-[#F8F9FD] dark:bg-[#1B1D23] border-y-[1.5px] border-y-[#EBEDF1] dark:border-y-[#2E3037] pl-6 flex items-center text-lg text-zinc-900 dark:text-zinc-200 sticky top-0 z-10">
                Anteriors
              </div>
              <div class="flex flex-col gap-1.5 py-1 px-1">
                <NotificationCard
                  v-for="notification in olderNotifications"
                  :key="notification.movie_id"
                  :notification="notification"
                  @delete-notification="deleteNotification"
                ></NotificationCard>
              </div>
              <div v-if="!todayNotifications.length && !olderNotifications.length" class="text-center italic py-4 text-lg text-gray-500">
                No tens notificacions disponibles.
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