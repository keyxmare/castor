# AGENTS.md — consignes pour les assistants IA

> Point d'entrée **inter-outils** (Codex, Gemini, et tout assistant lisant `AGENTS.md`).
> Le **référentiel de standards qui fait foi** est [`.claude/CLAUDE.md`](.claude/CLAUDE.md) :
> **lis-le et applique-le** intégralement. Ce fichier en rappelle les garde-fous non
> négociables et précise ce qui n'est pas portable hors Claude Code.

## Garde-fous non négociables

- **Toolchain 100 % Docker.** Ne lance **jamais** `php`, `composer`, `node`, `pnpm`,
  `vendor/bin/*`, `vitest`, etc. sur l'hôte. Tout passe par le `Makefile` (`make build`,
  `make install`, `make check`, `make test`, `make e2e`). Pas de wrapper Docker → on s'arrête
  et on demande.
- **Code et identifiants en anglais. Zéro commentaire** : le code est auto-explicite (nommage
  parlant, fonctions courtes, comportement couvert par les tests). La doc projet (README, ADR)
  reste en français.
- **Front** : TypeScript strict, `<script setup lang="ts">`, Composition API, Pinia,
  **SSR-safe**. Data fetching via `useFetch` / `useAsyncData` / `$fetch` — **`axios` proscrit**,
  Fetch natif uniquement.
- **Back** : `declare(strict_types=1);` partout, PER Coding Style (`php-cs-fixer`), PHPStan
  niveau 8 sans baseline, contrôleurs fins, injection par constructeur, exceptions typées.
- **Git** : Conventional Commits (`type(scope): description`). **Trunk-based** : jamais de
  commit direct sur `main`, on travaille sur une branche de feature courte.
- **CI bloquante**, dans l'ordre : **format → lint → analyse statique (PHPStan) → typecheck
  (`vue-tsc`) → tests**. Rouge = pas de merge ; on ne désactive pas une règle pour « faire passer ».
- **Sécurité / RGPD** : aucun secret en clair (variables d'environnement / gestionnaire de
  secrets), entrées externes validées et échappées, requêtes SQL préparées, pas de PII dans les logs.

## Ce qui n'est pas portable hors Claude Code

La configuration `.claude/` contient des mécanismes **spécifiques à Claude Code**, sans
équivalent automatique sous Codex/Gemini :

- **Subagents d'audit** (`.claude/agents/` : standards, sécurité, perf, correctness, a11y/i18n) :
  pas de lancement parallèle → réalise l'audit correspondant **en passe inline** avant de livrer.
- **Hooks** (`.claude/hooks/` : `commit-gate.sh`, `protect-main.sh`) : **non exécutés**. À la
  main, donc : lance **`make check-fast`** avant chaque commit et **ne committe jamais sur `main`**.

Le **vrai garde-fou inter-outils** reste la **CI + la protection de branche** : tant qu'elle
n'est pas verte, rien ne merge, quel que soit l'assistant.

## Workflow attendu

Le dépôt câble un workflow outillé (skills `.claude/skills/`, repris en commandes Gemini
`.gemini/commands/` et en skills Codex `.codex/skills/`) : **conception → planification →
développement → durcissement (tests, nettoyage, audits) → review → commit → push**, avec des
points d'arrêt pour validation humaine. Suis cette discipline même quand l'outillage n'est pas
exécutable nativement.

## Serveurs MCP

Le dépôt fournit les serveurs MCP **GitHub** et **Sentry** (cf. `.mcp.json`, `.codex/config.toml`,
`.gemini/settings.json`). Sous **Codex**, ils ne sont chargés que pour un projet **trusted** :
approuve le projet une fois.
