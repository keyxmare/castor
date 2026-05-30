---
name: commit
description: Stage et crée un commit (Conventional Commits) pour les changements en cours. Pré-requis OBLIGATOIRE — invoquer `check` d'abord ; ne jamais committer si un gate échoue (le hook commit-gate rebloque de toute façon). À utiliser pour "commit", "fais un commit", "/commit".
---

# commit

Crée un commit propre des changements en cours.

## Pré-requis obligatoire

Invoquer **`check`** d'abord. Si un gate échoue → **ne pas committer**, corriger. Le hook `commit-gate` rebloque le commit si `check` est rouge.

## Procédure

1. Vérifier `git status` / `git diff` ; ne stager que ce qui appartient au changement.
2. Rédiger un message **Conventional Commits** : `type(scope): description` (impératif, anglais). Types : `feat`, `fix`, `refactor`, `chore`, `test`, `docs`, `ci`, `perf`, `build`.
3. Plusieurs sujets distincts → plusieurs commits.
4. Committer sur une **branche** (jamais directement sur `main` — workflow trunk-based, cf. §4).

## Règles

- Pas de secret dans le diff (cf. §7).
- Pas de code commenté ni de debug (`dd()`, `console.log`) dans le commit.
