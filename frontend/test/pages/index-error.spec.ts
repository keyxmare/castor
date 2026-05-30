import { describe, expect, it } from 'vitest'
import { mountSuspended, registerEndpoint } from '@nuxt/test-utils/runtime'
import { createError } from 'h3'
import IndexPage from '~/pages/index.vue'

registerEndpoint('/api/greeting', () => {
  throw createError({ statusCode: 503, statusMessage: 'unavailable' })
})

registerEndpoint('/api/health', () => ({ status: 'degraded', database: 'unreachable' }))

describe('index page (degraded)', () => {
  it('renders the error alert and a down status', async () => {
    const wrapper = await mountSuspended(IndexPage)

    expect(wrapper.find('[role="alert"]').exists()).toBe(true)
    expect(wrapper.html()).toContain('data-status="down"')
  })
})
