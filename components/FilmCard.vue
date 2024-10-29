<script setup lang="ts">
import 'primeicons/primeicons.css'
import type { Film } from '~/types';
import { genres } from '~/types/genres';

defineProps({
  film: {
    type: Object as PropType<Film>,
    required: true
  },
  trending: {
    type: Boolean,
    required: true
  },
  trendingNumber: {
    type: Number,
    required: true
  },
});

const liked = ref(false)

</script>

<template>
  <div class="relative w-60 rounded-xl overflow-hidden shadow-lg hover:shadow-2xl transition-shadow duration-500 dark:bg-neutral-800">
    <!-- Header -->
    <div class="relative aspect-[2/3]">
      <img
        :src="film.poster"
        :alt="`${film.title} poster`"
        class="absolute inset-0 object-cover"
      />
      <div v-if="trending" class="absolute top-4 left-0 rounded-r-2xl shadow-md pl-4 pr-3 py-1.5 backdrop-blur bg-black/20 border-y border-r border-white/20 text-xs text-white font-normal">
        {{ '#'+trendingNumber+' Trending' }}
      </div>
      <div class="absolute top-4 right-3">
        <button @click="liked = !liked" class="flex items-center justify-center w-8 h-8 rounded-full bg-white shadow-lg">
          <i :class="liked ? 'pi pi-heart-fill text-red-500' : 'pi pi-heart-fill text-gray-300'"></i>
        </button>
      </div>
    </div>

    <!-- Footer -->
    <div class="px-3 pt-1.5 pb-5 bg-white/60 dark:bg-neutral-900/60 dark:text-white backdrop-blur-md">
      <h2 class="font-bold text-xl">{{ film.title }}</h2>
      <h3 class="text-sm text-gray-500 dark:text-gray-400">{{ film.genre.map(id => genres[id]).join(' • ') }}</h3>
      <div class="flex items-center space-x-1.5 mt-3">
        <span :class="film.isAdult ? 
        'tag bg-red-500/20 border border-red-500 text-red-500 dark:bg-red-500/20 dark:border-red-400 dark:text-red-400' :
        'tag bg-green-500/20 border border-green-500 text-green-500 dark:bg-green-500/20 dark:border-green-400 dark:text-green-400'">
          {{ film.isAdult ? 'R' : 'PG-13' }}
        </span>
        <span class="tag bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-200">
          <i class="pi pi-calendar mr-1.5" style="font-size: small"></i>
          {{ film.releaseDate }}
        </span>
        <span class="tag bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-200">
          <i class="pi pi-star-fill text-yellow-400 mr-1.5" style="font-size: small"></i> 
          {{ film.voteAverage }}
        </span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.tag {
  padding: 0.15rem 0.5rem;
  font-size: 0.77rem;
  font-weight: 400;
  border-radius: 9999px;
  display: inline-flex; /* Para alinear el icono y el texto */
  align-items: center;
  backdrop-filter: blur(8px);
}
</style>