<script setup lang="ts">
import type { Review, FilmsAPI, Profile } from "~/types";
import ReviewCard from "~/components/ReviewCard.vue";

const supabase = useSupabaseClient();
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
							summary: "Enllaç copiat",
							detail: "L'enllaç s'ha copiat al portapapers.",
							life: 3000,
					});
					console.log("Enllaç copiat al portapapers");
			})
			.catch((err) => {
					toast.add({
							severity: "error",
							summary: "Error al copiar",
							detail: "No s'ha pogut copiar l'enllaç. Torna-ho a intentar.",
							life: 3000,
					});
					console.error("Error en copiar l'enllaç: ", err);
			});
};

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
		let summary = "Oops, alguna cosa ha anat malament";
    	let detail = "Hi ha hagut un problema en seguir l'usuari.";

		switch (error.code) {
			case 'F0001':
				summary = "Ja segueixes aquest usuari";
				detail = "Sembla que ja segueixes l'usuari.";
				break;
			case 'F0002':
				summary = "Usuari no trobat";
				detail = "No s'ha trobat l'usuari que intentes seguir.";
				break;
			case 'F0003':
				summary = "No et pots seguir a tu mateix";
				detail = "Aquesta acció no està permesa.";
				break;
			case 'F0004':
				summary = "No segueixes aquest usuari";
				detail = "Sembla que no segueixes l'usuari.";
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
						alt="Perfil" 
						class="w-44 h-44 rounded-full border-4 border-white shadow-md object-cover"
					/>
					<div class="flex justify-between items-center w-full ml-6 mt-16">
						<!-- Followers & Followings -->
						<div class="flex items-center gap-8">
							<div class="flex text-center items-center">
								<div class="text-[1.3rem] font-bold mr-[5px]">{{ profile?.followers }}</div>
								<div class="text-xl text-gray-800 dark:text-gray-300 font-light">seguidors</div>
							</div>
							<div class="flex text-center items-center">
								<div class="text-[1.4rem] font-bold mr-[5px]"> {{ profile?.following }}</div>
								<div class="text-xl text-gray-800 dark:text-gray-300 font-light">seguint</div>
							</div>
						</div>
						<!-- Follow and Share Buttons -->
						<div class="flex justify-center items-center gap-4">
							<Button 
								:label="profile?.is_following ? 'Seguint' : 'Seguir'" 
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
						<h2 class="font-bold text-2xl">Sobre mi</h2>
						<p v-if="profile?.bio" class="text-lg text-justify">
							{{ profile?.bio }}
						</p>
						<p v-else class="text-gray-500 text-lg italic">
							Aquest usuari encara no ha escrit res sobre ell mateix.
						</p>
					</div>
					<div class="flex flex-col gap-2.5">
						<h2 class="font-bold text-2xl">Pel·lícules preferides</h2>
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
							Aquest usuari encara no té pel·lícules preferides.
						</p>
					</div>
				</div>
				<div v-if="true" class="flex flex-col gap-2.5 w-[450px]">
					<h2 class="font-bold text-2xl">{{ (reviewsWithMovies.length ? reviewsWithMovies.length : 0) + ' Ressenyes' }}</h2>
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
