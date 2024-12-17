<script setup lang="ts">
import "primeicons/primeicons.css";
import type { Film, Notification } from "~/types";
import { timeAgo } from "~/utils/timeFunctions";

const props = defineProps({
  notification: {
    type: Object as PropType<Notification>,
    required: true,
  },
});

const emit = defineEmits<{
  (event: 'delete-notification', notification: Notification): void;
}>();

const supabase = useSupabaseClient();

const { data: movie, error: errorMovie } = (await supabase.rpc(
  "find_movie_by_id",
  { movie_id: props.notification.movie_id, lang: 'ca-ES' }
)) as { data: Film; error: any };

const isLoadingRead = ref(false);
const setNotificationAsRead = async () => {
  isLoadingRead.value = true;
  try {
    const { error } = (await supabase.rpc(
      "set_is_read",
      { _sender_username: props.notification.sender_username, _movie_id: props.notification.movie_id, _is_read: !props.notification.is_read }
    ))

    if (error) throw error;

    props.notification.is_read = !props.notification.is_read;

  } catch (error) {
    console.error("Error setting notification as read:", error);      
  }
  isLoadingRead.value = false;
}

const deleteNotification = async () => {
  try {
    const { error } = (await supabase.rpc(
      "delete_notification",
      { _sender_username: props.notification.sender_username, _movie_id: props.notification.movie_id }
    ))

    if (error) throw error;
    
    emit('delete-notification', props.notification);

  } catch (error) {
    console.error("Error setting notification as read:", error);      
  }
}

</script>

<template>
  <div 
    :class="[ 'w-full flex items-start gap-3 py-3 px-4 rounded-lg', 
    notification.is_read ? 'bg-transparent' : 'bg-sky-500/15 dark:bg-sky-400/15' ]"
    :style="{
      transition: 'background-color 0.5s ease',
    }">
    
    <img
			class="w-14 h-14 rounded-full object-cover border-[1.5px] border-gray-300"
			src="https://a.storyblok.com/f/191576/1200x800/a3640fdc4c/profile_picture_maker_before.webp"
			alt="image"
			/>

    <div class="inline-flex items-baseline sm:flex-col w-full pr-2">
			<!-- Notification message -->
      <div class="w-full flex items-start justify-between">
        <div class="flex flex-col pr-1">
          <span class="leading-tight">
            <strong>{{ notification.sender_username }}</strong> t'ha compartit la pel·lícula <strong>{{ movie.title }}</strong>
          </span>
          <span class="text-[0.95rem] text-gray-500 dark:text-gray-400">
            {{ timeAgo(notification.created_at) }}
          </span>
        </div>
        <div class="flex items-center gap-1.5">
          <Button
            severity="info"
            variant="outlined"
            aria-label="Mark as read"
            rounded
            :disabled="isLoadingRead"
            @click="setNotificationAsRead"
          >
            <template #icon>
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="size-6">
                <path d="M1.5 12.5L5.57574 16.5757C5.81005 16.8101 6.18995 16.8101 6.42426 16.5757L9 14" stroke-width="1.5" stroke-linecap="round"/>
                <path d="M16 7L12 11" stroke-width="1.5" stroke-linecap="round"/>
                <path d="M7 12L11.5757 16.5757C11.8101 16.8101 12.1899 16.8101 12.4243 16.5757L22 7" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
            </template>
          </Button>
          <Button
            severity="danger"
            variant="outlined"
            icon="pi pi-times"
            aria-label="Delete notification"
            rounded
            @click="deleteNotification"
          />
        </div>
      </div>
			
			<!-- Movie info -->
			<div class="w-full flex gap-4 border-[1.2px] rounded-lg mt-3 p-3 bg-[#fdfdfd] dark:bg-[#1C1C1C] dark:border-[#2A2A2A]">
				<img
					class="w-24 rounded"
					:src="'https://image.tmdb.org/t/p/original' + movie.poster_path"
          :alt="`${movie.title} poster`"
					/>
				<div class="w-full flex flex-col justify-between">
					<div class="w-full flex items-start justify-between">
						<div class="pt-1 flex flex-col">
							<h3 class="text-lg font-semibold">{{ movie.title }}</h3>
							<span class="w-48 font-medium text-slate-500 dark:text-slate-400 text-sm truncate">
                {{ movie.genres?.map((genre) => genre.name).join(" • ") }}
              </span>
						</div>
						<div class="bg-slate-100 dark:bg-zinc-700 p-1" style="border-radius: 30px">
							<div class="bg-white dark:bg-zinc-800 flex items-center gap-2 justify-center py-1 px-2" style="border-radius: 30px; box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.04), 0px 1px 2px 0px rgba(0, 0, 0, 0.06)">
								<span class="text-slate-900 dark:text-slate-200 font-medium text-sm">{{ movie.vote_average.toFixed(1) }}</span>
								<i class="pi pi-star-fill text-yellow-500"></i>
							</div>
						</div>
					</div>
					<Button icon="pi pi-arrow-up-right" label="Veure pel·lícula" fluid @click="navigateTo(`/movies/${movie?.id}`);"></Button>
				</div>
			</div>
    </div>
  </div>
</template>