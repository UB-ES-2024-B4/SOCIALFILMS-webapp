import Aura from '@primevue/themes/aura';

export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: true },
  modules: ['@nuxtjs/supabase', '@nuxtjs/tailwindcss', '@primevue/nuxt-module', '@nuxt/icon'],
  supabase: {
    redirectOptions: {
      login: '/login',
      callback: '/',
      include: undefined,
      exclude: ['/','/signup'],
      cookieRedirect: false,
    }
  },
  primevue: {
    usePrimeVue: true,
    autoImport: true,
    options: {
        theme: {
            preset: Aura
        }
    }
  }
})