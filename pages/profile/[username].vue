<script setup lang="ts">
import type { Review, FilmsAPI } from "~/types";
import ReviewCard from "~/components/ReviewCard.vue";

const supabase = useSupabaseClient();
const route = useRoute();

definePageMeta({
  layout: "navbar",
});

const user = useSupabaseUser();
const following = ref(false);

const reviewsWithMovies = ref<Review[]>([]);
const isLoadingReviews = ref(false);

try {
	isLoadingReviews.value = true;

	const { data: dataReviews, error: errorReviews } = (await supabase.rpc(
		"get_reviews",
		{ _user_id: user.value?.id }
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
			{ movie_id: review.movie_id }
		);
		if (movieError) throw movieError;

		return {
			...review,
			film: movieData,
		};
	});

	reviewsWithMovies.value = await Promise.all(moviesPromises);
	console.log(reviewsWithMovies)
} catch (error) {
	console.error("Error loading reviews or movies:", error);
} finally {
	isLoadingReviews.value = false;
}

const { data, error } = (await supabase.rpc("get_trending_movies_of_week")) as {
  data: FilmsAPI;
  error: any;
};

const responsiveOptions = ref([
    {
        breakpoint: '2000px',
        numVisible: 6,
        numScroll: 2
    },
    {
        breakpoint: '1750px',
        numVisible: 5,
        numScroll: 2
    },
    {
        breakpoint: '1600px',
        numVisible: 4,
        numScroll: 2
    },
    {
        breakpoint: '1500px',
        numVisible: 2,
        numScroll: 1
    },
    {
        breakpoint: '1200px',
        numVisible: 1,
        numScroll: 1
    }
]);

const navigateToMovie = (id: number) => {
  navigateTo(`/movies/${id}`);
};

</script>

<template>
	<div class="relative w-full h-full pb-5">
    <!-- Background -->
    <div class="h-80 bg-gradient-to-r from-orange-200 via-pink-300 to-violet-400"></div>
    
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
								<div class="text-[1.3rem] font-bold mr-[5px]">1249</div>
								<div class="text-xl text-gray-800 font-light">seguidores</div>
							</div>
							<div class="flex text-center items-center">
								<div class="text-[1.4rem] font-bold mr-[5px]">586</div>
								<div class="text-xl text-gray-800 font-light">siguiendo</div>
							</div>
						</div>
						<!-- Follow and Share Buttons -->
						<div class="flex justify-center items-center gap-4">
							<Button 
								:label="following ? 'Seguiendo' : 'Seguir'" 
								:icon="following ? 'pi pi-check' : 'pi pi-user-plus'" 
								@click="following = !following" />
							<Button label="Compartir perfil" variant="outlined" icon="pi pi-send" severity="contrast" />
						</div>
					</div>
				</div>
				<div class="mt-5">
					<h1 class="font-extrabold text-3xl">Arfi Maulana</h1>
					<h3 class="text-gray-500 text-xl">{{ '@' + route.params.username }}</h3>
				</div>
			</div>
    </div>
		<!-- Content Section -->
		<div class="pt-[12rem] px-20">
			<Divider/>
			<div class="flex justify-between mt-7 w-full">
				<div class="flex flex-col gap-8 w-[calc(100%-550px)]">
					<div class="flex flex-col gap-2.5">
						<h2 class="font-bold text-2xl">Sobre mí</h2>
						<p v-if="true" class="text-lg text-justify">
							Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas imperdiet est et mauris tristique, id cursus eros interdum. Nam et dolor erat. Proin nec dolor pharetra turpis tincidunt viverra. Duis sit amet diam condimentum, dapibus magna sit amet, pharetra dui. Aenean nec lacus lorem. Cras et egestas metus. Pellentesque fermentum elit at ante tempor, nec facilisis magna eleifend. Nunc eget tempus tortor, a viverra metus. Fusce varius vulputate tortor. Donec bibendum metus ac magna molestie, id rhoncus lorem malesuada. Duis maximus viverra nisl, at finibus quam accumsan non.
						</p>
						<p v-else class="text-gray-500 text-lg italic">
							Este usuario aún no ha escrito nada sobre sí mismo.
						</p>
					</div>
					<div class="flex flex-col gap-2.5">
						<h2 class="font-bold text-2xl">Películas favoritas</h2>
						<Carousel
							v-if="true"
							class="mt-2.5"
							:value="data.results"
							:numVisible="2"
							:numScroll="1"
							:showIndicators="false"
							:responsiveOptions="responsiveOptions"
						>
							<template #item="slotProps">
								<FilmCard
									class="mt-2.5 mb-20 mx-2 cursor-pointer"
									:film="slotProps.data"
									:trending="false"
									:trendingNumber="slotProps.index + 1"
									@click="navigateToMovie(slotProps.data.id)"
								></FilmCard>
							</template>
						</Carousel>
						<p v-else class="text-gray-500 text-lg italic">
							Este usuario aún no tiene películas favoritas.
						</p>
					</div>
				</div>
				<div v-if="true" class="flex flex-col gap-2.5 w-[480px]">
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
						Este usuario aún no ha escrito ninguna reseña.
					</p>
				</div>
			</div>
		</div>
  </div>
</template>
