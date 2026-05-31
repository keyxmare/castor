import { describe, expect, it } from 'vitest'
import { mountSuspended } from '@nuxt/test-utils/runtime'
import type { DOMWrapper } from '@vue/test-utils'
import AssistantTabs from '~/components/AssistantTabs.vue'

const items = [
  { id: 'claude', label: 'Claude', command: '/castor-init', config: 'Reads .claude/' },
  { id: 'codex', label: 'Codex', command: 'skill castor-init', config: 'Reads .codex/' },
  { id: 'gemini', label: 'Gemini', command: '/castor-init', config: 'Reads .gemini/' },
]

const mount = () => mountSuspended(AssistantTabs, { props: { items, tablistLabel: 'Assistant' } })

const isHidden = (el: DOMWrapper<Element>) =>
  (el.attributes('style') ?? '').includes('display: none')

describe('AssistantTabs', () => {
  it('renders one tab per assistant with the first selected and visible', async () => {
    const wrapper = await mount()

    const tabs = wrapper.findAll('[role="tab"]')
    const panels = wrapper.findAll('[role="tabpanel"]')
    expect(tabs).toHaveLength(3)
    expect(panels).toHaveLength(3)
    expect(tabs[0]!.attributes('aria-selected')).toBe('true')
    expect(tabs[1]!.attributes('aria-selected')).toBe('false')
    expect(isHidden(panels[0]!)).toBe(false)
    expect(isHidden(panels[1]!)).toBe(true)
  })

  it('selects a tab on click and reveals its panel', async () => {
    const wrapper = await mount()

    await wrapper.findAll('[role="tab"]')[1]!.trigger('click')

    const tabs = wrapper.findAll('[role="tab"]')
    const panels = wrapper.findAll('[role="tabpanel"]')
    expect(tabs[1]!.attributes('aria-selected')).toBe('true')
    expect(tabs[0]!.attributes('aria-selected')).toBe('false')
    expect(isHidden(panels[1]!)).toBe(false)
    expect(isHidden(panels[0]!)).toBe(true)
  })

  it('moves selection with the arrow keys, wrapping around', async () => {
    const wrapper = await mount()
    const tabAt = (index: number) => wrapper.findAll('[role="tab"]')[index]!
    const selectedIndex = () =>
      wrapper.findAll('[role="tab"]').findIndex((tab) => tab.attributes('aria-selected') === 'true')

    await tabAt(0).trigger('keydown', { key: 'ArrowLeft' })
    expect(selectedIndex()).toBe(2)

    await tabAt(2).trigger('keydown', { key: 'ArrowRight' })
    expect(selectedIndex()).toBe(0)

    await tabAt(0).trigger('keydown', { key: 'End' })
    expect(selectedIndex()).toBe(2)

    await tabAt(2).trigger('keydown', { key: 'Home' })
    expect(selectedIndex()).toBe(0)
  })

  it('links every tab to its panel', async () => {
    const wrapper = await mount()

    const tabs = wrapper.findAll('[role="tab"]')
    const panels = wrapper.findAll('[role="tabpanel"]')
    tabs.forEach((tab, index) => {
      expect(tab.attributes('aria-controls')).toBe(panels[index]!.attributes('id'))
      expect(panels[index]!.attributes('aria-labelledby')).toBe(tab.attributes('id'))
    })
  })
})
