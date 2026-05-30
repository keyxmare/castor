export function useApiBase(): string {
  const config = useRuntimeConfig()

  return import.meta.server ? config.internalApiBase : config.public.apiBase
}
