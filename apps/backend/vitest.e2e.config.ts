import swc from 'unplugin-swc';
import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsconfigPaths({ ignoreConfigErrors: true }), swc.vite({ module: { type: 'es6' } })],
  oxc: false,
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['reflect-metadata'],
    include: ['test/**/*.e2e-spec.ts'],
    testTimeout: 10_000,
  },
});
