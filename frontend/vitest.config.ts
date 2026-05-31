import { defineVitestConfig } from '@nuxt/test-utils/config'

export default defineVitestConfig({
  test: {
    environment: 'nuxt',
    include: ['test/**/*.spec.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'clover'],
      reportsDirectory: 'coverage',
      include: ['app/**/*.{ts,vue}'],
    },
  },
})
