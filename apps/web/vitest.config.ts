import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  // `@vitejs/plugin-vue` lets route-level specs mount real `@app/ui` SFCs
  // (the package re-exports source `.vue` files via its `exports` map).
  // Without it, importing any component from `@app/ui` blows up the
  // import-analysis step with "Install @vitejs/plugin-vue to handle .vue files".
  plugins: [vue(), tsconfigPaths()],
  test: {
    environment: 'happy-dom',
    globals: true,
    include: [
      'tests/unit/**/*.spec.ts',
      'app/pages/__tests__/**/*.spec.ts',
      'app/utils/__tests__/**/*.spec.ts',
      'app/components/**/__tests__/**/*.spec.ts',
      'app/layouts/__tests__/**/*.spec.ts',
      'app/stores/**/*.spec.ts',
    ],
  },
});
