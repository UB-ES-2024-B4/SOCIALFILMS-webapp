<script setup lang="ts">
import "primeicons/primeicons.css";
import { countries, languages, genres } from "~/types";
import type { SearchFilters } from "~/types";

definePageMeta({
  layout: "navbar",
});

const isFiltersVisible = ref(false);

const selectedCountry = ref();
const selectedGenres = ref([]);
const selectedLanguage = ref();
const selectedYear = ref();
const searchQuery = ref("");

const handleSubmitSearch = () => {
  if (searchQuery.value.trim()) {
    const formattedQuery = searchQuery.value.trim().replace(/\s+/g, "-");
    const filters: SearchFilters = {};
    if (selectedGenres.value.length > 0) {
      filters.genre = selectedGenres.value.join(",");
    }
    if (selectedCountry.value) {
      filters.country = selectedCountry.value;
    }
    if (selectedLanguage.value) {
      filters.language = selectedLanguage.value;
    }
    if (selectedYear.value) {
      filters.year = new Date(selectedYear.value).getFullYear().toString();
    }

    const queryParams = new URLSearchParams(
      filters as Record<string, string>
    ).toString();
    const url = queryParams
      ? `/search/${encodeURIComponent(formattedQuery)}?${queryParams}`
      : `/search/${encodeURIComponent(formattedQuery)}`;

    navigateTo(url);
  }
};
</script>

<template>
  <div class="w-full h-full">
    <form
      class="flex flex-col px-20 pt-52"
      @submit.prevent="handleSubmitSearch"
    >
      <h1 class="text-8xl font-semibold mb-10">Buscador</h1>
      <div class="flex flex-col justify-center gap-1.5">
        <!-- Search input -->
        <Message severity="secondary" variant="simple"
          >Milions de pel·lícules i ressenyes.</Message
        >
        <InputGroup>
          <InputGroupAddon>
            <Button
              type="submit"
              icon="pi pi-search"
              severity="secondary"
              variant="text"
              size="large"
            />
          </InputGroupAddon>
          <InputText
            v-model="searchQuery"
            type="text"
            size="large"
            placeholder="Busca"
            variant="filled"
          />
          <InputGroupAddon>
            <Button
              :icon="isFiltersVisible ? 'pi pi-filter-fill' : 'pi pi-filter'"
              severity="contrast"
              label="Filtres"
              size="large"
              @click="isFiltersVisible = !isFiltersVisible"
            />
          </InputGroupAddon>
        </InputGroup>
      </div>

      <!-- Filters -->
      <div v-if="isFiltersVisible" class="flex items-center mt-4 gap-2">
        <MultiSelect
          class="w-full md:w-64"
          size="small"
          v-model="selectedGenres"
          display="chip"
          :options="genres"
          optionLabel="name"
          optionValue="code"
          filter
          placeholder="Gèneres"
          :maxSelectedLabels="3"
        />
        <Select
          class="w-full md:w-40"
          size="small"
          filter
          showClear
          v-model="selectedCountry"
          :options="countries"
          optionLabel="name"
          optionValue="code"
          placeholder="País"
          variant="outlined"
        />
        <Select
          class="w-full md:w-40"
          size="small"
          filter
          showClear
          v-model="selectedLanguage"
          :options="languages"
          optionLabel="name"
          optionValue="code"
          placeholder="Idioma"
        />
        <DatePicker
          class="w-full md:w-40"
          size="small"
          v-model="selectedYear"
          view="year"
          dateFormat="yy"
          showIcon
          placeholder="Any"
        />
      </div>
    </form>
  </div>
</template>
