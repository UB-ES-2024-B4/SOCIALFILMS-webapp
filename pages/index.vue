<script setup lang="ts">
import type { Film, FilmsAPI } from "~/types";
import FilmCard from "~/components/FilmCard.vue";
import HorizontalFilmCard from "~/components/HorizontalFilmCard.vue";
import BigFilmCard from "~/components/BigFilmCard.vue";

const supabase = useSupabaseClient();
const user = useSupabaseUser();

definePageMeta({
  layout: "navbar",
});

const { data: trendingMovies, error: errorTrendingMovies } = (await supabase.rpc(
  "get_trending_movies_of_week", 
  { 
    lang: 'ca-ES'
  }
)) as {  data: FilmsAPI; error: any };

const topRatedMovies = ref<FilmsAPI>();
const popularMovies = ref<FilmsAPI>();
const currentMovies = ref<Film[]>([]);

const { data: nowPlayingMovies, error: errorNowPlayingMovies } = (await supabase.rpc(
  "get_now_playing_movies",
  { 
    lang: 'ca-ES',
    region: 'ES'
  }
)) as { data: FilmsAPI; error: any };

const { data: myListMovies, error: errorMyListMovies } = (await supabase.rpc(
  "get_user_movies",
  { 
    _relation_type: 'watch_later'
  }
)) as { data: Film[]; error: any };

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
  const maxIndex = Math.ceil(trendingMovies.results.length / slidesPerView.value) - 1;
  currentIndex.value = (currentIndex.value + 1) % (maxIndex + 1);
};

const prevSlide = () => {
  const maxIndex = Math.ceil(trendingMovies.results.length / slidesPerView.value) - 1;
  currentIndex.value = (currentIndex.value - 1 + maxIndex + 1) % (maxIndex + 1);
};

function chunkArray(array, chunkSize) {
  const chunks = [];
  for (let i = 0; i < array.length; i += chunkSize) {
    chunks.push(array.slice(i, i + chunkSize));
  }
  return chunks;
}

const activeList = ref("trending");
const isTransitioningList = ref(false);
const setActiveList = async (list: string) => {
  if (activeList.value === list) return;

  isTransitioningList.value = true;

  if (list === 'trending') {
    currentMovies.value = trendingMovies.results;
  } 
  else if (list === 'top_rated') {
    currentMovies.value = topRatedMovies.value?.results || [];
  }
  else if (list === 'popular') {
    currentMovies.value = popularMovies.value?.results || [];
  }

  if (currentMovies.value.length === 0) {
    await fetchMoviesList(list);
  }

  await new Promise((resolve) => setTimeout(resolve, 300));
  activeList.value = list;

  currentIndex.value = 0;
  isTransitioningList.value = false;
};

const fetchMoviesList = async (list: string) => {
  try {
    if (list === "top_rated") {
      const { data, error } = await supabase.rpc(
        "get_top_rated_movies",
        { 
          lang: 'ca-ES'
        }
      ) as { data: FilmsAPI; error: any };
      if (error) throw error;
      topRatedMovies.value = data;
      currentMovies.value = topRatedMovies.value.results;
    }
    else if (list === "popular") {
      const { data, error } = await supabase.rpc(
        "get_popular_movies",
        { 
          lang: 'ca-ES'
        }
      ) as { data: FilmsAPI; error: any };
      if (error) throw error;
      popularMovies.value = data;
      currentMovies.value = popularMovies.value.results;
    }   
  } catch (error) {
    console.error("Error fetching movies:", error.message);
  }
};

const buttonListClass = (list: string) => {
  return [
    "flex items-center justify-center h-14 rounded-3xl px-9 py-[2.7rem] text-lg text-white transition-all duration-500 transform",
    activeList.value === list
      ? "bg-zinc-200/50 scale-[1.015] ring-1 ring-zinc-300/90 font-semibold shadow-xl"
      : "bg-zinc-200/20 hover:bg-zinc-200/50 hover:scale-[1.015] hover:shadow-xl hover:ring-1 ring-zinc-300/90",
  ];
};

onMounted(() => {
  updateSlidesPerView();
  window.addEventListener("resize", updateSlidesPerView);
  fetchMoviesList('top_rated');
  fetchMoviesList('popular');
  currentMovies.value = trendingMovies.results;
});

onUnmounted(() => {
  window.removeEventListener("resize", updateSlidesPerView);
});

</script>

<template>
  <div
    class="w-full h-full fixed inset-0 bg-cover bg-center"
    :style="{ backgroundImage: `url(https://image.tmdb.org/t/p/original${trendingMovies.results[0].backdrop_path})` }"
  ></div>

  <div class="absolute inset-0 bg-gradient-to-b from-neutral-800/50 via-neutral-800/5 via-25% to-neutral-800/0"></div>

  <div class="pt-[5.8rem] w-full h-full flex-col justify-center backdrop-blur-lg bg-zinc-300/20 dark:bg-black/60">
    <div class="w-full flex px-10 gap-12">
      <!-- Left Column -->
      <div class="flex flex-col items-start gap-12 grow-0 w-1/3">
        <!-- Billboard -->
        <div class="h-[500px] w-[350px] flex flex-col items-start pt-6 bg-zinc-200/20 rounded-[2.5rem] shadow-lg">
          <h3 class="font-bold text-white text-[1.6rem] ml-12 mb-2">Cartellera</h3>
          <div class="w-full h-full px-10 pt-1.5 pb-16 overflow-y-auto">
            <div class="flex flex-col items-center gap-4">
              <HorizontalFilmCard
                v-for="film in nowPlayingMovies.results"
                class="cursor-pointer"
                :film="film"
                :favorite="true"
                :watch_later="false"
                @click="navigateToMovie(film.id)"
              ></HorizontalFilmCard>
            </div>
          </div>
        </div>

        <!-- My list -->
        <div class="h-[500px] w-[350px] flex flex-col items-start pt-6 bg-zinc-200/20 rounded-[2.5rem] shadow-lg">
          <h3 class="font-bold text-white text-[1.6rem] ml-12 mb-2">La meva llista</h3>
          <div v-if="user && myListMovies" class="w-full h-full px-10 pt-1.5 pb-16 overflow-y-auto">
            <div class="flex flex-col items-center gap-4">
              <HorizontalFilmCard
                v-for="film in myListMovies"
                class="cursor-pointer"
                :film="film"
                :favorite="false"
                :watch_later="true"
                @click="navigateToMovie(film.id)"
              ></HorizontalFilmCard>
            </div>
          </div>
          <span v-else-if="!myListMovies && user" class="text-center text-gray-300 text-lg italic px-10 pt-1.5 pb-16">
            Encara no tens pel·lícules a la teva llista.
          </span>
          <span v-else class="text-center text-gray-300 text-lg italic px-10 pt-1.5 pb-16">
            Inicia sessió per poder afegir pel·lícules a la teva llista.
          </span>
        </div>
      </div>

      <!-- Right Column -->
      <div class="flex flex-col gap-12 w-[67%]">
        <BigFilmCard
          class="cursor-pointer h-[500px]"
          :film="trendingMovies.results[0]"
          :trending="true"
          :trendingNumber="1"
          @click="navigateToMovie(trendingMovies.results[0].id)"
        ></BigFilmCard>

        <div class="flex flex-col gap-2">
          <div class="flex items-center gap-2.5">
            <button
              @click="setActiveList('trending')"
              :class="buttonListClass('trending')"
            > 
              <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 56 56" stroke="currentColor" class="mr-1.5 size-9">
                <path d="M 8.1250 37.3984 C 8.1250 46.9141 15.9063 53.6406 26.8750 53.6406 C 39.3203 53.6406 47.8750 45.6016 47.8750 32.3828 C 47.8750 11.7578 29.7812 2.3594 16.5860 2.3594 C 14.5000 2.3594 13.4687 3.3906 13.4687 4.5859 C 13.4687 5.5469 13.9844 6.3437 14.7578 7.4453 C 16.6328 10.0234 19.8203 13.7734 19.8203 18.4844 C 19.8203 18.8828 19.7969 19.2813 19.7500 19.7031 C 18.4375 17.2422 16.1172 15.5078 13.3047 15.5078 C 12.5078 15.5078 12.0860 15.9766 12.0860 16.6562 C 12.0860 17.4766 12.2734 18.0625 12.2734 20.6172 C 12.2734 25.5156 8.1250 28.8203 8.1250 37.3984 Z M 27.3438 47.0547 C 22.6563 47.0547 19.5391 44.2187 19.5391 40.0000 C 19.5391 35.5703 22.6797 34.0000 23.1016 31.1406 C 23.1250 30.9062 23.2891 30.8359 23.4531 31.0000 C 24.6250 32.0078 25.3516 33.2734 25.9141 34.7266 C 26.0312 34.9844 26.2187 35.0078 26.3360 34.7969 C 27.6250 32.5469 27.8594 29.1953 27.5547 24.9766 C 27.5078 24.7422 27.6719 24.625 27.8828 24.7187 C 33.4375 27.2500 36.2734 32.7578 36.2734 37.7031 C 36.2734 42.6719 33.3438 47.0547 27.3438 47.0547 Z"/>
              </svg>
              Trending
            </button>
            <button
              @click="setActiveList('top_rated')"
              :class="buttonListClass('top_rated')"
            > 
              <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 512 512" stroke-width="15" stroke="currentColor" class="mr-3 size-10">
                <g>
                  <path d="M34.044,278.031c-0.641-0.516-1.531-0.594-2.266-0.234c-0.734,0.391-1.172,1.172-1.109,2l3.219,50.547
                    c0.078,0.891-0.453,1.719-1.297,2.063L1.326,344.828c-0.719,0.297-1.219,0.953-1.313,1.703c-0.078,0.766,0.266,1.516,0.891,1.953
                    l83.922,50.922c0.578,0.406,1.328,0.484,1.969,0.203c0.672-0.266,1.141-0.859,1.266-1.563l12.641-71.875
                    c0.141-0.75-0.156-1.5-0.734-1.984L34.044,278.031z"/>
                  <path d="M479.419,332.406c-0.828-0.344-1.359-1.172-1.313-2.063l3.25-50.547c0.047-0.828-0.391-1.609-1.125-2
                    c-0.734-0.359-1.625-0.281-2.266,0.234l-65.922,46.156c-0.578,0.484-0.875,1.234-0.734,1.984l12.656,71.875
                    c0.109,0.703,0.578,1.297,1.234,1.563c0.672,0.281,1.406,0.203,2-0.203l83.906-50.922c0.641-0.438,0.969-1.188,0.875-1.953
                    c-0.078-0.75-0.578-1.406-1.281-1.703L479.419,332.406z"/>
                  <path d="M255.998,392.469c-48.422,0-94.266-11.25-135.109-31.203l-13.156,74.75
                    c45.609,19.281,95.719,29.953,148.266,29.953s102.672-10.672,148.281-29.953l-13.172-74.75
                    C350.294,381.219,304.451,392.469,255.998,392.469z"/>
                  <polygon points="74.873,186.625 81.388,199.797 95.919,201.906 85.404,212.156 87.873,226.641 74.873,219.797 
                    61.873,226.641 64.357,212.156 53.826,201.906 68.373,199.797 	"/>
                  <polygon points="137.373,82.578 143.873,95.75 158.419,97.859 147.888,108.109 150.373,122.594 137.373,115.766 
                    124.357,122.594 126.857,108.109 116.326,97.859 130.873,95.75 	"/>
                  <polygon points="437.138,186.625 430.638,199.797 416.106,201.906 426.622,212.156 424.138,226.641 437.138,219.797 
                    450.153,226.641 447.669,212.156 458.185,201.906 443.638,199.797 	"/>
                  <polygon points="374.654,82.578 368.154,95.75 353.607,97.859 364.123,108.109 361.654,122.594 374.654,115.766 
                    387.653,122.594 385.169,108.109 395.7,97.859 381.154,95.75 	"/>
                  <polygon points="251.498,46.031 257.998,59.203 272.544,61.328 262.013,71.578 264.498,86.063 251.498,79.219 
                    238.498,86.063 240.982,71.578 230.451,61.328 244.998,59.203 	"/>
                  <path d="M236.091,129.266c3.344-6.766,10.219-11.047,17.75-11.047c7.547,0,14.438,4.281,17.766,11.047l19.703,39.922
                    c2.891,5.844,8.469,9.906,14.906,10.844l44.063,6.391c7.469,1.094,13.672,6.313,16,13.484s0.391,15.031-5.016,20.297
                    l-31.875,31.078c-4.672,4.547-6.797,11.109-5.703,17.531l7.531,43.891c1.266,7.422-1.781,14.922-7.875,19.359
                    c-6.109,4.438-14.188,5.016-20.859,1.5l-39.422-20.719c-5.766-3.031-12.656-3.031-18.422,0l-39.406,20.719
                    c-6.688,3.516-14.75,2.938-20.875-1.5c-6.094-4.438-9.141-11.938-7.875-19.359l7.531-43.891c1.109-6.422-1.031-12.984-5.688-17.531
                    l-31.891-31.078c-5.391-5.266-7.328-13.125-5-20.297s8.531-12.391,15.984-13.484l44.063-6.391c6.438-0.938,12.031-5,14.906-10.844
                    L236.091,129.266z"/>
                </g>
              </svg>
              Top Valorades
            </button>
            <button
              @click="setActiveList('popular')"
              :class="buttonListClass('popular')"
            > 
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" viewBox="0 0 24 24" class="mr-1.5 size-9">
                <path d="M20.0005 7L14.1543 12.9375C14.0493 13.0441 13.9962 13.0976 13.9492 13.1396C13.1899 13.8193 12.0416 13.8193 11.2822 13.1396C11.2352 13.0976 11.1817 13.0442 11.0767 12.9375C10.9716 12.8308 10.9191 12.7774 10.8721 12.7354C10.1127 12.0557 8.96397 12.0557 8.20461 12.7354C8.15771 12.7773 8.10532 12.8305 8.00078 12.9367L4 17M20.0005 7L20 13M20.0005 7H14" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              Populars
            </button>
          </div>
          <div class="flex items-end justify-between">
            <h2 class="font-bold text-white text-3xl mb-1">
              Pel·lícules
              {{
                activeList === 'trending'
                  ? 'Trending'
                  : activeList === 'popular'
                  ? 'Populars'
                  : 'Millor Valorades'
              }}
            </h2>
            <div class="flex items-center justify-center gap-2">
              <button
                @click ="prevSlide"
                class="flex items-center justify-center w-14 h-14 rounded-full text-white bg-zinc-200/35 hover:bg-zinc-200/60 transition-all duration-500"
              > 
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="mr-1 size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
                </svg>
              </button>
              <button
                @click ="nextSlide"
                class="flex items-center justify-center w-14 h-14 rounded-full text-white bg-zinc-200/35 hover:bg-zinc-200/60 transition-all duration-500"
              > 
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="ml-1 size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
              </svg>
              </button>
            </div>
          </div>
          <!-- Carousel Section -->
          <div 
            class="relative w-full overflow-hidden pt-2 pb-16"
            :class="{ 'opacity-0 pointer-events-none': isTransitioningList, 'opacity-100': !isTransitioningList }"
            :style="{ transition: 'opacity 0.3s ease-in-out' }"
            >
            <!-- Contenedor del Carrusel -->
            <div
              class="flex transition-transform duration-500"
              :style="{ transform: `translateX(-${currentIndex * 100}%)` }"
            >
              <!-- Cada slide -->
              <div
                v-for="(chunk, chunkIndex) in chunkArray(currentMovies, slidesPerView)"
                :key="chunkIndex"
                class="flex-shrink-0 w-full flex justify-start gap-[3.4rem]"
              >
                <!-- Cada FilmCard -->
                <FilmCard
                  v-for="(film, index) in chunk"
                  class="cursor-pointer"
                  :key="index"
                  :film="film"
                  :trending="activeList === 'trending'"
                  :trendingNumber="chunkIndex * slidesPerView + index + 1"
                  :favorite="true"
                  :watch_later="false"
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