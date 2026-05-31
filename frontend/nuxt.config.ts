export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  app: {
    head: {
      title: 'Castor',
      meta: [
        {
          name: 'description',
          content: 'Castor — base dockerisée Symfony + Nuxt pour les projets de l’équipe.',
        },
      ],
      link: [
        { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/favicon-32.png' },
        { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/favicon-16.png' },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' },
      ],
    },
  },
  modules: [
    '@sentry/nuxt/module',
    '@nuxt/eslint',
    '@nuxt/test-utils/module',
    '@pinia/nuxt',
    '@nuxtjs/i18n',
  ],
  typescript: {
    strict: true,
    typeCheck: false,
  },
  runtimeConfig: {
    internalApiBase: 'http://nginx/api',
    public: {
      apiBase: '/api',
      sentry: {
        dsn: '',
      },
    },
  },
  nitro: {
    devProxy: {
      '/api': { target: 'http://nginx/api', changeOrigin: true },
    },
  },
  sourcemap: {
    client: 'hidden',
  },
  eslint: {
    config: {
      stylistic: false,
    },
  },
  sentry: {
    sourceMapsUploadOptions: {
      enabled: false,
    },
  },
  i18n: {
    strategy: 'no_prefix',
    defaultLocale: 'fr',
    detectBrowserLanguage: false,
    locales: [
      { code: 'fr', name: 'Français', file: 'fr.json' },
      { code: 'en', name: 'English', file: 'en.json' },
    ],
  },
})
