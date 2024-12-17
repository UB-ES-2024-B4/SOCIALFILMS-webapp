<script setup lang="ts">
import type { Film, FilmsAPI } from "~/types";
import { countries, languages, genres } from "~/types";

definePageMeta({
  layout: "navbar",
});

const supabase = useSupabaseClient();
const user = useSupabaseUser();

const optionsSort = ref([
  { sort_by: "Más vistas", value: "popularity.desc" },
  { sort_by: "Menos vistas", value: "popularity.asc" },
  { sort_by: "Más valoradas", value: "vote_count.desc" },
  { sort_by: "Menos valoradas", value: "vote_count.asc" },
  { sort_by: "Mejor valoradas", value: "vote_average.desc" },
  { sort_by: "Peor valoradas", value: "vote_average.asc" },
]);
const sortValue = ref("popularity.desc");

const isFiltersVisible = ref(true);
const queryCountry = ref("");
const queryGenre = ref("");
const queryLanguage = ref("");

const selectedGenres = ref<number[]>([]);
const selectedYear = ref<Date | null>(null);
const selectedCountry = ref<string>("");
const selectedLanguage = ref<string>("");

const filmsQuery = ref<Film[]>([]);
const currentBackground = ref("");
const isBackgroundTransitioning = ref(false);

const applyFilters = async () => {
  if (
    selectedGenres.value.length === 0 &&
    !selectedCountry.value &&
    !selectedLanguage.value &&
    !selectedYear.value
  ) {
    filmsQuery.value = [];
    isBackgroundTransitioning.value = true;
    setTimeout(() => {
      currentBackground.value = '/';
    }, 350);
    
    return;
  }
  try {
    const params = {
      with_genres: selectedGenres.value.length
        ? encodeURIComponent(selectedGenres.value.join(","))
        : null,
      with_origin_country: selectedCountry.value || null,
      sort_by: sortValue.value,
      with_original_language: selectedLanguage.value || null,
      year: selectedYear.value
        ? selectedYear.value.getFullYear()
        : null,
      lang: "ca-ES",
    };

    const { data, error } = (await supabase.rpc("discover_movies", params)) as {
      data: FilmsAPI;
      error: any;
    };

    if (error) throw error;

    filmsQuery.value = data.results;
    const newBackdrop = filmsQuery.value[0]?.backdrop_path;
    if (newBackdrop && newBackdrop !== currentBackground.value) {
      isBackgroundTransitioning.value = true;

      setTimeout(() => {
        currentBackground.value = newBackdrop;
      }, 350);
    }
  } catch (e) {
    console.error("Error fetching movies:", e);
  }
};

const navigateToMovie = (id: number) => {
  navigateTo(`/movies/${id}`);
};

const filteredGenres = computed(() => {
  if (queryGenre) {
    return genres.filter((genre) =>
      genre.name.toLowerCase().includes(queryGenre.value.toLowerCase())
    );
  }
  return genres;
});

const filteredCountry = computed(() => {
  if (queryCountry) {
    return countries.filter((country) =>
      country.name.toLowerCase().includes(queryCountry.value.toLowerCase())
    );
  }
  return countries;
});

const filteredLanguage = computed(() => {
  if (queryLanguage) {
    return languages.filter((language) =>
      language.name.toLowerCase().includes(queryLanguage.value.toLowerCase())
    );
  }
  return languages;
});

watch(
  [
    selectedGenres,
    selectedYear,
    selectedCountry,
    selectedLanguage,
    sortValue,
  ],
  async () => {
    await applyFilters();
  },
  { deep: true }
);
</script>

<template>
  <div
    class="w-full h-full fixed inset-0 bg-cover bg-center transition-opacity duration-700"
    :style="{ backgroundImage: `url(https://image.tmdb.org/t/p/original${currentBackground})`, opacity: isBackgroundTransitioning ? 0 : 1 }"
    @transitionend="isBackgroundTransitioning = false"
  ></div>
  <div class="absolute inset-0 bg-gradient-to-b from-neutral-800/50 via-neutral-800/5 via-25% to-neutral-800/0"></div>
  <div class="pt-[4.5rem] w-full h-full relative backdrop-blur-xl bg-zinc-300/20 dark:bg-black/60">
    <div class="flex py-5 ml-10 mr-4">
      <div class="flex-none">
        <div v-if="isFiltersVisible" class="w-72 mr-10 rounded-md shadow">
          <Accordion :value="['0', '1', '2', '3']" multiple>
            <AccordionPanel value="0">
              <AccordionHeader>Gèneres</AccordionHeader>
              <AccordionContent>
                <div class="flex flex-wrap justify-center gap-4">
                  <div class="flex items-center gap-2">
                    <FloatLabel variant="on">
                      <IconField>
                        <InputText
                          fluid
                          size="small"
                          v-model="queryGenre"
                        />
                        <InputIcon class="pi pi-search" />
                      </IconField>
                      <label for="on_label">Busca un gènere</label>
                    </FloatLabel>
                    <Button v-tooltip.bottom="'Neteja els gèneres'" icon="pi pi-filter-slash" severity="contrast" aria-label="Neteja els gèneres" size="small" @click="selectedGenres = []"/>
                  </div>
                  <div
                    v-for="genre of filteredGenres"
                    :key="genre.code"
                    class="flex items-center gap-2"
                  >
                    <Checkbox
                      v-model="selectedGenres"
                      name="genre"
                      :value="genre.code"
                    />
                    <label :for="genre.name">{{ genre.name }}</label>
                  </div>
                </div>
              </AccordionContent>
            </AccordionPanel>
            <AccordionPanel value="1">
              <AccordionHeader>País</AccordionHeader>
              <AccordionContent>
                <div class="flex flex-wrap justify-center gap-4">
                  <div class="flex items-center gap-2">
                    <FloatLabel variant="on">
                      <IconField>
                        <InputText
                          fluid
                          size="small"
                          v-model="queryCountry"
                        />
                        <InputIcon class="pi pi-search" />
                      </IconField>
                      <label for="on_label">Busca un país</label>
                    </FloatLabel>
                    <Button v-tooltip.bottom="'Neteja el país'" icon="pi pi-filter-slash" severity="contrast" aria-label="Neteja el país" size="small" @click="selectedCountry = ''"/>
                  </div>
                  <div
                    v-for="country in filteredCountry"
                    :key="country.code"
                    class="flex items-center gap-2"
                  >
                    <RadioButton
                      v-model="selectedCountry"
                      :inputId="country.code"
                      name="country"
                      :value="country.code"
                    />
                    <label :for="country.code">{{ country.name }}</label>
                  </div>
                </div>
              </AccordionContent>
            </AccordionPanel>
            <AccordionPanel value="2">
              <AccordionHeader>Idioma</AccordionHeader>
              <AccordionContent>
                <div class="flex flex-wrap justify-center gap-4">
                  <div class="flex items-center gap-2">
                    <FloatLabel variant="on">
                      <IconField>
                        <InputText
                          fluid
                          size="small"
                          v-model="queryLanguage"
                        />
                        <InputIcon class="pi pi-search" />
                      </IconField>
                      <label for="on_label">Busca un idioma</label>
                    </FloatLabel>
                    <Button v-tooltip.bottom="`Neteja l'idioma`" icon="pi pi-filter-slash" severity="contrast" aria-label="Neteja l'idioma" size="small" @click="selectedLanguage = ''"/>
                  </div>
                  <div
                    v-for="language in filteredLanguage"
                    :key="language.code"
                    class="flex items-center gap-2"
                  >
                    <RadioButton
                      v-model="selectedLanguage"
                      :inputId="language.code"
                      name="language"
                      :value="language.code"
                    />
                    <label :for="language.code">{{ language.name }}</label>
                  </div>
                </div>
              </AccordionContent>
            </AccordionPanel>
            <AccordionPanel value="3">
              <AccordionHeader>Any</AccordionHeader>
              <AccordionContent>
                <DatePicker
                  v-model="selectedYear"
                  inline
                  view="year"
                  dateFormat="yy"
                  fluid
                />
                <Button fluid class="mt-2" label="Neteja l'any" icon="pi pi-filter-slash" severity="contrast" aria-label="Neteja l'idioma" size="small" @click="selectedYear = null"/>
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
            optionValue="value"
          />
          <Button
            iconPos="right"
            :icon="isFiltersVisible ? 'pi pi-filter-fill' : 'pi pi-filter'"
            severity="contrast"
            label="Filtres"
            @click="isFiltersVisible = !isFiltersVisible"
            raised
          >
          </Button>
        </div>

        <div
          v-if="filmsQuery.length > 0"
          class="flex flex-wrap my-10 mx-2 gap-10 items-center"
        >
          <FilmCard
            v-for="(film, index) in filmsQuery"
            class="cursor-pointer"
            :film="film"
            :trending="false"
            :trendingNumber="index + 1"
            :favorite="false"
            :watch_later="user ? true : false"
            @click="navigateToMovie(film.id)"
          ></FilmCard>
        </div>
        <div
          v-else-if="selectedGenres.length === 0 && !selectedCountry && !selectedLanguage && !selectedYear"
          class="w-full mt-16 items-center justify-center text-center"
        >
          <p class="text-2xl font-semibold text-gray-600 dark:text-gray-300">
            Explora pel·lícules noves ajustant els filtres
          </p>
          <p class="mt-2 text-xl text-gray-400 dark:text-gray-500">
            Comença ajustant els filtres
          </p>
        </div>
        <div
          v-else
          class="w-full mt-16 items-center justify-center text-center"
        >
          <p class="text-2xl font-semibold text-gray-600 dark:text-gray-300">
            No s'han trobat resultats per aquest filtratge
          </p>
          <p class="mt-2 text-xl text-gray-400 dark:text-gray-500">
            Prova a ajustar els filtres
          </p>
        </div>
      </div>
    </div>
  </div>
</template>