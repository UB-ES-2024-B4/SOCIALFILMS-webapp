import Aura from '@primevue/themes/aura';

export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/supabase',
    '@nuxtjs/tailwindcss',
    '@primevue/nuxt-module',
    '@nuxt/icon',
    '@nuxtjs/google-fonts'
  ],
  supabase: {
    redirectOptions: {
      login: '/login',
      callback: '/',
      include: undefined,
      exclude: ['/','/signup', '/movies', '/movies/*', '/search', '/search/*'],
      cookieRedirect: false,
    }
  },
  primevue: {
    usePrimeVue: true,
    autoImport: true,
    importTheme: { from: '@/themes/mytheme.js' },
  },
  googleFonts: {
    families: {
      Inter: {
        wght: '100..900',
        ital: '100..900',
      }
    }
  },
  app: {
    head: {
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/logo1.png' }

      ]
    }
  },
  css: ["~/assets/css/main.css"]
})