<script setup lang="ts">
import type { Film, Review } from "~/types";
import ReviewCard from "~/components/ReviewCard.vue";
import CreditCard from "~/components/CreditCard.vue";

const supabase = useSupabaseClient()
const route = useRoute()

const { data: dataMovie, error: errorMovie } = await supabase.rpc('find_movie_by_id', {movie_id: route.params.id}) as {data: Film[], error: any}
const { data: dataReviews, error: errorReviews } = await supabase.rpc('get_reviews', {_movie_id: route.params.id}) as {data: Review[], error: any}

const reviews = dataReviews?.map(review => ({
  ...review,
  created_at: new Date(review.created_at)
})) || [];

console.log(dataMovie)

const posterTranslateY = ref(-112) 
const scrollThreshold = 200

const handleScroll = () => {
  const scrollPosition = window.scrollY

  const newTranslateY = -112 + Math.min(scrollPosition, 100);
  posterTranslateY.value = Math.max(newTranslateY, -112);

  if (scrollPosition > scrollThreshold) {
    const adjustedScroll = scrollPosition - scrollThreshold
    const newTranslateY = -112 + Math.min(adjustedScroll, 100)
    posterTranslateY.value = Math.max(newTranslateY, -112)
  } else {
    posterTranslateY.value = -112
  }
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', handleScroll)
})

const visibleDrawerDirector = ref(false)
const visibleDrawerScript = ref(false)
const visibleDrawerCast = ref(false)

</script>

<template>
  <Drawer v-model:visible="visibleDrawerDirector" header="Director" position="right">
    <CreditCard 
      image="https://image.tmdb.org/t/p/original/DDeITcCpnBd0CkAIRPhggy9bt5.jpg" 
      name="Alfonso Kakna"
      rol-or-character="Manolo Aada">
    </CreditCard>
  </Drawer>
  <Drawer v-model:visible="visibleDrawerScript" header="Guión" position="right">
    <CreditCard 
      image="https://image.tmdb.org/t/p/original/DDeITcCpnBd0CkAIRPhggy9bt5.jpg" 
      name="Alfonso Kakna"
      rol-or-character="Manolo Aada">
    </CreditCard>
  </Drawer>
  <Drawer v-model:visible="visibleDrawerCast" header="Reparto" position="right">
    <CreditCard 
      image="https://image.tmdb.org/t/p/original/DDeITcCpnBd0CkAIRPhggy9bt5.jpg" 
      name="Alfonso Kakna"
      rol-or-character="Manolo Aada">
    </CreditCard>
  </Drawer>

  <div class="w-full min-h-screen">
    <!-- Backdrop Image -->
    <div
      class="fixed w-full h-full bg-cover bg-center bg-fixed transition-opacity"
      :style="{ backgroundImage: `url(${'https://image.tmdb.org/t/p/original'+dataMovie.backdrop_path})` }"
      >
    </div>

    <!-- Film Info Section -->
    <div class="relative z-10 pt-[28rem]">
      <div class="backdrop-blur-xl bg-white/70 dark:bg-black/50">
        <div class="flex flex-col md:flex-row px-4 pt-4 md:px-10 md:pt-10">
          <!-- Poster -->
          <img
            :src="'https://image.tmdb.org/t/p/original'+dataMovie.poster_path"
            :alt="`${dataMovie.title} poster`"
            class="w-48 md:w-80 rounded-lg shadow-xl md:mr-10 transition-transform duration-500 dark:shadow-gray-300/15"
            :style="{ transform: `translateY(${posterTranslateY}px)` }"
          />

          <!-- Film Details -->
          <div class="flex flex-col">
            <h1 class="text-7xl font-extrabold mb-4">{{ dataMovie.title }}</h1>
            <div class="flex flex-col flex-1 mt-4 md:flex-row md:mt-0 gap-14">
              <!-- Detalles de la película -->
              <div class="flex-1 flex flex-col space-y-3">
                <h2 class="text-lg text-gray-600 dark:text-gray-400">{{ dataMovie.genres?.map(genre => genre.name).join(' • ') }}</h2>
              
                <!-- Ratings and Tags -->
                <div class="flex items-center space-x-2 mt-4">
                  <span :class="dataMovie.adult ? 
                  'tag bg-red-500/20 border border-red-500 text-red-500 dark:border-red-400 dark:text-red-400' :
                  'tag bg-green-500/20 border border-green-500 text-green-500 dark:border-green-400 dark:text-green-400'">
                    {{ dataMovie.adult ? 'R' : 'PG-13' }}
                  </span>
                  <span class="tag bg-gray-100/50 text-gray-600 dark:bg-gray-700/50 dark:text-gray-200">
                    <i class="pi pi-calendar mr-1.5"></i>
                    {{ dataMovie.release_date }}
                  </span>
                  <span class="tag bg-gray-100/50 text-gray-600 dark:bg-gray-700/50 dark:text-gray-200">
                    <i class="pi pi-star-fill text-yellow-400 mr-1.5"></i> 
                    {{ dataMovie.vote_average }}
                  </span>
                </div>
                <div>
                  <h3 class="text-3xl font-bold mt-4 mb-1.5">Sinopsis</h3>
                  <p>{{ dataMovie.overview }}</p>
                </div>
              </div>

              <!-- Film Director, Cast, etc -->
              <div class="flex-none md:w-1/3 lg:w-1/4 space-y-10"> <!-- Ajusta el ancho según tus necesidades -->
                <div>
                  <div class="divider"></div>
                  <div class="flex justify-between">
                    <div>
                      <h4 class="text-lg font-semibold text-violet-500 dark:text-violet-400 mb-1">Director/a</h4>
                      <p class="text-gray-600 dark:text-gray-400">James Cameron</p>
                    </div>
                    <Button icon="pi pi-angle-right" text rounded aria-label="More info" @click="visibleDrawerDirector = true"/>
                  </div>
                  
                </div>
                <div>
                  <div class="divider"></div>
                  <div class="flex justify-between">
                    <div>
                      <h4 class="text-lg font-semibold text-violet-500 dark:text-violet-400 mb-1">Guión</h4>
                      <p class="text-gray-600 dark:text-gray-400">James Cameron</p>
                    </div>
                    <Button icon="pi pi-angle-right" text rounded aria-label="More info" @click="visibleDrawerScript = true"/>
                  </div>
                </div>
                <div>
                  <div class="divider"></div>
                  <div class="flex justify-between">
                    <div>
                      <h4 class="text-lg font-semibold text-violet-500 dark:text-violet-400 mb-1">Reparto</h4>
                      <p class="text-gray-600 dark:text-gray-400">James Cameron</p>
                    </div>
                    <Button icon="pi pi-angle-right" text rounded aria-label="More info" @click="visibleDrawerCast = true" />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- Reviews Section -->
        <div class="px-4 py-10 md:px-10">
          <h2 class="text-3xl font-bold mb-4">Reviews</h2>
          <div v-if="reviews.length" class="space-y-4">
            <ReviewCard v-for="(review, index) in reviews" :review="review" :key="index"></ReviewCard>
          </div>
          <p v-else class="text-gray-600 dark:text-gray-400">Encara no hi ha ressenyes.</p>
        </div>
      </div>  
    </div>
  </div>
</template>

<style scoped>
.tag {
  padding: 0.2rem 0.7rem;
  font-size: 1rem;
  font-weight: 400;
  border-radius: 9999px;
  display: inline-flex; /* Para alinear el icono y el texto */
  align-items: center;
  backdrop-filter: blur(8px);
}

.divider {
  height: 1px;
  background-color: rgb(167 139 250 / 0.5);
  margin-top: 0.5rem;
  margin-bottom: 0.5rem;
}
</style>