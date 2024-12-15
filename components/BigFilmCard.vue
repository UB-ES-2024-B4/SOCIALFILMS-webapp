<script setup lang="ts">
import "primeicons/primeicons.css";
import type { Film } from "~/types";
import { genres } from "~/types/genres";

defineProps({
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
});

const liked = ref(false);
const saved = ref(false);
</script>

<template>
  <div
    class="relative w-full rounded-3xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-500 transform hover:scale-[1.015]"
  >
    <div class="relative md:aspect-[4/5] lg:aspect-[7/5] xl:aspect-[8/5]">
      <img
        :src="'https://image.tmdb.org/t/p/original' + film.backdrop_path"
        :alt="`${film.title} poster`"
        class="absolute inset-0 w-full h-full object-cover"
      />
      <div class="absolute inset-0 bg-gradient-to-r from-neutral-800/60 via-neutral-800/20 to-neutral-800/0"></div>
      <div
        v-if="trending"
        class="absolute top-8 left-0 rounded-r-2xl shadow-md pl-4 pr-3 py-1.5 backdrop-blur bg-black/20 border border-white/20 text-sm text-white font-normal"
      >
        🔥 Trending Ara
      </div>
    </div>

    <div class="absolute bottom-0 left-0 w-full px-8 pt-1.5 pb-6 text-white">     
      <div class="w-full flex flex-col items-start justify-between">
        <div class="w-[48%]">
          <h3 class="text-sm text-gray-300 mt-[2px] truncate">
            {{ film?.genre_ids?.map((id) => genres[id]).join(" • ") }}
          </h3>
          <h2 class="font-bold text-[2rem] truncate">{{ film.title }}</h2>
          <p class="text-zinc-300/80 mt-1">{{ film.overview }}</p>
        </div>
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
            <i class="pi pi-calendar mr-1.5 text-[0.9rem]"></i>
            {{ film.release_date }}
          </span>
          <span class="tag bg-gray-200/20 text-gray-200">
            <i class="pi pi-star-fill text-yellow-400 mr-1.5 text-[0.9rem]"></i>
            {{ film.vote_average.toFixed(1) }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.tag {
  padding: 0.3rem 0.7rem;
  font-size: 0.9rem;
  font-weight: 400;
  border-radius: 9999px;
  display: inline-flex;
  align-items: center;
  backdrop-filter: blur(8px);
}
</style>
