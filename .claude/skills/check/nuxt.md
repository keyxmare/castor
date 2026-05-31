# Fiche Nuxt — check

Indice de présence : `nuxt.config.ts|js` ou dépendance `nuxt` dans `package.json`. Paquets gérés via **pnpm**.

## Outils & ordre (alignés CLAUDE.md)

| Famille | Outil |
| --- | --- |
| Format | Prettier (ou `eslint --fix`) |
| Lint | ESLint |
| Typecheck | `nuxi typecheck` / `vue-tsc` |
| Tests | Vitest (unit / composants), Playwright (e2e) |

## Exécuter — toujours dans Docker

Aucune commande sur l'hôte. Service node typique : `node`, `front`, `web`.

1. **Cible `make`** si le projet en expose (`make lint`, `make front-test`…) — **lire la recette** pour confirmer qu'elle passe par Docker, puis la préférer.
2. Sinon **`docker compose exec <svc> …`** (stack non démarrée → `docker compose run --rm <svc> …`) :
   - `docker compose exec <svc> pnpm run lint`
   - `docker compose exec <svc> pnpm run typecheck`  (ou `pnpm exec nuxi typecheck`)
   - `docker compose exec <svc> pnpm run test`
   - `docker compose exec <svc> pnpm run test:e2e`

Les scripts `package.json` (`lint`, `typecheck`, `test`, `test:e2e`) ne donnent que le **nom** du script à appeler **dans le conteneur** — jamais à lancer via `pnpm` / `npx` sur l'hôte.
