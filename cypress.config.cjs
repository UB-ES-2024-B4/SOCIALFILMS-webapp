const { defineConfig } = require("cypress");
require('dotenv').config()

module.exports = defineConfig({
  env: {
    URL: process.env.CYPRESS_URL,
    SUPABASE_URL: process.env.CYPRESS_SUPABASE_URL,
    SUPABASE_SERVICE_KEY: process.env.CYPRESS_SUPABASE_SERVICE_KEY,
  },
  e2e: {
    setupNodeEvents(on, config) {
      // Implementa eventos de Node si es necesario
    },
  },
});
