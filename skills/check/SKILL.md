---
name: check
description: Lance les gates qualité — formatter → lint → analyse statique → tests — exclusivement dans la stack Docker du projet. Skill DISPATCHER : détecte la/les techno(s) présentes et charge uniquement la fiche correspondante (php.md, nuxt.md, vue.md) avec les commandes concrètes. S'arrête à la première erreur. Pré-requis obligatoire du `commit`.
---

# check — gates qualité (Docker, dispatcher)

Lance **format → lint → analyse statique → tests** sur le code en cours, **exclusivement via Docker**. Skill **dispatcher** : détecte les technos présentes et charge **uniquement** la fiche concernée.

## Règle d'or — tout dans Docker

Aucune commande de toolchain sur l'hôte (`php`, `composer`, `vendor/bin/*`, `node`, `pnpm`, `npx`, `phpstan`, `php-cs-fixer`, `vitest`, `eslint`, `vue-tsc`…). Tout via `make` (qui appelle `docker compose …`) ou `docker compose exec|run --rm <service> …`. Pas de wrapper Docker pour un outil → **stop et demander**.

## 1. Détecter la stack

| Indice | Fiche à charger |
| --- | --- |
| `composer.json` | `php.md` |
| `nuxt.config.*` ou dép `nuxt` dans `package.json` | `nuxt.md` |
| `.vue` + `vite.config.*` (et **pas** de Nuxt) | `vue.md` |

Lire **uniquement** les fiches concernées via `Read` — elles sont **dans ce dossier de skill** (`php.md`, `nuxt.md`, `vue.md`). Plusieurs technos peuvent coexister (monorepo). Aucune techno connue → demander.

## 2. Localiser la stack Docker

- Repérer `Makefile` / `compose.yaml` et le(s) service(s) applicatif(s).
- Pour chaque cible `make` candidate, **lire la recette** et confirmer qu'elle passe par Docker. Une recette qui appelle `vendor/bin/...` ou `pnpm` en direct → non conforme, signaler.
- Stack non démarrée (`is not running`, `No such container`) → utiliser `docker compose run --rm`, ne pas se rabattre sur l'hôte.

## 3. Exécuter (ordre commun)

1. **Formatter** — peut modifier des fichiers → les signaler.
2. **Lint / analyse statique**.
3. **Tests**.

Commandes exactes : dans la fiche techno. S'arrêter à la première erreur ; ne pas relancer une étape déjà verte si rien n'a bougé.

## 4. Sortie

Statut par techno et par famille (✓ / ✗), fichiers modifiés par le formatter, sortie utile en cas de ✗. Le caller (ex. `commit`) décide de la suite.

## 5. Étendre

Nouvelle techno → créer une fiche `<tech>.md` **dans ce dossier de skill** (table outils / cibles `make` probables / fallback `docker compose`) + une ligne dans la table §1. Garder ce `SKILL.md` mince.
