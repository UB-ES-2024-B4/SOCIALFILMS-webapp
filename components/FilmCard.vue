<script setup lang="ts">
import "primeicons/primeicons.css";
import type { Film } from "~/types";
import { genres } from "~/types/genres";
import { useUserMovieRelation } from "~/composables/useUserMovieRelation";

const props = defineProps({
  film: {
    type: Object as PropType<Film>,
    required: true,
  },
  trending: {
    type: Boolean,
    required: true,
  },
  trendingNumber: {
    type: Number,
    required: true,
  },
  favorite: {
    type: Boolean,
    required: true,
  },
  watch_later: {
    type: Boolean,
    required: true,
  }
});

const supabase = useSupabaseClient();
const is_favorite = ref(false);
const is_watch_later = ref(false);
const { isLoading, handleUserMovieRelation } = useUserMovieRelation(props.film.id, is_watch_later, is_favorite);

if (props.film.relations) {
  is_favorite.value = props.film.relations.is_favorite;
  is_watch_later.value = props.film.relations.is_watch_later;
}
else {
  try {
    const { data: userMovieRelations, error } = (await supabase.rpc("get_user_movie_relations", {
      _movie_id: props.film.id
    }))

    if (error) throw error;
    is_favorite.value = userMovieRelations?.favorite ?? false;
    is_watch_later.value = userMovieRelations?.watch_later ?? false;

  } catch (e) {
    console.error(e);
  }
}

watch(
  () => props.film.relations,
  (newRelations) => {
    if (newRelations) {
      is_favorite.value = newRelations.is_favorite;
      is_watch_later.value = newRelations.is_watch_later;
    }
  },
  { immediate: true }
);

</script>

<template>
  <div
    class="relative w-[235px] rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-500 hover:-translate-y-2"
  >
    <div class="relative aspect-[2/3]">
      <img
        :src="'https://image.tmdb.org/t/p/original' + film.poster_path"
        :alt="`${film.title} poster`"
        class="absolute inset-0 w-full h-full object-cover"
      />
      <div
        v-if="trending"
        class="absolute top-4 left-0 rounded-r-2xl shadow-md pl-4 pr-3 py-1.5 backdrop-blur bg-black/20 border-y border-r border-white/20 text-xs text-white font-normal"
      >
        {{ "#" + trendingNumber + " Trending" }}
      </div>
      <div class="absolute top-4 right-3">
        <div class="flex flex-col items-center gap-1.5">
          <button
            v-if="favorite"
            @click.stop="handleUserMovieRelation('favorite')"
            :disabled="isLoading"
            class="flex items-center justify-center w-8 h-8 rounded-full bg-white hover:bg-gray-100 shadow-lg transition-all duration-500 group"
          >
            <i
              :class="[
                'pi pi-heart-fill transition-all duration-500',
                is_favorite ? 'text-red-500' : 'text-gray-300',
                'group-hover:text-red-500'
              ]"
            ></i>
          </button>
          <button
            v-if="watch_later"
            @click.stop="handleUserMovieRelation('watch_later')"
            :disabled="isLoading"
            class="flex items-center justify-center w-8 h-8 rounded-full bg-white hover:bg-gray-100 shadow-lg transition-all duration-500 group"
          >
            <i
              :class="[
                'pi pi-bookmark-fill transition-all duration-500',
                is_watch_later ? 'text-amber-400' : 'text-gray-300',
                'group-hover:text-amber-400'
              ]"
            ></i>
          </button>
        </div>
      </div>
    </div>

    <div class="absolute bottom-0 left-0 w-full px-3.5 pt-1.5 pb-5 bg-neutral-400/10 text-white backdrop-blur">
      <h2 class="font-bold text-xl truncate">{{ film.title }}</h2>
      <h3 class="text-sm text-gray-300 mt-[2px] truncate">
        {{ film?.genre_ids?.map((id) => genres[id]).join(" • ") }}
      </h3>
      <div class="flex items-center space-x-1.5 mt-3">
        <span
          :class="
            film.adult
              ? 'tag bg-red-500/20 border border-red-500 text-red-500 dark:bg-red-500/20 dark:border-red-400 dark:text-red-400'
              : 'tag bg-green-500/20 border border-green-500 text-green-500 dark:bg-green-500/20 dark:border-green-400 dark:text-green-400'
          "
        >
          {{ film.adult ? "R" : "PG-13" }}
        </span>
        <span class="tag bg-gray-200/20 text-gray-200">
          <i class="pi pi-calendar mr-1.5 text-[0.8rem]"></i>
          {{ film.release_date }}
        </span>
        <span class="tag bg-gray-200/20 text-gray-200">
          <i class="pi pi-star-fill text-yellow-400 mr-1.5 text-[0.8rem]"></i>
          {{ film.vote_average.toFixed(1) }}
        </span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.tag {
  padding: 0.2rem 0.5rem;
  font-size: 0.8rem;
  font-weight: 400;
  border-radius: 9999px;
  display: inline-flex;
  align-items: center;
  backdrop-filter: blur(8px);
}
</style>
