import { beforeEach, describe, expect, it, vi } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { mockNuxtImport } from '@nuxt/test-utils/runtime'
import { useHealthStore } from '~/stores/health'

const { fetchMock } = vi.hoisted(() => ({ fetchMock: vi.fn() }))

mockNuxtImport('useApiClient', () => () => fetchMock)

describe('useHealthStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    fetchMock.mockReset()
  })

  it('marks the API as available when the health status is ok', async () => {
    fetchMock.mockResolvedValue({ status: 'ok', database: 'ok' })

    const store = useHealthStore()
    await store.refresh()

    expect(store.available).toBe(true)
  })

  it('marks the API as unavailable when the request fails', async () => {
    fetchMock.mockRejectedValue(new Error('network'))

    const store = useHealthStore()
    await store.refresh()

    expect(store.available).toBe(false)
  })
})
