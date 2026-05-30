export function useApiFetch<T>(path: string) {
  return useFetch<T>(path, { baseURL: useApiBase(), key: `api:${path}` })
}
