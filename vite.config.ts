/// <reference types="vitest" />
import { defineConfig } from 'vite'

export default defineConfig({
  test: {
    testTimeout: 1000 * 60 * 2,
    setupFiles: ['./test/setup.ts'],
    exclude: [
      '**/node_modules/**',
      '**/.{git,dfx,vessel}/**',
      'test/marketplace',
    ],
  },
});