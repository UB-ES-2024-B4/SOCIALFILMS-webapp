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

const buttonClick = (event: MouseEvent) => {
  // Prevenir la propagación del clic
  event.stopPropagation();
  console.log("Botón clickeado");
  liked.value = !liked.value
};

</script>

<template>
  <div
    class="relative w-[235px] rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-500 hover:-translate-y-2"
  >
    <div class="relative aspect-[3/3]">
      <img
        :src="'https://image.tmdb.org/t/p/original' + film.poster_path"
        :alt="`${film.title} poster`"
        class="absolute inset-0 object-cover"
      />
      <div
        v-if="trending"
        class="absolute top-4 left-0 rounded-r-2xl shadow-md pl-4 pr-3 py-1.5 backdrop-blur bg-black/20 border-y border-r border-white/20 text-xs text-white font-normal"
      >
        {{ "#" + trendingNumber + " Trending" }}
      </div>
      <div class="absolute top-4 right-3">
        <button
          @click="buttonClick($event)"
          class="flex items-center justify-center w-8 h-8 rounded-full bg-white shadow-lg hover:cursor-pointer hover:bg-gray-200 hover:shadow-xl transition-all"
        >
          <i
            :class="
              liked
                ? 'pi pi-heart-fill text-red-500'
                : 'pi pi-heart-fill text-gray-300'
            "
          ></i>
        </button>
      </div>
    </div>

    <div class="px-3.5 pt-1.5 pb-5 bg-neutral-400/10 text-white backdrop-blur">
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
