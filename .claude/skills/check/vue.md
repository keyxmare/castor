# Fiche Vue (Vite, sans Nuxt) — check

Indice de présence : fichiers `.vue` + `vite.config.*`, et **pas** de Nuxt. Paquets gérés via **pnpm**.

## Outils & ordre (alignés CLAUDE.md)

| Famille | Outil |
| --- | --- |
| Format | Prettier |
| Lint | ESLint |
| Typecheck | `vue-tsc --noEmit` |
| Tests | Vitest (unit / composants), Playwright (e2e) |

## Exécuter — toujours dans Docker

Aucune commande sur l'hôte. Service node typique : `node`, `front`, `web`.

1. **Cible `make`** si le projet en expose — **lire la recette** pour confirmer qu'elle passe par Docker, puis la préférer.
2. Sinon **`docker compose exec <svc> …`** (stack non démarrée → `docker compose run --rm <svc> …`) :
   - `docker compose exec <svc> pnpm run lint`
   - `docker compose exec <svc> pnpm exec vue-tsc --noEmit`
   - `docker compose exec <svc> pnpm run test`

Les scripts `package.json` ne donnent que le **nom** du script à appeler **dans le conteneur** — jamais via `pnpm` / `vue-tsc` sur l'hôte.
