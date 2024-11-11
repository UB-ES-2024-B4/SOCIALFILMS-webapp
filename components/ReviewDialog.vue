<script setup lang="ts">
import 'primeicons/primeicons.css'
import type { Film } from '~/types';
import { useToast } from "primevue/usetoast";

const supabase = useSupabaseClient()
const user = useSupabaseUser()

const props = defineProps({
  movie_id: {
    type: Number,
    required: true
  },
  edit: {
    type: Boolean,
    required: true,
  },
  comment: {
    type: String,
    required: false,
  },
  visible: {
    type: Boolean,
    required: true,
  }
});

const film = ref<Film | null>(null);

const toast = useToast();

const rating = ref(1);
const comment = ref(' ');
const numCharacters = computed(() => {
    return comment.value.length;
});

const loadMovieData = async () => {
    const { data, error } = await supabase.rpc('find_movie_by_id', { movie_id: props.movie_id }) as { data: Film | null, error: any };
    film.value = data;

    if (error) {
      toast.add({ severity: 'error', summary: 'Error', detail: 'No se pudo cargar la película.', life: 3000 });
    }
}

const selectRating = (star: number) => {
    rating.value = star;
};

// Submit review
const submitReview = async () => {
    const user_id = user.value?.id
   
    if (!user_id) {
    toast.add({ severity: 'error', summary: 'Error', detail: 'Debes estar logueado para dejar una reseña.', life: 3000 })
    return;
    }
    console.log(user_id, props.movie_id, rating.value, comment.value)

    try {
        const { data: reviewData, error: reviewError } = await supabase.rpc('create_review', { _user_id: user_id, _movie_id: props.movie_id, _rating: rating.value, _comment: comment.value })
        if (!reviewError) {
            console.log('Review created with ID:', reviewData?.review_id);
            toast.add({ severity: 'success', summary: 'Éxito', detail: 'La review ha sido publicada correctamente.', life: 3000 });
        } else {
            toast.add({ severity: 'error', summary: 'Error', detail: 'Por favor, selecciona una calificación y escribe un comentario.', life: 3000 })
        }
    } catch (err) {
        console.error('Fetch error:', err);
    }
};

onMounted(() => {
  loadMovieData();
});

</script>   

<template>
    <div>
        <Toast />
        <Dialog :visible="visible" modal header="Nueva reseña:">
            <div class="flex flex-col mt-4 space-y-4">
                <div class="flex space-x-8">
                    <div class="flex flex-col">
                        <h2 class="font-bold whitespace-nowrap text-2xl text-gray-800 leading-tight">{{film.title}}</h2>

                        <div class="flex items-center space-x-1.5 mt-3">
                            <span :class="film.adult ? 
                            'tag bg-red-500/20 border border-red-500 whitespace-nowrap text-red-500 dark:bg-red-500/20 dark:border-red-400 dark:text-red-400' :
                            'tag bg-green-500/20 border border-green-500 whitespace-nowrap text-green-500 dark:bg-green-500/20 dark:border-green-400 dark:text-green-400'">
                            {{ film.adult ? 'R' : 'PG-13' }}
                            </span>
                            <span class="tag border border-gray-400 whitespace-nowrap text-gray-800 dark:text-gray-200">
                            <i class="pi pi-calendar mr-1.5 text-[0.8rem]"></i>
                            {{ film.release_date }}
                            </span>
                            <span class="tag border border-gray-400 text-gray-800 dark:text-gray-200">
                            <i class="pi pi-star-fill text-yellow-400 dark:text-yellow-400 mr-1.5 text-[0.8rem]"></i> 
                            {{ film.vote_average.toFixed(1) }}
                            </span>
                        </div>

                        <h3 class="mt-auto ">Califica del 1 al 10 ({{ rating }})</h3>
                        <div class="flex mb-4 items-center space-x-2">
                            <span
                                v-for="star in 10"
                                :key="star"
                                @mouseover ="selectRating(star)" 
                                class="cursor-pointer text-2xl transition-transform duration-200 transform"
                                :class="{'scale-125': star === rating}"
                            >
                                <i :class="['pi', star <= (rating) ? 'pi-star-fill text-yellow-400' : 'pi-star']"></i>
                            </span>
                        </div>
                    </div>
                    <img
                        :src="'https://image.tmdb.org/t/p/original'+film.poster_path"
                        :alt="`${film.title} poster`"
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
                        placeholder="Escribe tu comentario..."
                        class="mb-4 w-full"
                    />
                    <span class="absolute right-2 bottom-[-0.1rem] text-gray-500 text-sm">
                        {{ numCharacters }} / 255
                    </span>
                </div>

                <div v-if="user" class="flex justify-between">
                    <Button label="Publicar" severity="success" @click="submitReview" />
                </div>
            </div>
         </Dialog>
    </div>
</template>

<style scoped>
.tag {
  padding: 0.2rem 0.5rem;
  font-size: 0.8rem;
  font-weight: 400;
  border-radius: 9999px;
  display: inline-flex; /* Para alinear el icono y el texto */
  align-items: center;
  backdrop-filter: blur(8px);
}
</style>