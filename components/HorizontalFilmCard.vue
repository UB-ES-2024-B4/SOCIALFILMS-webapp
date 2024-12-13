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
    class="relative w-[270px] rounded-3xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-500 hover:scale-[1.03]"
  >
    <div class="relative aspect-[3/2]">
      <img
        :src="'https://image.tmdb.org/t/p/original' + film.backdrop_path"
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
        <button
          @click.stop ="saved = !saved"
          class="flex items-center justify-center w-8 h-8 rounded-full bg-white hover:bg-gray-100 shadow-lg"
        >
          <i
            :class="
              saved
                ? 'pi pi-bookmark-fill text-amber-400'
                : 'pi pi-bookmark-fill text-gray-300'
            "
          ></i>
        </button>
      </div>
    </div>

    <div class="absolute bottom-0 left-0 w-full px-3.5 pt-1.5 pb-5 bg-neutral-400/10 text-white backdrop-blur">     
      <div class="w-full flex items-start justify-between">
        <div class="w-3/4">
          <h2 class="font-bold text-lg truncate">{{ film.title }}</h2>
          <h3 class="text-xs text-gray-300 mt-[2px] truncate leading-none">
            {{ film?.genre_ids?.map((id) => genres[id]).join(" • ") }}
          </h3>
        </div>
        <span class="tag bg-gray-200/20 text-gray-200 mt-1">
          <i class="pi pi-star-fill text-yellow-400 mr-1.5 text-[0.8rem]"></i>
          {{ film.vote_average.toFixed(1) }}
        </span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.tag {
  padding: 0.3rem 0.6rem;
  font-size: 0.8rem;
  font-weight: 400;
  border-radius: 9999px;
  display: inline-flex;
  align-items: center;
  backdrop-filter: blur(8px);
}
</style>
