<script setup lang="ts">
import type { Film } from "~/types";
import FilmCard from "~/components/FilmCard.vue";
import FilmCardV2 from "~/components/FilmCard.vue";


definePageMeta({
	layout: 'empty'
})

const dummyFilm: Film = {
  poster: "https://image.tmdb.org/t/p/original/cRDJxdnRb7ikKd6fVJTrGeaL34v.jpg", // Cambia esto por una URL válida
  title: "Inception",
  overview: "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a CEO.",
  isAdult: false,
  genre: [1, 2],
  releaseDate: "2010-07-16",
  voteAverage: 8.8,
  voteCount: 230000
};

</script>

<template>
	<div class="w-screen h-screen flex items-center justify-center gap-60">
		<FilmCard :film="dummyFilm" :trending="true" :trendingNumber="2"></FilmCard>
	</div>
</template>