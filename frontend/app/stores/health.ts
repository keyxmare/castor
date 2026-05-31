import { defineStore } from 'pinia'

interface HealthResponse {
  status: string
  database: string
}

export const useHealthStore = defineStore('health', () => {
  const available = ref(false)

  async function refresh(): Promise<void> {
    const api = useApiClient()

    try {
      const data = await api<HealthResponse>('/health')
      available.value = data.status === 'ok'
    } catch {
      available.value = false
    }
  }

  return { available, refresh }
})
