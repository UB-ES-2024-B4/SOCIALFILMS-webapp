<script setup lang="ts">
import type { Film, FilmsAPI } from "~/types";
import { countries, languages, genres } from "~/types";

definePageMeta({
	layout: 'navbar'
})

const supabase = useSupabaseClient()
const route = useRoute()
const query = route.params.query

const optionsSort = ref([
    { sort_by: 'Más vistas', value: 'popularity.desc' },
    { sort_by: 'Menos vistas', value: 'popularity.asc' },
    { sort_by: 'Más valoradas', value: 'vote_count.desc' },
    { sort_by: 'Menos valoradas', value: 'vote_count.asc' },
    { sort_by: 'Mejor valoradas', value: 'vote_average.desc' },
    { sort_by: 'Peor valoradas', value: 'vote_average.asc' }
])
const sortValue = ref('popularity.desc')
const { data, error } = await supabase.rpc('get_trending_movies_of_week') as {data: FilmsAPI, error: any}

const navigateToMovie = (id: number) => {
  navigateTo(`/movies/${id}`)
}

const isFiltersVisible = ref(true)
const selectedCountry = ref()
const selectedGenres = ref()
const selectedLanguage = ref()
const selectedYear = ref()
const queryCountry = ref('')
const queryGenre = ref('')
const queryLanguage = ref('')

const filteredGenres = computed(() => {
    if (queryGenre) {
        return genres.filter((genre) =>
            genre.name.toLowerCase().includes(queryGenre.value.toLowerCase())
        )
    }
    return genres
})

const filteredCountry = computed(() => {
    if (queryCountry) {
        return countries.filter((country) =>
            country.name.toLowerCase().includes(queryCountry.value.toLowerCase())
        )
    }
    return countries
})

const filteredLanguage = computed(() => {
    if (queryLanguage) {
        return languages.filter((language) =>
            language.name.toLowerCase().includes(queryLanguage.value.toLowerCase())
        )
    }
    return languages
})

</script>

<template>
  <div class="w-full h-full">
    <div class="flex my-5 ml-10 mr-4">
        <div class="flex-1 flex-col">
            <div class="flex justify-between items-center">
                <SelectButton 
                    class="shadow" 
                    v-model="sortValue" 
                    :options="optionsSort" 
                    optionLabel="sort_by" 
                    optionValue="value" />
            </div>
            <div class="flex flex-wrap my-10 mx-2 gap-10 justify-between items-center">
                <FilmCard
                    v-for="(film, index) in data.results"
                    class="cursor-pointer"
                    :film="film"
                    :trending="false"
                    :trendingNumber="index + 1"
                    @click="navigateToMovie(film.id)"
                ></FilmCard>
            </div>
        </div>
    </div>
  </div>
</template>