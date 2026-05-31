<script setup lang="ts">
interface AssistantTab {
  id: string
  label: string
  command: string
  config: string
}

const props = defineProps<{
  items: AssistantTab[]
  tablistLabel: string
}>()

const selected = ref(0)
const tablist = ref<HTMLElement | null>(null)
const uid = useId()

const tabId = (index: number) => `${uid}-tab-${index}`
const panelId = (index: number) => `${uid}-panel-${index}`

const focusTab = (index: number) => {
  selected.value = index
  const tabs = tablist.value?.querySelectorAll<HTMLElement>('[role="tab"]')
  tabs?.[index]?.focus()
}

const onKeydown = (event: KeyboardEvent, index: number) => {
  const count = props.items.length
  switch (event.key) {
    case 'ArrowRight':
    case 'ArrowDown':
      event.preventDefault()
      focusTab((index + 1) % count)
      break
    case 'ArrowLeft':
    case 'ArrowUp':
      event.preventDefault()
      focusTab((index - 1 + count) % count)
      break
    case 'Home':
      event.preventDefault()
      focusTab(0)
      break
    case 'End':
      event.preventDefault()
      focusTab(count - 1)
      break
  }
}
</script>

<template>
  <div class="tabs">
    <div ref="tablist" role="tablist" :aria-label="tablistLabel" class="tabs__list">
      <button
        v-for="(item, index) in items"
        :id="tabId(index)"
        :key="item.id"
        type="button"
        role="tab"
        class="tabs__tab"
        :aria-selected="selected === index"
        :aria-controls="panelId(index)"
        :tabindex="selected === index ? 0 : -1"
        @click="selected = index"
        @keydown="onKeydown($event, index)"
      >
        {{ item.label }}
      </button>
    </div>
    <div
      v-for="(item, index) in items"
      v-show="selected === index"
      :id="panelId(index)"
      :key="item.id"
      role="tabpanel"
      class="tabs__panel"
      :aria-labelledby="tabId(index)"
      :tabindex="0"
    >
      <code class="tabs__command">{{ item.command }}</code>
      <p class="tabs__config">{{ item.config }}</p>
    </div>
  </div>
</template>

<style scoped>
.tabs {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.tabs__list {
  display: inline-flex;
  gap: 0.25rem;
  align-self: flex-start;
  padding: 0.25rem;
  background: #eceef4;
  border: 1px solid #e7e9f0;
  border-radius: 999px;
}

.tabs__tab {
  padding: 0.4rem 1rem;
  font: inherit;
  font-size: 0.85rem;
  font-weight: 600;
  color: #5b6472;
  cursor: pointer;
  background: transparent;
  border: 0;
  border-radius: 999px;
  transition: background-color 0.15s ease;
}

.tabs__tab:hover[aria-selected='false'] {
  background: rgba(31, 36, 48, 0.06);
}

.tabs__tab[aria-selected='true'] {
  color: #ffffff;
  background: #1b1e24;
}

.tabs__panel {
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
  align-items: flex-start;
  padding: 1.5rem;
  background: #1b1e24;
  border-radius: 1rem;
}

.tabs__command {
  padding: 0.6rem 1.1rem;
  font-family: ui-monospace, 'SF Mono', 'Cascadia Code', Menlo, Consolas, monospace;
  font-size: 1.1rem;
  font-weight: 700;
  color: #ffffff;
  background: linear-gradient(135deg, #e11d2a, #b3151f);
  border-radius: 0.6rem;
}

.tabs__config {
  margin: 0;
  font-size: 0.92rem;
  line-height: 1.5;
  color: #c2c6d0;
}

.tabs__tab:focus-visible {
  outline: 2px solid #1b1e24;
  outline-offset: 2px;
}

.tabs__panel:focus-visible {
  outline: 2px solid #ffffff;
  outline-offset: 2px;
}
</style>
