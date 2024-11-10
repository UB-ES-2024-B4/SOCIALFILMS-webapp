<script setup lang="ts">
import type { Film, Review, CreditsAPI, CastMember, CrewMember } from "~/types";
import { formatRuntime } from '~/utils/timeFunctions';
import ReviewCard from "~/components/ReviewCard.vue";
import CreditCard from "~/components/CreditCard.vue";

const supabase = useSupabaseClient()
const route = useRoute()

const { data: dataMovie, error: errorMovie } = await supabase.rpc('find_movie_by_id', {movie_id: route.params.id}) as {data: Film, error: any}
const { data: dataReviews, error: errorReviews } = await supabase.rpc('get_reviews', {_movie_id: route.params.id}) as {data: Review[], error: any}

const directors = ref<CrewMember[]>()
const writing = ref<CrewMember[]>()
const dataCredits = ref<CreditsAPI>()

try {
  const { data: dataCredits, error: errorCredits } = await supabase.rpc('get_credits_movie', {movie_id: route.params.id}) as {data: CreditsAPI, error: any}
  if (errorCredits) throw errorCredits
  
  directors.value = dataCredits.crew.filter(member => member.job === "Director")
  writing.value = dataCredits.crew.filter(member => member.department === "Writing")
  
} catch (e) {
  console.error(e)
}

// const reviews = dataReviews?.map(review => ({
//   ...review,
//   created_at: new Date(review.created_at)
// })) || [];

// dump data
const reviews: Review[] = [
  {
    id: 1,
    user_id: "user123",
    user: "John Doe",
    created_at: new Date("2023-11-01T10:30:00Z"),
    comment: "Absolutely loved this movie! The storyline was captivating and the characters were well-developed.",
    likes: 124,
    dislikes: 3,
    shared_count: 15,
    rating: 9,
    editable: false,
  },
  {
    id: 2,
    user_id: "user456",
    user: "Jane Smith",
    created_at: new Date("2023-11-02T15:45:00Z"),
    comment: "Great cinematography but the plot was lacking. Expected more from the director.",
    likes: 67,
    dislikes: 20,
    shared_count: 5,
    rating: 6,
    editable: true,
  },
  {
    id: 3,
    user_id: "user789",
    user: "Sam Wilson",
    created_at: new Date("2023-11-03T12:00:00Z"),
    comment: "A classic! I can watch it over and over again. Highly recommended!",
    likes: 200,
    dislikes: 1,
    shared_count: 30,
    rating: 10,
    editable: false,
  },
  {
    id: 4,
    user_id: "user101",
    user: "Alex Johnson",
    created_at: new Date("2023-11-04T18:20:00Z"),
    comment: "Not my type of movie, but I can see why others might enjoy it.",
    likes: 30,
    dislikes: 45,
    shared_count: 8,
    rating: 4,
    editable: true,
  },
  {
    id: 5,
    user_id: "user102",
    user: "Emily Brown",
    created_at: new Date("2023-11-05T21:10:00Z"),
    comment: "Well-crafted storyline and brilliant acting. One of the best movies of the year!",
    likes: 180,
    dislikes: 5,
    shared_count: 25,
    rating: 8,
    editable: false,
  },
]

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
  <Drawer v-model:visible="visibleDrawerDirector" header="Director/a" position="right">
    <CreditCard v-for="director in directors"
      :image="'https://image.tmdb.org/t/p/original'+director.profile_path" 
      :name="director.name"
      :rol-or-character="director.job">
    </CreditCard>
  </Drawer>
  <Drawer v-model:visible="visibleDrawerScript" header="Guión" position="right">
    <CreditCard v-for="writingMember in writing"
      :image="'https://image.tmdb.org/t/p/original'+writingMember.profile_path" 
      :name="writingMember.name"
      :rol-or-character="writingMember.job">
    </CreditCard>
  </Drawer>
  <Drawer v-model:visible="visibleDrawerCast" header="Reparto" position="right">
    <CreditCard v-for="castMember in dataCredits?.cast"
      :image="'https://image.tmdb.org/t/p/original'+castMember.profile_path" 
      :name="castMember.name"
      :rol-or-character="castMember.character">
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
                    <i class="pi pi-clock mr-1.5"></i>
                    {{ formatRuntime(dataMovie.runtime) }}
                  </span>
                  <span class="tag bg-gray-100/50 text-gray-600 dark:bg-gray-700/50 dark:text-gray-200">
                    <i class="pi pi-star-fill text-yellow-400 mr-1.5"></i> 
                    {{ dataMovie.vote_average.toFixed(1) }}
                  </span>
                </div>
                <div>
                  <h3 class="text-3xl font-bold mt-4 mb-1.5">Sinopsis</h3>
                  <p>{{ dataMovie.overview }}</p>
                </div>
              </div>

              <!-- Film Director, Cast, etc -->
              <div class="flex-none md:w-1/3 lg:w-1/4 space-y-14"> <!-- Ajusta el ancho según tus necesidades -->
                <div>
                  <div class="divider"></div>
                  <div class="flex justify-between">
                    <div>
                      <h4 class="text-lg font-semibold text-violet-500 dark:text-violet-400 mb-1">Director/a</h4>
                      <p class="text-gray-600 dark:text-gray-400 max-h-6">
                        {{ directors?.slice(0, 2).map(d => d.name).join(' • ') }}
                      </p>
                    </div>
                    <Button class="flex-none" icon="pi pi-angle-right" text rounded aria-label="More info" @click="visibleDrawerDirector = true"/>
                  </div>
                  
                </div>
                <div>
                  <div class="divider"></div>
                  <div class="flex justify-between">
                    <div>
                      <h4 class="text-lg font-semibold text-violet-500 dark:text-violet-400 mb-1">Guión</h4>
                      <p class="text-gray-600 dark:text-gray-400 max-h-6">
                        {{ writing?.slice(0, 2).map(w => w.name).join(' • ') }}
                      </p>
                    </div>
                    <Button class="flex-none" icon="pi pi-angle-right" text rounded aria-label="More info" @click="visibleDrawerScript = true"/>
                  </div>
                </div>
                <div>
                  <div class="divider"></div>
                  <div class="flex justify-between">
                    <div>
                      <h4 class="text-lg font-semibold text-violet-500 dark:text-violet-400 mb-1">Reparto</h4>
                      <p class="text-gray-600 dark:text-gray-400 max-h-6">
                        {{ dataCredits?.cast.slice(0, 3).map(c => c.name).join(' • ') }}
                      </p>
                    </div>
                    <Button class="flex-none" icon="pi pi-angle-right" text rounded aria-label="More info" @click="visibleDrawerCast = true" />
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