import { defineConfig } from "cypress";
import dotenv from "dotenv";
dotenv.config();

console.log(process.env);

export default defineConfig({
  env: {
    base_url: process.env.TEST_CYPRESS_BASEURL,
  },
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
});
