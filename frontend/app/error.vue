<script setup lang="ts">
import type { NuxtError } from '#app'

defineProps<{ error: NuxtError }>()

const { t, locale } = useI18n()

useHead({ htmlAttrs: { lang: locale } })

function handleClear(): void {
  void clearError({ redirect: '/' })
}
</script>

<template>
  <main class="error">
    <div class="error__inner">
      <p class="error__code">{{ error.statusCode }}</p>
      <h1 class="error__title">{{ t('error.title') }}</h1>
      <p class="error__lead">{{ t('error.lead') }}</p>
      <button class="error__button" type="button" @click="handleClear">
        {{ t('error.back') }}
      </button>
    </div>
  </main>
</template>

<style scoped>
.error {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 1.5rem;
  font-family:
    ui-sans-serif,
    system-ui,
    -apple-system,
    'Segoe UI',
    Roboto,
    Helvetica,
    Arial,
    sans-serif;
  color: #ffffff;
  text-align: center;
  background: radial-gradient(900px 500px at 50% 18%, #3b3e45 0%, #20232a 48%, #131419 100%);
}

.error__inner {
  max-width: 32rem;
}

.error__code {
  margin: 0;
  font-size: 4rem;
  font-weight: 800;
  line-height: 1;
  color: #f1f2f6;
}

.error__title {
  margin: 0.75rem 0 0.5rem;
  font-size: 1.6rem;
  font-weight: 700;
}

.error__lead {
  margin: 0 0 1.75rem;
  color: #c2c6d0;
}

.error__button {
  padding: 0.7rem 1.4rem;
  font: inherit;
  font-weight: 700;
  color: #ffffff;
  cursor: pointer;
  background: #b3151f;
  border: 0;
  border-radius: 0.6rem;
  transition: background-color 0.15s ease;
}

.error__button:hover {
  background: #951119;
}

.error__button:focus-visible {
  outline: 2px solid #ffffff;
  outline-offset: 2px;
}
</style>
