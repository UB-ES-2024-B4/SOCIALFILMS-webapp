<script setup lang="ts">
import type { Film, FilmsAPI } from "~/types";
import FilmCard from "~/components/FilmCard.vue";
import HorizontalFilmCard from "~/components/HorizontalFilmCard.vue";
import BigFilmCard from "~/components/BigFilmCard.vue";

const supabase = useSupabaseClient();

definePageMeta({
  layout: "navbar",
});

const { data, error } = (await supabase.rpc("get_trending_movies_of_week")) as {
  data: FilmsAPI;
  error: any;
};

const navigateToMovie = (id: number) => {
  navigateTo(`/movies/${id}`);
};

const responsiveOptions = ref([
  { breakpoint: 2000, numVisible: 6 },
  { breakpoint: 1750, numVisible: 5 },
  { breakpoint: 1600, numVisible: 4 },
  { breakpoint: 1300, numVisible: 3 },
  { breakpoint: 1000, numVisible: 2 },
  { breakpoint: 700, numVisible: 1 },
]);

const currentIndex = ref(0);
const slidesPerView = ref(4);

const updateSlidesPerView = () => {
  const screenWidth = window.innerWidth;
  for (const option of responsiveOptions.value) {
    if (screenWidth <= option.breakpoint) {
      slidesPerView.value = option.numVisible;
    }
  }
};

const nextSlide = () => {
  const maxIndex = Math.ceil(data.results.length / slidesPerView.value) - 1;
  currentIndex.value = (currentIndex.value + 1) % (maxIndex + 1);
};

const prevSlide = () => {
  const maxIndex = Math.ceil(data.results.length / slidesPerView.value) - 1;
  currentIndex.value = (currentIndex.value - 1 + maxIndex + 1) % (maxIndex + 1);
};

function chunkArray(array, chunkSize) {
  const chunks = [];
  for (let i = 0; i < array.length; i += chunkSize) {
    chunks.push(array.slice(i, i + chunkSize));
  }
  return chunks;
}

onMounted(() => {
  updateSlidesPerView();
  window.addEventListener("resize", updateSlidesPerView);
});

onUnmounted(() => {
  window.removeEventListener("resize", updateSlidesPerView);
});

</script>

<template>
  <div
    class="w-full h-full fixed inset-0 bg-cover bg-center"
    :style="{ backgroundImage: `url(https://image.tmdb.org/t/p/original${data.results[0].backdrop_path})` }"
  ></div>

  <div class="pt-[5.8rem] w-full h-full flex-col justify-center backdrop-blur-lg bg-zinc-300/20 dark:bg-black/60">
    <div class="w-full flex px-10 pb-5 gap-12">
      <!-- Left Column -->
      <div class="flex flex-col items-start gap-12 grow-0 w-1/3">
        <!-- Billboard -->
        <div class="h-[500px] flex flex-col items-start pt-6 bg-zinc-200/20 rounded-[2.5rem] shadow-lg">
          <h3 class="font-bold text-white text-[1.6rem] ml-12 mb-2">Cartellera</h3>
          <div class="w-full h-full px-10 pt-1.5 pb-16 overflow-y-auto">
            <div class="flex flex-col items-center gap-4">
              <HorizontalFilmCard
                v-for="film in data.results"
                class="cursor-pointer"
                :film="film"
                :trending="false"
                :trendingNumber="1"
              ></HorizontalFilmCard>
            </div>
          </div>
        </div>

        <!-- My list -->
        <div class="h-[500px] flex flex-col items-start pt-6 bg-zinc-200/20 rounded-[2.5rem] shadow-lg">
          <h3 class="font-bold text-white text-[1.6rem] ml-12 mb-2">La meva llista</h3>
          <div class="w-full h-full px-10 pt-1.5 pb-16 overflow-y-auto">
            <div class="flex flex-col items-center gap-4">
              <HorizontalFilmCard
                v-for="film in data.results"
                class="cursor-pointer"
                :film="film"
                :trending="false"
                :trendingNumber="1"
              ></HorizontalFilmCard>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column -->
      <div class="flex-1 flex flex-col gap-10 max-w-[68%]">
        <BigFilmCard
          class="cursor-pointer h-[500px]"
          :film="data.results[0]"
          :trending="true"
          :trendingNumber="1"
          @click="navigateToMovie(data.results[0].id)"
        ></BigFilmCard>

        <div class="flex flex-col gap-2">
          <div class="flex items-end justify-between">
            <h2 class="font-extrabold text-white text-3xl mb-1">Pel·lícules Trending</h2>
            <div class="flex items-center justify-center gap-2">
              <button
                @click ="prevSlide"
                class="flex items-center justify-center w-14 h-14 rounded-full text-white bg-zinc-200/35 hover:bg-zinc-200/60"
              > 
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="mr-1 size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
                </svg>
              </button>
              <button
                @click ="nextSlide"
                class="flex items-center justify-center w-14 h-14 rounded-full text-white bg-zinc-200/35 hover:bg-zinc-200/60"
              > 
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="ml-1 size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
              </svg>
              </button>
            </div>
          </div>
          <!-- Carousel Section -->
          <div class="relative w-full overflow-hidden pt-2 pb-16">
            <!-- Contenedor del Carrusel -->
            <div
              class="flex transition-transform duration-500"
              :style="{ transform: `translateX(-${currentIndex * 100}%)` }"
            >
              <!-- Cada slide -->
              <div
                v-for="(chunk, chunkIndex) in chunkArray(data.results, slidesPerView)"
                :key="chunkIndex"
                class="flex-shrink-0 w-full flex justify-start gap-16"
              >
                <!-- Cada FilmCard -->
                <FilmCard
                  v-for="(film, index) in chunk"
                  class="cursor-pointer"
                  :key="index"
                  :film="film"
                  :trending="true"
                  :trendingNumber="chunkIndex * slidesPerView + index + 1"
                  @click="navigateToMovie(film.id)"
                ></FilmCard>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
::-webkit-scrollbar {
  width: 8px;
  transition: opacity 0.3s ease;
}
::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 10px;
}
::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>