<script setup lang="ts">
import "primeicons/primeicons.css";
import UserProfileButton from "~/components/UserProfileButton.vue";
import NotificationCard from "~/components/NotificationCard.vue";
import type { Notification, Notifications } from "~/types"; 

const route = useRoute();
const supabase = useSupabaseClient();
const user = useSupabaseUser();
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
    return notifications.value.notifications.filter((notification) => {
      const notificationDate = new Date(notification.created_at);
      return (
        notificationDate.getDate() === today.getDate() &&
        notificationDate.getMonth() === today.getMonth() &&
        notificationDate.getFullYear() === today.getFullYear()
      );
    });
  }
  return [];
});

const olderNotifications = computed(() => {
  if (notifications.value) {
    const today = new Date();
    return notifications.value.notifications.filter((notification) => {
      const notificationDate = new Date(notification.created_at);
      return (
        notificationDate.getDate() !== today.getDate() ||
        notificationDate.getMonth() !== today.getMonth() ||
        notificationDate.getFullYear() !== today.getFullYear()
      );
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
      notifications.value?.push(payload.new)
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

watch(
  () => route.path,
  () => {
    notificationsPopover.value.toggle();
  }
);

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
        <OverlayBadge v-if="user && notifications?.unread_count !== 0" :value="notifications?.unread_count" severity="danger" size="small">
          <Button icon="pi pi-bell" severity="secondary" rounded @click="seeNotifications" />
        </OverlayBadge>
        <Button v-else-if="user && notifications?.unread_count === 0" icon="pi pi-bell" severity="secondary" rounded @click="seeNotifications" />
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
              <div v-if="todayNotifications.length && !olderNotifications.length" class="text-center italic py-4 text-lg text-gray-500">
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