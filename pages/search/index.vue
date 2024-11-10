<script setup lang="ts">
import 'primeicons/primeicons.css'
import { countries, languages, genres } from "~/types";

const supabase = useSupabaseClient()
const route = useRoute()

const query = ref('')

</script>

<template>
  <div class="w-full h-full">
    <form class="flex flex-col px-20 py-40" @submit.prevent="navigateTo(`/search/${query}`)">
      <h1 class="text-8xl font-semibold mb-10">Buscador</h1>
      <div class="flex flex-col justify-center gap-1.5">
        <!-- Search input -->
        <Message  severity="secondary" variant="simple">Milions de pel·lícules i ressenyes.</Message>
        <InputGroup>
          <InputGroupAddon>
            <Button type="submit" icon="pi pi-search" severity="secondary" variant="text" size="large" />
          </InputGroupAddon>
          <InputText v-model="query" type="text" size="large" placeholder="Busca" variant="filled" />
        </InputGroup>
      </div>
    </form>
  </div>
</template>