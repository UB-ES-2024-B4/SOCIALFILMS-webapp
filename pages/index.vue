<script setup lang="ts">
import type { Film, FilmsAPI } from "~/types";
import FilmCard from "~/components/FilmCard.vue";

const supabase = useSupabaseClient()

definePageMeta({
	layout: 'navbar'
})

const { data, error } = await supabase.rpc('get_trending_movies_of_week') as {data: FilmsAPI, error: any}
console.log(data)

</script>

<template>
	<div class="mt-10 w-full h-full flex justify-center">
    <div class="w-[88%]">
      <h2 class="font-extrabold text-3xl pl-16 mb-5">Trending films</h2>

      <Carousel
        :value="data.results"
        :numVisible="4"
        :numScroll="2"
        :showIndicators="false"
      >
        <template #item="slotProps">
          <FilmCard class="mt-2.5 mb-20 mx-5" :film="slotProps.data" :trending="true" :trendingNumber="slotProps.index+1"></FilmCard>
        </template>
      </Carousel>
    </div>
  </div>
</template>