# Standards techniques — SI de l'équipe

> Ce fichier est le **référentiel de standards techniques partagé**. Il est destiné à être
> chargé globalement par Claude Code (via un symlink vers `~/.claude/CLAUDE.md`, cf. `README.md`)
> et s'applique donc à **tous les projets** de l'équipe, pas seulement à ce dépôt.
>
> Il décrit **comment on écrit le code dans le SI**, pas le fonctionnement d'un projet précis.
> Toute évolution passe par une **PR sur ce dépôt** (revue d'équipe).
>
> Convention : `⚠️ À COMPLÉTER` marque une décision d'équipe à trancher avant adoption.

## 0. Principes généraux

- **Clarté avant astuce.** Du code lisible et explicite prime sur du code malin.
- **Cohérence locale.** Tout nouveau code épouse le style du code qui l'entoure (nommage, structure, idiomes).
- **Pas de magie silencieuse.** Une décision non triviale se justifie par le **nommage**, un **test** qui documente le comportement, le **message de commit** ou un **ADR** — pas par un commentaire.
- **Langue & commentaires.** Code et identifiants **en anglais**. On **ne commente pas** le code : il doit être **auto-explicite** (nommage parlant, fonctions courtes, comportement couvert par les tests). Les annotations exigées par l'outillage (PHPDoc de typage, attributs PHP) ne sont pas des commentaires et restent autorisées ; un commentaire ne se justifie que pour un *workaround* réellement non devinable. La **documentation projet** (README, ADR) reste en **français**.
- **On ne contourne pas les garde-fous** (lint, types, tests, CI) : on les corrige ou on en discute.

## 1. Stack & versions

**Politique de versions — toujours la dernière stable à l'`init`.** À la création d'un projet, on part de la **dernière version stable** de chaque techno, vérifiée sur sa **source officielle** au moment du init. On ne fige **aucun numéro** dans ce référentiel (il deviendrait obsolète) ; la version retenue est ensuite **épinglée dans le projet** via les lockfiles.

| Domaine | Techno | Où vérifier la dernière version stable |
| --- | --- | --- |
| Backend | PHP | https://www.php.net/supported-versions.php |
| Framework backend | Symfony | https://symfony.com/releases |
| Frontend | Vue | https://github.com/vuejs/core/releases |
| Meta-framework | Nuxt | https://github.com/nuxt/nuxt/releases |
| Runtime JS | Node.js | https://nodejs.org/en/about/previous-releases |
| Paquets PHP | Composer | https://github.com/composer/composer/releases |
| Paquets JS | pnpm | https://github.com/pnpm/pnpm/releases |
| Base de données | PostgreSQL | https://www.postgresql.org/support/versioning/ |

- On retient la **dernière version stable** publiée (pas nécessairement LTS) : pas de RC, beta ou nightly en production.
- Une fois choisie au init, la version est **épinglée** (lockfiles versionnés : `composer.lock`, `pnpm-lock.yaml`).
- **Le gestionnaire de paquets est lui-même versionné et épinglé** (pas seulement les dépendances) : pnpm via le champ `packageManager` de `package.json` + **Corepack** ; côté toolchain (Composer, Node, pnpm), la version est figée par les **tags d'image Docker** du projet (cf. §2).
- Toute montée de **version majeure** ultérieure = décision d'équipe + plan de migration.

## 2. Environnement local & outillage — tout passe par Docker

- La toolchain s'exécute **exclusivement** dans la stack Docker du projet (jamais sur l'hôte).
- Les commandes courantes passent par un `Makefile` / `compose` versionné (build, install, test, lint).
- Ne **pas** lancer `php`, `composer`, `node`, `pnpm`, `vendor/bin/*`, `vitest`, etc. directement sur la machine.
- Si un outil n'a pas de wrapper Docker : **on s'arrête et on demande**, on n'utilise pas le binaire local.

## 3. Conventions de code

### PHP / Symfony

- `declare(strict_types=1);` en tête de **chaque** fichier.
- Style **PER Coding Style** (la recommandation PHP-FIG qui remplace PSR-12 et PSR-2), appliqué automatiquement par `php-cs-fixer` via le ruleset `@PER-CS` (config versionnée). Le ruleset suit la dernière version du standard ; le formatage ne se règle pas à la main. Réf. : https://www.php-fig.org/per/coding-style/
- Analyse statique **PHPStan niveau 8** (minimum requis sur tout nouveau code), sans baseline qui grossit au fil du temps.
- **Contrôleurs fins** : aucune logique métier dedans → services / handlers dédiés.
- **Injection de dépendances par constructeur.** Pas de `new` sur un service, pas de service locator.
- Entités Doctrine sans logique d'infrastructure ; **migrations versionnées et revues** (jamais d'`update --force` en prod).
- DTO / Value Objects pour les payloads d'entrée et de sortie ; pas d'`array` mal typé qui traverse les couches.
- Exceptions **typées et métier**, jamais de `throw new \Exception('...')` générique.

### Vue / Nuxt

- **TypeScript strict**, composants en `<script setup lang="ts">`, **Composition API uniquement** (pas d'Options API en nouveau code).
- **ESLint + Prettier** (configs versionnées). Pas de `any` non justifié par un commentaire.
- Props typées, `emits` déclarés explicitement ; composants en `PascalCase`.
- État partagé via **Pinia** ; pas de store fourre-tout global.
- **SSR-safe** : pas d'accès direct à `window`/`document` hors `onMounted` ou `import.meta.client`.
- Data fetching via `useFetch` / `useAsyncData` / `$fetch` (ofetch natif) avec gestion explicite des états d'erreur et de chargement. **`axios` est proscrit** : on s'en tient au Fetch natif, aucun client HTTP tiers en dépendance directe.
- **Accessibilité (a11y)** et **i18n** pris en compte dès la conception, pas après coup.

## 4. Git & workflow

- **Conventional Commits** : `type(scope): description` — types `feat`, `fix`, `refactor`, `chore`, `test`, `docs`, `ci`, `perf`, `build`. Description courte, à l'impératif.
- Une **PR = un sujet**, petite et relisible. Au moins **une revue** approuvée avant merge.
- **Trunk-based** : une seule branche longue `main`, des branches de feature **très courtes** (≤ 1–2 jours) mergées vite après PR + CI verte. Pas de push direct sur `main`.
- Le travail inachevé est masqué par des **feature flags**, pas par des branches longue durée.
- La PR ne merge que si la **CI est verte** (cf. §6).

## 5. Tests

- Tout code de production est **testé**. Un bug corrigé s'accompagne d'un **test de non-régression**.
- **PHP** : PHPUnit (unitaires + fonctionnels). **Front** : Vitest (unit/composants) + Playwright (e2e).
- Tests **déterministes et rapides** : pas d'appel réseau réel, pas de dépendance à l'horloge ou à l'ordre d'exécution.
- Couverture cible : **80 %** (en priorité sur le code métier). La couverture reste un indicateur, pas une fin : 80 % de tests pertinents valent mieux que 100 % de tests cosmétiques.

## 6. Qualité & CI

Gates **bloquants** en CI, dans cet ordre : **format → lint → analyse statique (PHPStan) → typecheck (`vue-tsc`) → tests**.

- Rouge = pas de merge. On ne désactive pas une règle pour « faire passer ».
- Les mêmes commandes sont exécutables en local via Docker (cf. §2).

## 7. Sécurité & données (RGPD)

- **Aucun secret en clair** dans le dépôt : variables d'environnement / gestionnaire de secrets. Vérifier avant chaque commit.
- Dépendances **à jour** et auditées ; pas d'ajout de dépendance sans justification.
- Toute entrée externe est **validée et échappée** ; requêtes **préparées** côté SQL, jamais de concaténation.
- **Données personnelles** (contexte e-commerce) : minimisation, pas de PII dans les logs, conformité RGPD.

## 8. Observabilité

- Erreurs remontées à **Sentry** ; logs **structurés** et de niveau pertinent.
- Pas de `var_dump`, `dd()`, `console.log` de debug laissés dans le code livré.

## 9. Documentation & décisions

- Chaque projet a un **`README` à jour** : comment lancer, tester et déployer.
- Les décisions d'architecture notables sont consignées en **ADR** (`docs/adr/NNN-titre.md`).
