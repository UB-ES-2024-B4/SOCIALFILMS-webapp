const { defineConfig } = require("cypress");
const envConfig = require("./cypress.env.cjs"); // Usar require en lugar de import

module.exports = defineConfig({
  env: envConfig,
  e2e: {
    setupNodeEvents(on, config) {
      // Implementa eventos de Node si es necesario
    },
  },
});
