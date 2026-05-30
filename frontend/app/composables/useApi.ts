export function useApiClient() {
  return $fetch.create({ baseURL: useApiBase() })
}
