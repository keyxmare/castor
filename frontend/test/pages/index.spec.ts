import { describe, expect, it } from 'vitest'
import { mountSuspended, registerEndpoint } from '@nuxt/test-utils/runtime'
import IndexPage from '~/pages/index.vue'

registerEndpoint('/api/greeting', () => ({
  message: 'Hello from Symfony',
  generatedAt: '2026-01-01T00:00:00+00:00',
}))

registerEndpoint('/api/health', () => ({ status: 'ok', database: 'ok' }))

describe('index page', () => {
  it('renders the API greeting and a healthy status', async () => {
    const wrapper = await mountSuspended(IndexPage)

    expect(wrapper.text()).toContain('Hello from Symfony')
    expect(wrapper.html()).toContain('data-status="ok"')
  })

  it('exposes one assistant tab per supported AI', async () => {
    const wrapper = await mountSuspended(IndexPage)

    expect(wrapper.findAll('[role="tab"]')).toHaveLength(3)
  })
})
