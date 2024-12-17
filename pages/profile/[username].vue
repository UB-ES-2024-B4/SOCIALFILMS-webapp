<script setup lang="ts">
import type { Review, FilmsAPI, Profile } from "~/types";
import ReviewCard from "~/components/ReviewCard.vue";

const supabase = useSupabaseClient();
const user = useSupabaseUser();
const route = useRoute();
const toast = useToast()

definePageMeta({
  layout: "navbar",
});

const profile = ref<Profile>();

try {
	const { data: dataProfile, error: errorProfile } = (await supabase.rpc(
		"get_profile_by_username",
		{ _username: route.params.username }
	)) as { data: Profile; error: any };

	if (errorProfile) throw errorProfile;

	profile.value = dataProfile;

} catch (error) {
	console.error("Error loading profile:", error);
}

const reviewsWithMovies = ref<Review[]>([]);
const isLoadingReviews = ref(false);

try {
	isLoadingReviews.value = true;

	const { data: dataReviews, error: errorReviews } = (await supabase.rpc(
		"get_reviews",
		{ _user_id: profile?.value.id }
	)) as { data: Review[]; error: any };

	if (errorReviews) throw errorReviews;

	const reviews =
		dataReviews?.map((review) => ({
			...review,
			created_at: new Date(review.created_at),
		})) || [];

	const moviesPromises = reviews.map(async (review) => {
		const { data: movieData, error: movieError } = await supabase.rpc(
			"find_movie_by_id",
			{ movie_id: review.movie_id, lang: 'ca-ES' }
		);
		if (movieError) throw movieError;

		return {
			...review,
			film: movieData,
		};
	});

	reviewsWithMovies.value = await Promise.all(moviesPromises);
} catch (error) {
	console.error("Error loading reviews or movies:", error);
} finally {
	isLoadingReviews.value = false;
}


const deleteReview = (review_id: string) => {
  const index = reviewsWithMovies.value.findIndex((review) => review.id === review_id);
  if (index !== -1) {
    reviewsWithMovies.value.splice(index, 1);
  }
};

const { data, error } = (await supabase.rpc("get_trending_movies_of_week")) as {
  data: FilmsAPI;
  error: any;
};

const responsiveOptions = ref([
    {
        breakpoint: '2500px',
        numVisible: 6,
        numScroll: 2
    },
    {
        breakpoint: '2250px',
        numVisible: 5,
        numScroll: 2
    },
    {
        breakpoint: '2000px',
        numVisible: 4,
        numScroll: 2
    },
	{
        breakpoint: '1750px',
        numVisible: 3,
        numScroll: 1
    },
    {
        breakpoint: '1500px',
        numVisible: 2,
        numScroll: 1
    },
    {
        breakpoint: '1250px',
        numVisible: 1,
        numScroll: 1
    }
]);

const navigateToMovie = (id: number) => {
  navigateTo(`/movies/${id}`);
};

const shareProfile = () => {
	const currentURL = window.location.href;
	navigator.clipboard.writeText(currentURL)
			.then(() => {
					toast.add({
							severity: "success",
							summary: "Enlace copiado",
							detail: "El enlace se ha copiado al portapapeles.",
							life: 3000,
					});
					console.log("Enlace copiado al portapapeles");
			})
			.catch((err) => {
					toast.add({
							severity: "error",
							summary: "Error al copiar",
							detail: "No se pudo copiar el enlace. Intenta nuevamente.",
							life: 3000,
					});
					console.error("Error al copiar el enlace: ", err);
			});
};

const { data: favoriteMovie, error: errorFavoriteMovies } = await supabase.rpc('get_user_movies', {
  _relation_type: 'favorite'
}) as { data: Film[]; error: any };

// Refs y propiedades computadas
const favorite = ref<Film[]>(favoriteMovie);

const favoriteMovies = computed(() => {
  return favorite.value.map((movie, index) => ({
    ...movie,
    order: index,
  }));
});

const snackbarVisible = ref(false);
const removedMovie = ref<Film | null>(null);
const timeoutId = ref<number | null>(null);
const movie_remove_id = ref<string | null>(null);

const snackbarMessage = computed(() =>
  removedMovie.value ? `${removedMovie.value.title} s'ha tret de favorits` : ''
);

function removeFilm(movie_id: string) {

  movie_remove_id.value = movie_id;
  removedMovie.value = favoriteMovies.value.find(m => m.id === movie_id) || null;
  
  if (removedMovie.value) {
    favorite.value = favorite.value.filter(m => m.id !== movie_id);
    snackbarVisible.value = true;

    timeoutId.value = setTimeout(() => {
      snackbarVisible.value = false;
      removedMovie.value = null;
      movie_remove_id.value = null;
    }, 4000);
  }
}

async function restoreFilm() {

  const { error } = await supabase.rpc('add_user_movie', {
    _movie_id: movie_remove_id.value,
    _relation_type: 'favorite',
  });

  if (removedMovie.value) {
    favorite.value.splice(removedMovie.value?.order, 0, removedMovie.value);
  }

  snackbarVisible.value = false;
  removedMovie.value = null;
  movie_remove_id.value = null;

  if (timeoutId.value) {
    clearTimeout(timeoutId.value);
    timeoutId.value = null;
  }
}


const isProcessingFollow = ref(false);
const handleFollow = async () => {
	if (isProcessingFollow.value) return;
  isProcessingFollow.value = true;

	try {
		if (profile.value?.is_following) {
			const { error } = (await supabase.rpc(
				"unfollow_user",
				{ _following_username: route.params.username }
			))
			if (error) throw error;
		}
		else {
			const { error } = (await supabase.rpc(
				"follow_user",
				{ _following_username: route.params.username }
			))
			if (error) throw error;
		}

		if (profile.value?.is_following) {
			profile.value.followers--;
			profile.value.is_following = false;
		} else {
			profile.value.followers++;
			profile.value.is_following = true;
		}
	} catch (error) {
		console.error(error);
		let summary = "Oops, algo salió mal";
    let detail = "Hubo un problema al realizar seguir al usuario.";

		switch (error.code) {
			case 'F0001':
				summary = "Ya estás siguiendo a este usuario";
				detail = "Parece que ya sigues al usuario.";
				break;
			case 'F0002':
				summary = "Usuario no encontrado";
				detail = "No se encontró el usuario que intentas seguir.";
				break;
			case 'F0003':
				summary = "No puedes seguirte a ti mismo";
				detail = "Esta acción no está permitida.";
				break;
			case 'F0004':
				summary = "No estás siguiendo a este usuario";
				detail = "Parece que no sigues al usuario.";
				break;
		}
		toast.add({
			severity: "error",
			summary,
			detail,
			life: 3000,
		});
	} finally {
    isProcessingFollow.value = false;
  }
}

</script>

<template>
	<transition name="scale">
      <div v-if="snackbarVisible" id="snackbar" class="flex items-center justify-between backdrop-blur bg-neutral-600/70  rounded-lg z-50">
        <div class="flex items-center gap-4">
			<span class="text-white text-md font-medium">
          {{ snackbarMessage }}
        </span>
        <button
			@click="restoreFilm"
			class="flex items-center justify-center px-4 py-2 bg-transparent border border-white text-white rounded-full hover:bg-white hover:text-black transition-all"
		>
			<i class="pi pi-replay mr-2"></i>
			Desfer
		</button>
		</div>
      </div>
    </transition>

	<div class="relative w-full h-full pb-5">
    <!-- Background -->
		<div class="h-80 bg-gradient-to-b from-pink-400/90 to-violet-400 dark:from-pink-700 dark:to-violet-800"></div>
  	<!-- <div class="absolute inset-0 bg-gradient-to-b from-neutral-800/40 via-neutral-800/5 via-25% to-neutral-800/0"></div> -->
    
    <!-- Profile -->
    <div class="absolute top-60 inset-x-20 transform">
			<div class="flex flex-col">
				<div class="flex">
					<!-- Avatar -->
					<img 
						src="https://a.storyblok.com/f/191576/1200x800/a3640fdc4c/profile_picture_maker_before.webp" 
						alt="Profile" 
						class="w-44 h-44 rounded-full border-4 border-white shadow-md object-cover"
					/>
					<div class="flex justify-between items-center w-full ml-6 mt-16">
						<!-- Followers & Followings -->
						<div class="flex items-center gap-8">
							<div class="flex text-center items-center">
								<div class="text-[1.3rem] font-bold mr-[5px]">{{ profile?.followers }}</div>
								<div class="text-xl text-gray-800 dark:text-gray-300 font-light">seguidores</div>
							</div>
							<div class="flex text-center items-center">
								<div class="text-[1.4rem] font-bold mr-[5px]"> {{ profile?.following }}</div>
								<div class="text-xl text-gray-800 dark:text-gray-300 font-light">siguiendo</div>
							</div>
						</div>
						<!-- Follow and Share Buttons -->
						<div class="flex justify-center items-center gap-4">
							<Button 
								:label="profile?.is_following ? 'Siguiendo' : 'Seguir'" 
								:icon="profile?.is_following ? 'pi pi-check' : 'pi pi-user-plus'" 
								:loading="isProcessingFollow"
								@click="handleFollow" />
							<Button 
								label="Compartir perfil"
								variant="outlined"
								icon="pi pi-send"
								severity="contrast" 
								@click="shareProfile" />
						</div>
					</div>
				</div>
				<div class="mt-5">
					<h1 class="font-extrabold text-3xl">{{ profile?.real_name + ' ' + profile?.last_name }}</h1>
					<h3 class="text-gray-500 text-xl">{{ '@' + profile?.username }}</h3>
				</div>
			</div>
    </div>
		<!-- Content Section -->
		<div class="pt-[12rem] px-20">
			<Divider/>
			<div class="flex justify-between mt-7 w-full">
				<div class="flex flex-col gap-8 w-[calc(100%-520px)]">
					<div class="flex flex-col gap-2.5">
						<h2 class="font-bold text-2xl">Sobre mí</h2>
						<p v-if="profile?.bio" class="text-lg text-justify">
							{{ profile?.bio }}
						</p>
						<p v-else class="text-gray-500 text-lg italic">
							Este usuario aún no ha escrito nada sobre sí mismo.
						</p>
					</div>
					<div class="flex flex-col gap-2.5">
						<h2 class="font-bold text-2xl">Películas favoritas</h2>
						<Carousel
							v-if="favoriteMovies"
							class="mt-2.5"
							:value="favoriteMovies"
							:numVisible="3"
							:numScroll="1"
							:showIndicators="false"
							:responsiveOptions="responsiveOptions"
						>
							<template #item="slotProps">
								<FilmCard
									class="mt-2.5 mb-20 mx-2 cursor-pointer"
									:key="slotProps.data.id"
									:film="slotProps.data"
									:trending="false"
									:trendingNumber="slotProps.index + 1"
									:favorite="true"
                					:watch_later="false"
									@click="navigateToMovie(slotProps.data.id)"
									@remove-film="removeFilm"
								></FilmCard>
							</template>
						</Carousel>
						<p v-else class="text-gray-500 text-lg italic">
							Aquest usuari encara no té pel·lícules preferides.
						</p>
					</div>
				</div>
				<div v-if="true" class="flex flex-col gap-2.5 w-[450px]">
					<h2 class="font-bold text-2xl">{{ (reviewsWithMovies.length ? reviewsWithMovies.length : 0) + ' Reseñas' }}</h2>
					<div v-if="reviewsWithMovies.length" class="space-y-4 mt-1">
            <ReviewCard
							v-for="(review, index) in reviewsWithMovies"
							:review="review"
							:key="index"
							:film="review.film"
							:showFilm="true"
            ></ReviewCard>
          </div>
					<p v-else class="text-gray-500 text-lg italic">
						Aquest usuari encara no ha escrit cap ressenya.
					</p>
				</div>
			</div>
		</div>
  </div>
</template>

<style>
/* Transiciones para mostrar y ocultar el snackbar con animación de escala */
.scale-enter-active,
.scale-leave-active {
  transition: opacity 0.5s, transform 0.5s; /* Animación de opacidad y escala */
}

.scale-enter-from,
.scale-leave-to {
  opacity: 0;
  transform: scale(0.5); /* Hacerlo pequeño al desaparecer */
}

.scale-enter-to,
.scale-leave-from {
  opacity: 1;
  transform: scale(1); /* Hacerlo grande al aparecer */
}

#snackbar {
  border-radius: 36px;
  width: wrap;
  padding: 16px 24px;
  position: fixed;
  left: 50%; /* Centra el snackbar horizontalmente */
  bottom: 30px; /* Posición 30px desde el fondo */
  transform: translateX(-50%); /* Ajusta para que esté centrado */
}
</style>