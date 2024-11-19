<script setup lang="ts">
import type { Film, FilmsAPI } from "~/types";
import FilmCard from "~/components/FilmCard.vue";

const supabase = useSupabaseClient();

definePageMeta({
  layout: "navbar",
});

const { data, error } = (await supabase.rpc("get_trending_movies_of_week")) as {
  data: FilmsAPI;
  error: any;
};

const navigateToMovie = (id: number) => {
  navigateTo(`/movies/${id}`);
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
        breakpoint: '1300px',
        numVisible: 3,
        numScroll: 1
    },
    {
        breakpoint: '1000px',
        numVisible: 2,
        numScroll: 1
    },
    {
        breakpoint: '700px',
        numVisible: 1,
        numScroll: 1
    }
]);

</script>

<template>
  <div class="mt-32 w-full h-full flex justify-center">
    <div class="w-[89%]">
      <h2 class="font-extrabold text-3xl pl-16 mb-5">Trending films</h2>

      <Carousel
        :value="data.results"
        :numVisible="4"
        :numScroll="2"
        :showIndicators="false"
        :responsiveOptions="responsiveOptions"
      >
        <template #item="slotProps">
          <FilmCard
            class="mt-2.5 mb-20 mx-5 cursor-pointer"
            :film="slotProps.data"
            :trending="true"
            :trendingNumber="slotProps.index + 1"
            @click="navigateToMovie(slotProps.data.id)"
          ></FilmCard>
        </template>
      </Carousel>
    </div>
  </div>
</template>
