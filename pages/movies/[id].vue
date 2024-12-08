<script setup lang="ts">
import type { Film, Review, CreditsAPI, CastMember, CrewMember } from "~/types";
import { formatRuntime } from "~/utils/timeFunctions";
import ReviewCard from "~/components/ReviewCard.vue";
import CreditCard from "~/components/CreditCard.vue";
import Button from "primevue/button";

definePageMeta({
  layout: "navbar",
});

const supabase = useSupabaseClient();
const user = useSupabaseUser();
const route = useRoute();
const toast = useToast();

const { data: dataMovie, error: errorMovie } = (await supabase.rpc(
  "find_movie_by_id",
  { movie_id: route.params.id }
)) as { data: Film; error: any };

const { data: dataReviews, error: errorReviews } = (await supabase.rpc(
  "get_reviews",
  { _movie_id: route.params.id }
)) as { data: Review[]; error: any };

const searchQuery = ref("")

const reviews = reactive<Review[]>(
  dataReviews?.map((review) => ({
    ...review,
    created_at: new Date(review.created_at),
  })) || []);

const filteredReviews = computed(() => {
  if (!searchQuery.value) return reviews;

  return reviews.filter((review) => {
    const commentMatch = review.comment
      ?.toLowerCase()
      .includes(searchQuery.value.toLowerCase());
    const userMatch = review.user
      ?.toLowerCase()
      .includes(searchQuery.value.toLowerCase());
    return userMatch || commentMatch;
  });
});

const directors = ref<CrewMember[]>();
const writing = ref<CrewMember[]>();
const dataCredits = ref<CreditsAPI>();

const checked = ref(false);
const visible = ref(false)
const rating = ref(1)
const comment = ref('')
const numCharacters = computed(() => {
  return comment.value.length;
});

const selectRating = (star: number) => {
  rating.value = star;
};

const submitReview = async () => {
  const user_id = user.value?.id

  if (!user_id) {
    toast.add({ severity: "error", summary: "Error", detail: "Has d'estar registrat per deixar una ressenya.", life: 3000 });
    visible.value = false;
    return;
  }

    try {
      const { data: reviewData, error: reviewError } = await supabase.rpc('create_review', {_movie_id: dataMovie.id, _rating: rating.value, _comment: comment.value, _spoilers: checked.value})
      console.log(reviewData)
      if (!reviewError) {
          toast.add({ severity: 'success', summary: 'Ressenya pujada', detail: 'La teva ressenya s\'ha publicat amb èxit.', life: 3000 });
          const new_review: Review = {
            id: reviewData,
            user_id: user_id || '', 
            user: user.value?.user_metadata.username,
            created_at: new Date(),
            comment: comment.value || '',
            likes: 0,
            dislikes: 0,
            shared_count: 0,
            rating: rating.value,
            editable: true,
            spoilers: checked.value
          }
        
          reviews.push(new_review)
          visible.value = false;
      } else {
        if (reviewError.code === '23505') { // Código de error específico para conflicto de recurso en Supabase
          toast.add({ severity: 'error', summary: 'Conflicte detectat', detail: 'Ja has deixat una ressenya per aquesta pel·lícula. No es permeten duplicats.', life: 3000})
        } else {
          toast.add({ severity: 'error', summary: 'Error al publicar', detail: 'Actualitza la teva valoració o escriu un comentari vàlid abans d\'intentar-ho de nou.', life: 3000 })
        }
      }
    } catch (e) {
      console.error(e)
    }
}


try {
  const { data, error: errorCredits } = (await supabase.rpc(
    "get_credits_movie",
    { movie_id: route.params.id }
  )) as { data: CreditsAPI; error: any };
  if (errorCredits) throw errorCredits;

  dataCredits.value = data;
  directors.value = data.crew.filter((member) => member.job === "Director");
  writing.value = data.crew.filter((member) => member.department === "Writing");
} catch (e) {
  console.error(e);
}

const posterTranslateY = ref(-112);
const scrollThreshold = 200;

const handleScroll = () => {
  const scrollPosition = window.scrollY;

  const newTranslateY = -112 + Math.min(scrollPosition, 100);
  posterTranslateY.value = Math.max(newTranslateY, -112);

  if (scrollPosition > scrollThreshold) {
    const adjustedScroll = scrollPosition - scrollThreshold;
    const newTranslateY = -112 + Math.min(adjustedScroll, 100);
    posterTranslateY.value = Math.max(newTranslateY, -112);
  } else {
    posterTranslateY.value = -112;
  }
};

const deleteReview = (review_id: string) => {
  const index = reviews.findIndex((review) => review.id === review_id);
  if (index !== -1) {
    reviews.splice(index, 1);
  }
};

onMounted(() => {
  window.addEventListener("scroll", handleScroll);
});

onBeforeUnmount(() => {
  window.removeEventListener("scroll", handleScroll);
});

const visibleDrawerDirector = ref(false);
const visibleDrawerScript = ref(false);
const visibleDrawerCast = ref(false);
</script>

<template>
  <Toast/>
  <Dialog v-model:visible="visible" modal header="Nova ressenya">
    <div class="flex flex-col mt-4 space-y-4">
      <div class="flex space-x-8">
        <div class="flex flex-col">
          <h2
            class="font-bold whitespace-nowrap text-2xl text-gray-800 dark:text-gray-100 leading-tight"
          >
            {{ dataMovie.title }}
          </h2>

          <div class="flex items-center space-x-1.5 mt-3">
            <span
              :class="
                dataMovie.adult
                  ? 'tag bg-red-500/20 border border-red-500 whitespace-nowrap text-red-500 dark:bg-red-500/20 dark:border-red-400 dark:text-red-400'
                  : 'tag bg-green-500/20 border border-green-500 whitespace-nowrap text-green-500 dark:bg-green-500/20 dark:border-green-400 dark:text-green-400'
              "
            >
              {{ dataMovie.adult ? "R" : "PG-13" }}
            </span>
            <span
              class="tag border border-gray-400 whitespace-nowrap text-gray-800 dark:text-gray-200"
            >
              <i class="pi pi-calendar mr-1.5 text-[0.8rem]"></i>
              {{ dataMovie.release_date }}
            </span>
            <span
              class="tag border border-gray-400 text-gray-800 dark:text-gray-200"
            >
              <i
                class="pi pi-star-fill text-yellow-400 dark:text-yellow-400 mr-1.5 text-[0.8rem]"
              ></i>
              {{ dataMovie.vote_average.toFixed(1) }}
            </span>
          </div>

          <h3 class="mt-auto">Qualifica del 1 al 10 ({{ rating }})</h3>
          <div class="flex mb-4 items-center space-x-2">
            <span
              v-for="star in 10"
              :key="star"
              @mouseover="selectRating(star)"
              class="cursor-pointer text-2xl transition-transform duration-200 transform"
              :class="{ 'scale-125': star === rating }"
            >
              <i
                :class="[
                  'pi',
                  star <= rating ? 'pi-star-fill text-yellow-400' : 'pi-star',
                ]"
              ></i>
            </span>
          </div>
        </div>
        <img
          :src="'https://image.tmdb.org/t/p/original' + dataMovie.poster_path"
          :alt="`${dataMovie.title} poster`"
          class="w-2/3 h-72 object-cover rounded-lg"
        />
      </div>
      <div class="relative mb-4">
        <Textarea
          autoResize
          v-model="comment"
          rows="4"
          cols="20"
          maxlength="255"
          placeholder="Escriu el teu comentari..."
          class="mb-4 w-full"
        />
        <span class="absolute right-2 bottom-[-0.1rem] text-gray-500 text-sm">
          {{ numCharacters }} / 255
        </span>
      </div>

        <div class="flex justify-between items-center">
          <Button label="Cancel·lar" severity="secondary" @click="visible=false" />
          <div class="flex items-center gap-7">
            <div class="relative flex items-center justify-center">
              <span class="absolute top-[-1.3rem] text-sm">Spoiler</span>
              <ToggleSwitch v-model="checked"/>
            </div>
            <Button label="Publicar" @click="submitReview" />
          </div>
        </div>
    </div>
  </Dialog>

  <Drawer
    v-model:visible="visibleDrawerDirector"
    header="Director/a"
    position="right"
    class="!w-full md:!w-80 lg:!w-[25rem]"
  >
    <CreditCard
      v-for="director in directors"
      :image="director.profile_path"
      :name="director.name"
      :rol-or-character="director.job"
    >
    </CreditCard>
  </Drawer>
  <Drawer
    v-model:visible="visibleDrawerScript"
    header="Guió"
    position="right"
    class="!w-full md:!w-80 lg:!w-[25rem]"
  >
    <CreditCard
      v-for="writingMember in writing"
      :image="writingMember.profile_path"
      :name="writingMember.name"
      :rol-or-character="writingMember.job"
    >
    </CreditCard>
  </Drawer>
  <Drawer
    v-model:visible="visibleDrawerCast"
    header="Figurants"
    position="right"
    class="!w-full md:!w-80 lg:!w-[25rem]"
  >
    <CreditCard
      v-for="castMember in dataCredits?.cast"
      :image="castMember.profile_path"
      :name="castMember.name"
      :rol-or-character="castMember.character"
    >
    </CreditCard>
  </Drawer>

  <div class="w-full min-h-screen">
    <div
      class="fixed w-full h-full bg-cover bg-center bg-fixed transition-opacity"
      :style="{
        backgroundImage: `url(${
          'https://image.tmdb.org/t/p/original' + dataMovie.backdrop_path
        })`,
      }"
    ></div>

    <div class="relative z-10 pt-[28rem]">
      <div class="backdrop-blur-xl bg-white/70 dark:bg-black/50">
        <div class="flex flex-col md:flex-row px-4 pt-4 md:px-10 md:pt-10">
          <img
            :src="'https://image.tmdb.org/t/p/original' + dataMovie.poster_path"
            :alt="`${dataMovie.title} poster`"
            class="w-48 md:w-80 rounded-lg shadow-xl md:mr-10 transition-transform duration-500 dark:shadow-gray-300/15"
            :style="{ transform: `translateY(${posterTranslateY}px)` }"
          />
          <div class="flex flex-col">
            <h1 class="text-7xl font-extrabold mb-4">{{ dataMovie.title }}</h1>
            <div class="flex flex-col flex-1 mt-4 md:flex-row md:mt-0 gap-14">
              <div class="flex-1 flex flex-col space-y-3">
                <h2 class="text-lg text-gray-600 dark:text-gray-400">
                  {{ dataMovie.genres?.map((genre) => genre.name).join(" • ") }}
                </h2>

                <div class="flex items-center space-x-2 mt-4">
                  <span
                    :class="
                      dataMovie.adult
                        ? 'tag bg-red-500/20 border border-red-500 text-red-500 dark:border-red-400 dark:text-red-400'
                        : 'tag bg-green-500/20 border border-green-500 text-green-500 dark:border-green-400 dark:text-green-400'
                    "
                  >
                    {{ dataMovie.adult ? "R" : "PG-13" }}
                  </span>
                  <span
                    class="tag bg-gray-100/50 text-gray-600 dark:bg-gray-700/50 dark:text-gray-200"
                  >
                    <i class="pi pi-calendar mr-1.5"></i>
                    {{ dataMovie.release_date }}
                  </span>
                  <span
                    class="tag bg-gray-100/50 text-gray-600 dark:bg-gray-700/50 dark:text-gray-200"
                  >
                    <i class="pi pi-clock mr-1.5"></i>
                    {{ formatRuntime(dataMovie.runtime) }}
                  </span>
                  <span
                    class="tag bg-gray-100/50 text-gray-600 dark:bg-gray-700/50 dark:text-gray-200"
                  >
                    <i class="pi pi-star-fill text-yellow-400 mr-1.5"></i>
                    {{ dataMovie.vote_average.toFixed(1) }}
                  </span>
                </div>
                <div>
                  <h3 class="text-3xl font-bold mt-4 mb-1.5">Sinopsi</h3>
                  <p>{{ dataMovie.overview }}</p>
                </div>
              </div>
              <div class="flex-none md:w-1/3 lg:w-1/4 space-y-14">
                <div>
                  <div class="divider"></div>
                  <div class="flex justify-between">
                    <div>
                      <h4
                        class="text-lg font-semibold text-violet-500 dark:text-violet-400 mb-1"
                      >
                        Director/a
                      </h4>
                      <p class="text-gray-600 dark:text-gray-400 max-h-6">
                        {{
                          directors
                            ?.slice(0, 2)
                            .map((d) => d.name)
                            .join(" • ")
                        }}
                      </p>
                    </div>
                    <Button
                      class="flex-none"
                      icon="pi pi-angle-right"
                      text
                      rounded
                      aria-label="More info"
                      @click="visibleDrawerDirector = true"
                    />
                  </div>
                </div>
                <div>
                  <div class="divider"></div>
                  <div class="flex justify-between">
                    <div>
                      <h4
                        class="text-lg font-semibold text-violet-500 dark:text-violet-400 mb-1"
                      >
                        Guió
                      </h4>
                      <p class="text-gray-600 dark:text-gray-400 max-h-6">
                        {{
                          writing
                            ?.slice(0, 2)
                            .map((w) => w.name)
                            .join(" • ")
                        }}
                      </p>
                    </div>
                    <Button
                      class="flex-none"
                      icon="pi pi-angle-right"
                      text
                      rounded
                      aria-label="More info"
                      @click="visibleDrawerScript = true"
                    />
                  </div>
                </div>
                <div>
                  <div class="divider"></div>
                  <div class="flex justify-between">
                    <div>
                      <h4
                        class="text-lg font-semibold text-violet-500 dark:text-violet-400 mb-1"
                      >
                      Figurants
                      </h4>
                      <p class="text-gray-600 dark:text-gray-400 max-h-6">
                        {{
                          dataCredits?.cast
                            .slice(0, 3)
                            .map((c) => c.name)
                            .join(" • ")
                        }}
                      </p>
                    </div>
                    <Button
                      class="flex-none"
                      icon="pi pi-angle-right"
                      text
                      rounded
                      aria-label="Mes info"
                      @click="visibleDrawerCast = true"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="px-4 py-10 md:px-10">
          <div class="flex items-center justify-between gap-8 mb-4">
            <div class="flex items-center gap-8">
              <h2 class="text-3xl font-bold">Ressenyes</h2>
              <Button
                v-if="user"
                label="Afegir ressenya"
                variant="outlined"
                @click="visible = true"
              />
            </div>

            <div class="search-container relative">
              <span
                class="absolute inset-y-0 left-4 flex items-center text-violet-900"
              >
                <i class="pi pi-search"></i>
              </span>
              <input
                type="text"
                v-model="searchQuery"
                placeholder="Buscar ressenya"
                class="absolut pl-12 pr-2 py-2 rounded-full bg-violet-500/40 placeholder-violet-900 focus:outline-none focus:ring-1 focus:ring-violet-500/80 transition-shadow duration-300"
              />
            </div>
          </div>
          <div v-if="filteredReviews.length" class="space-y-4">
            <ReviewCard
              v-for="review in filteredReviews"
              :review="review"
              :key="review.id"
              :film="dataMovie"
              @delete-review="deleteReview"
            ></ReviewCard>
          </div>
          <p v-else-if="!reviews.length" class="text-gray-600 dark:text-gray-400">
            Encara no hi ha ressenyes.
          </p>
          <p v-else class="text-gray-600 dark:text-gray-400">
            No s'han trobat resultats.
          </p>
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
  display: inline-flex;
  align-items: center;
  backdrop-filter: blur(8px);
}

.divider {
  height: 1px;
  background-color: rgb(167 139 250 / 0.5);
  margin-top: 0.5rem;
  margin-bottom: 0.5rem;
}

input[type="text"] {
  width: 165px;
  transition: width 0.4s ease-in-out;
}

input[type="text"]:focus {
  width: 300px; /* Define el ancho al expandirse */
}
</style>