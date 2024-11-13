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

const filmsQueryOriginal = ref<FilmsAPI>({ results: [] })
const filmsQueryFiltered = ref<Film[]>([])
try {
    const { data, error } = await supabase.rpc('search_movie_by_name', {movie_name: query}) as {data: FilmsAPI, error: any}
    if (error) throw error
    
    filmsQueryOriginal.value = data
    filmsQueryFiltered.value = data.results
    console.log(data)
} catch (e) {
    console.error(e)
}

const navigateToMovie = (id: number) => {
  navigateTo(`/movies/${id}`)
}

const isFiltersVisible = ref(true)
const selectedCountry = ref('')
const selectedGenres = ref([])
const selectedLanguage = ref('')
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

watch([filmsQueryOriginal, selectedGenres, selectedYear, selectedCountry, selectedLanguage, sortValue], async () => {
    let filtered = [...filmsQueryOriginal.value?.results]

    if (selectedGenres.value.length > 0) {
        filtered = filtered.filter(film =>
            film.genre_ids?.some(genreId => selectedGenres.value.includes(genreId))
        )
    }
    
    if (selectedYear.value) {
        filtered = filtered.filter(film => new Date(film.release_date).getFullYear() === new Date(selectedYear.value).getFullYear())
    }

    console.log(selectedCountry.value || selectedLanguage.value)

    if (selectedCountry.value || selectedLanguage.value) {
        const detailedFilms = await Promise.all(filtered.map(async (film) => {
            const { data: fullFilm, error } = await supabase.rpc('find_movie_by_id', {movie_id: film.id}) as {data: Film, error: any}
            return {
                ...film,
                spoken_languages: fullFilm.spoken_languages,
                production_countries: fullFilm.production_countries
            }
        }))
        filtered = detailedFilms
        console.log(filtered)
        console.log(selectedCountry.value)

        if (selectedCountry.value) {
            filtered = filtered.filter(film => film.production_countries?.some(country => country.iso_3166_1 === selectedCountry.value))
        }
        console.log(filtered)
        if (selectedLanguage.value) {
            filtered = filtered.filter(film => film.spoken_languages?.some(language => language.iso_639_1 === selectedLanguage.value))
        }
    }

    filtered = filtered.sort((a, b) => {
        const [field, order] = sortValue.value.split('.')
        const modifier = order === 'desc' ? -1 : 1
        return ((a[field as keyof Film] ?? 0) < (b[field as keyof Film] ?? 0) ? -1 : 1) * modifier
    })

    filmsQueryFiltered.value = filtered
})

</script>

<template>
  <div class="w-full h-full">
    <div class="flex my-5 ml-10 mr-4">
        <div class="flex-none">
            <div v-if="isFiltersVisible" class="w-72 mr-10 rounded-md shadow">
                <Accordion :value="['0','1','2','3']" multiple>
                    <AccordionPanel value="0">
                        <AccordionHeader>Gèneres</AccordionHeader>
                        <AccordionContent>
                            <div class="flex flex-wrap justify-center gap-4">
                                <FloatLabel variant="on">
                                    <IconField>
                                        <InputText class="w-60" size="small" v-model="queryGenre" />
                                        <InputIcon class="pi pi-search" />
                                    </IconField>
                                    <label for="on_label">Busca un gènere</label>
                                </FloatLabel>
                                <div v-for="genre of filteredGenres" :key="genre.code" class="flex items-center gap-2">
                                    <Checkbox v-model="selectedGenres" name="genre" :value="genre.code" />
                                    <label :for="genre.name">{{ genre.name }}</label>
                                </div>
                            </div>
                        </AccordionContent>
                    </AccordionPanel>
                    <AccordionPanel value="1">
                        <AccordionHeader>País</AccordionHeader>
                        <AccordionContent>
                            <div class="flex flex-wrap justify-center gap-4">
                                <FloatLabel variant="on">
                                    <IconField>
                                        <InputText class="w-60" size="small" v-model="queryCountry" />
                                        <InputIcon class="pi pi-search" />
                                    </IconField>
                                    <label for="on_label">Busca un país</label>
                                </FloatLabel>
                                <div v-for="country in filteredCountry" :key="country.code" class="flex items-center gap-2">
                                    <RadioButton v-model="selectedCountry" :inputId="country.code" name="country" :value="country.code" />
                                    <label :for="country.code">{{ country.name }}</label>
                                </div>
                            </div>
                        </AccordionContent>
                    </AccordionPanel>
                    <AccordionPanel value="2">
                        <AccordionHeader>Idioma</AccordionHeader>
                        <AccordionContent>
                            <div class="flex flex-wrap justify-center gap-4">
                                <FloatLabel variant="on">
                                    <IconField>
                                        <InputText class="w-60" size="small" v-model="queryLanguage" />
                                        <InputIcon class="pi pi-search" />
                                    </IconField>
                                    <label for="on_label">Busca un idioma</label>
                                </FloatLabel>
                                <div v-for="language in filteredLanguage" :key="language.code" class="flex items-center gap-2">
                                    <RadioButton v-model="selectedLanguage" :inputId="language.code" name="language" :value="language.code" />
                                    <label :for="language.code">{{ language.name }}</label>
                                </div>
                            </div>
                        </AccordionContent>
                    </AccordionPanel>
                    <AccordionPanel value="3">
                        <AccordionHeader>Any</AccordionHeader>
                        <AccordionContent>
                            <DatePicker v-model="selectedYear" inline view="year" dateFormat="yy" />
                        </AccordionContent>
                    </AccordionPanel>
                </Accordion>
            </div>
        </div>
        <div class="flex-1 flex-col">
            <div class="flex justify-between items-center">
                <SelectButton 
                    class="shadow" 
                    v-model="sortValue" 
                    :options="optionsSort" 
                    optionLabel="sort_by" 
                    optionValue="value" />
                <Button 
                    iconPos="right" 
                    :icon="isFiltersVisible ? 'pi pi-filter-fill' : 'pi pi-filter'" 
                    severity="contrast" 
                    label="Filtres"
                    @click="isFiltersVisible = !isFiltersVisible"
                    raised>
                </Button>
            </div>
            <div class="flex flex-wrap my-10 mx-2 gap-10 justify-between items-center">
                <FilmCard
                    v-for="(film, index) in filmsQueryFiltered"
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