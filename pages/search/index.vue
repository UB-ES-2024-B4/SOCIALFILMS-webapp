<script setup lang="ts">
import 'primeicons/primeicons.css'
import { countries, languages, genres } from "~/types";

const supabase = useSupabaseClient()
const route = useRoute()

const isFiltersVisible = ref(false)

const selectedCountry = ref()
const selectedGenres = ref()
const selectedLanguage = ref()
const selectedYear = ref()
const query = ref('')

</script>

<template>
  <div class="w-full h-full">
    <form class="flex flex-col px-20 py-40" @submit.prevent="navigateTo(`/search/${encodeURIComponent(query)}`)">
      <h1 class="text-8xl font-semibold mb-10">Buscador</h1>
      <div class="flex flex-col justify-center gap-1.5">
        <!-- Search input -->
        <Message  severity="secondary" variant="simple">Milions de pel·lícules i ressenyes.</Message>
        <InputGroup>
          <InputGroupAddon>
            <Button type="submit" icon="pi pi-search" severity="secondary" variant="text" size="large" />
          </InputGroupAddon>
          <InputText v-model="query" type="text" size="large" placeholder="Busca" variant="filled" />
          <InputGroupAddon>
            <Button :icon="isFiltersVisible ? 'pi pi-filter-fill' : 'pi pi-filter'" severity="contrast" label="Filtres" size="large" @click="isFiltersVisible = !isFiltersVisible"/>
          </InputGroupAddon>
        </InputGroup>
      </div>

      <!-- Filters -->
      <div v-if="isFiltersVisible" class="flex items-center mt-4 gap-2">
        <MultiSelect class="w-full md:w-64" size="small" v-model="selectedGenres" display="chip" :options="genres" optionLabel="name" filter placeholder="Gèneres"
          :maxSelectedLabels="3" />
        <Select class="w-full md:w-32" size="small" filter showClear v-model="selectedCountry" :options="countries" optionLabel="name" placeholder="País" variant="outlined" />
        <Select class="w-full md:w-32" size="small" filter showClear v-model="selectedLanguage" :options="languages" optionLabel="name" placeholder="Idioma"/>
        <DatePicker class="w-full md:w-24" size="small" v-model="selectedYear" view="year" dateFormat="yy" showIcon iconDisplay="input" placeholder="Any" />
      </div>
    </form>
  </div>
</template>