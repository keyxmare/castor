# ADR 0002 — Durcissement du scaffold

- Statut : accepté
- Date : 2026-05-30

## Contexte

Le scaffold initial (cf. [`0001`](0001-stack-et-archi.md)) était optimisé pour le
développement local. Plusieurs promesses du référentiel de standards n'étaient pas
encore outillées (couverture, analyse statique Symfony/Doctrine, a11y) et il manquait
un chemin de mise en production ainsi que des optimisations CI.

## Décision

### Images Docker multi-stage

- Dockerfiles `php` et `node` découpés en stages `base` / `dev` / `prod`.
- `compose.yaml` cible le stage `dev` (outillage + pcov, bind-mount du code).
- Stage `prod` durci : code copié dans l'image, `composer install --no-dev` + autoloader
  optimisé, OPcache figé (`validate_timestamps=0` + `preload`), build SSR Nuxt servi par
  Nitro, **utilisateur non-root** (`www-data` / `node`), sans pcov.
- Dépendance PostgreSQL isolée aux cibles de test (`--no-deps` ailleurs), ce qui allège
  le `commit-gate`.

### Couverture & analyse statique

- Couverture mesurable : **pcov** côté PHP, **v8** côté Vitest (`make coverage`).
- PHPStan niveau 8 complété par les extensions **phpstan-symfony** et **phpstan-doctrine**.

### Tests e2e & accessibilité

- Image Playwright dédiée (`docker/playwright/`) : dépendances figées au build, plus
  d'installation au runtime.
- Test d'accessibilité **axe-core** sur la page d'accueil (zéro violation WCAG 2 A/AA).

### CI

- Cache des dépendances (vendor, node_modules, store pnpm) et des layers Docker
  (buildx + override `compose.ci.yaml`, sans impacter le build local).
- Job **audit** (composer + pnpm) non bloquant.

### Épinglage toolchain

- `composer:2.8` et `corepack@0.35.0` épinglés ; `.dockerignore` ajouté (contexte de build
  réduit à la racine).

## Conséquences

- Le scaffold fournit un chemin de prod prêt à l'emploi ; restent à la charge de la cible
  le reverse proxy HTTPS et la fourniture des secrets.
- La couverture est un **indicateur** outillé, non un gate bloquant (cf. standards §5).
- Le cache de layers CI repose sur le backend `type=gha` ; en cas d'indisponibilité du
  token, le build se poursuit sans cache (dégradation silencieuse, non bloquante).
