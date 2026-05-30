<script setup lang="ts">
interface GreetingResponse {
  message: string
  generatedAt: string
}

const { t, locale, locales, setLocale } = useI18n()

const healthStore = useHealthStore()

onMounted(() => {
  if (!healthStore.available) {
    void healthStore.refresh()
  }
})

const { data: greeting, error, refresh } = await useApiFetch<GreetingResponse>('/greeting')

await callOnce(() => healthStore.refresh())

const availableLocales = computed(() =>
  locales.value.map((entry) => (typeof entry === 'string' ? entry : entry.code)),
)

const features = computed(() => [
  { icon: '🐳', title: t('home.features.docker.title'), text: t('home.features.docker.text') },
  { icon: '✅', title: t('home.features.quality.title'), text: t('home.features.quality.text') },
  {
    icon: '📡',
    title: t('home.features.observability.title'),
    text: t('home.features.observability.text'),
  },
  { icon: '🤖', title: t('home.features.workflow.title'), text: t('home.features.workflow.text') },
])
</script>

<template>
  <main class="page">
    <section class="hero">
      <div class="hero__inner">
        <img
          class="hero__mascot"
          src="/castor.png"
          :alt="t('home.logoAlt')"
          width="512"
          height="512"
        />
        <p class="hero__eyebrow">{{ t('home.eyebrow') }}</p>
        <h1 class="hero__title">{{ t('home.title') }}</h1>
        <p class="hero__tagline">{{ t('home.tagline') }}</p>
        <p class="hero__lead">{{ t('home.lead') }}</p>
        <nav class="locale-switcher" :aria-label="t('home.localeSwitcher')">
          <button
            v-for="code in availableLocales"
            :key="code"
            class="locale-switcher__button"
            type="button"
            :aria-pressed="locale === code"
            :disabled="locale === code"
            @click="setLocale(code)"
          >
            {{ code }}
          </button>
        </nav>
      </div>
    </section>

    <div class="content">
      <section class="block">
        <h2 class="block__title">{{ t('home.featuresTitle') }}</h2>
        <ul class="features">
          <li v-for="feature in features" :key="feature.title" class="features__item">
            <span class="features__icon" aria-hidden="true">{{ feature.icon }}</span>
            <div>
              <p class="features__name">{{ feature.title }}</p>
              <p class="features__text">{{ feature.text }}</p>
            </div>
          </li>
        </ul>
      </section>

      <section class="block">
        <h2 class="block__title">{{ t('home.nextStepTitle') }}</h2>
        <p class="block__lead">{{ t('home.nextStepLead') }}</p>
        <div class="cta">
          <code class="cta__cmd">/castor-init</code>
          <p class="cta__note">{{ t('home.nextStepNote') }}</p>
        </div>
      </section>

      <section class="block" aria-live="polite">
        <h2 class="block__title">{{ t('home.liveTitle') }}</h2>
        <p class="block__lead">{{ t('home.liveLead') }}</p>
        <div class="live">
          <div class="live__card">
            <p class="live__label">{{ t('home.greetingLabel') }}</p>
            <p v-if="error" class="live__error" role="alert">
              <span>{{ t('home.error') }}</span>
              <button class="retry" type="button" :aria-label="t('home.error')" @click="refresh()">
                ↻
              </button>
            </p>
            <p v-else-if="greeting" class="live__value">
              <span class="live__message">{{ greeting.message }}</span>
              <time class="live__time" :datetime="greeting.generatedAt">{{
                greeting.generatedAt
              }}</time>
            </p>
            <p v-else class="live__muted">{{ t('home.loading') }}</p>
          </div>
          <div class="live__card">
            <p class="live__label">{{ t('home.healthLabel') }}</p>
            <p class="status" :data-status="healthStore.available ? 'ok' : 'down'">
              <span class="status__dot" aria-hidden="true" />
              {{ healthStore.available ? t('home.healthOk') : t('home.healthDown') }}
            </p>
          </div>
        </div>
      </section>

      <footer class="foot">{{ t('home.footer') }}</footer>
    </div>
  </main>
</template>

<style scoped>
.page {
  min-height: 100vh;
  font-family:
    ui-sans-serif,
    system-ui,
    -apple-system,
    'Segoe UI',
    Roboto,
    Helvetica,
    Arial,
    sans-serif;
  color: #1f2430;
  background: #f5f6fa;
}

.hero {
  padding: 3.5rem 1.5rem 3rem;
  color: #ffffff;
  text-align: center;
  background: radial-gradient(900px 500px at 50% 18%, #3b3e45 0%, #20232a 48%, #131419 100%);
}

.hero__inner {
  max-width: 48rem;
  margin: 0 auto;
}

.hero__mascot {
  display: block;
  width: clamp(11rem, 42vw, 16rem);
  height: auto;
  margin: 0 auto 1.25rem;
  filter: drop-shadow(0 16px 30px rgba(0, 0, 0, 0.55));
}

.hero__eyebrow {
  margin: 0 0 0.4rem;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: #9aa0ac;
}

.hero__title {
  margin: 0 0 0.5rem;
  font-size: clamp(2.4rem, 6vw, 3.25rem);
  font-weight: 800;
  letter-spacing: -0.02em;
}

.hero__tagline {
  margin: 0 0 1rem;
  font-size: 1.2rem;
  font-weight: 600;
  color: #f1f2f6;
}

.hero__lead {
  max-width: 38rem;
  margin: 0 auto 1.75rem;
  font-size: 1rem;
  line-height: 1.6;
  color: #c2c6d0;
}

.locale-switcher {
  display: inline-flex;
  gap: 0.25rem;
  padding: 0.25rem;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 999px;
}

.locale-switcher__button {
  padding: 0.35rem 0.85rem;
  font: inherit;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  color: #ffffff;
  cursor: pointer;
  background: transparent;
  border: 0;
  border-radius: 999px;
  transition: background-color 0.15s ease;
}

.locale-switcher__button:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.18);
}

.locale-switcher__button[aria-pressed='true'] {
  color: #1f2430;
  cursor: default;
  background: #ffffff;
}

.content {
  max-width: 60rem;
  margin: 0 auto;
  padding: 3rem 1.5rem 4rem;
}

.block {
  margin-bottom: 3rem;
}

.block__title {
  margin: 0 0 0.5rem;
  font-size: 1.4rem;
  font-weight: 700;
  letter-spacing: -0.01em;
}

.block__lead {
  margin: 0 0 1.5rem;
  color: #5b6472;
}

.features {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.25rem;
  margin: 0;
  padding: 0;
  list-style: none;
}

.features__item {
  display: flex;
  gap: 0.85rem;
  align-items: flex-start;
  padding: 1.25rem;
  background: #ffffff;
  border: 1px solid #e7e9f0;
  border-radius: 1rem;
}

.features__icon {
  flex-shrink: 0;
  font-size: 1.4rem;
  line-height: 1.2;
}

.features__name {
  margin: 0 0 0.3rem;
  font-size: 1rem;
  font-weight: 700;
}

.features__text {
  margin: 0;
  font-size: 0.88rem;
  line-height: 1.5;
  color: #5b6472;
}

.cta {
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
  align-items: flex-start;
  padding: 1.5rem;
  background: #1b1e24;
  border-radius: 1rem;
}

.cta__cmd {
  padding: 0.6rem 1.1rem;
  font-family: ui-monospace, 'SF Mono', 'Cascadia Code', Menlo, Consolas, monospace;
  font-size: 1.1rem;
  font-weight: 700;
  color: #ffffff;
  background: linear-gradient(135deg, #e11d2a, #b3151f);
  border-radius: 0.6rem;
}

.cta__note {
  margin: 0;
  font-size: 0.92rem;
  line-height: 1.5;
  color: #c2c6d0;
}

.live {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 1rem;
}

.live__card {
  padding: 1.25rem;
  background: #ffffff;
  border: 1px solid #e7e9f0;
  border-radius: 1rem;
}

.live__label {
  margin: 0 0 0.7rem;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: #5b6472;
}

.live__value {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  margin: 0;
}

.live__message {
  font-size: 1.05rem;
  font-weight: 600;
}

.live__time {
  font-size: 0.78rem;
  color: #5b6472;
  font-variant-numeric: tabular-nums;
}

.live__muted {
  margin: 0;
  color: #5b6472;
}

.live__error {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  margin: 0;
  font-weight: 600;
  color: #b91c1c;
}

.retry {
  width: 2rem;
  height: 2rem;
  font-size: 1rem;
  line-height: 1;
  color: #b91c1c;
  cursor: pointer;
  background: #fee2e2;
  border: 0;
  border-radius: 999px;
  transition: background-color 0.15s ease;
}

.retry:hover {
  background: #fecaca;
}

.status {
  display: inline-flex;
  gap: 0.55rem;
  align-items: center;
  margin: 0;
  padding: 0.4rem 0.9rem;
  font-size: 0.9rem;
  font-weight: 600;
  border-radius: 999px;
}

.status__dot {
  width: 0.6rem;
  height: 0.6rem;
  background: currentColor;
  border-radius: 999px;
}

.status[data-status='ok'] {
  color: #047857;
  background: #d1fae5;
}

.status[data-status='down'] {
  color: #b91c1c;
  background: #fee2e2;
}

.foot {
  padding-top: 2rem;
  font-size: 0.85rem;
  color: #5b6472;
  text-align: center;
  border-top: 1px solid #e7e9f0;
}

.locale-switcher__button:focus-visible,
.retry:focus-visible {
  outline: 2px solid #ffffff;
  outline-offset: 2px;
}

.retry:focus-visible {
  outline-color: #b91c1c;
}

@media (max-width: 36rem) {
  .features,
  .live {
    grid-template-columns: 1fr;
  }
}
</style>
