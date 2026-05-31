---
name: dev
description: Phase de développement — implémente le plan validé, étape par étape, en respectant strictement CLAUDE.md (code EN sans commentaire, conventions PHP/Symfony & Vue/Nuxt, toolchain Docker). Utilisable seule ou via `feature`. Ne committe pas (rôle de `commit`).
---

# dev — développement

Implémente le plan validé, **une étape à la fois**.

## Règles

- Respecter `CLAUDE.md` : code et identifiants en **anglais**, **zéro commentaire** (code auto-explicite), conventions PHP/Symfony (PER-CS, `strict_types`, contrôleurs fins, DI par constructeur, exceptions typées) et Vue/Nuxt (`<script setup lang="ts">`, Composition API, Pinia, SSR-safe).
- Coller au **style du code environnant**.
- Toolchain **exclusivement dans Docker** (cf. §2 du référentiel) : ne rien lancer sur l'hôte.
- Après chaque étape, vérifier compilation / typecheck via la stack Docker du projet.

## Sortie

Le code implémenté, prêt pour la phase de durcissement (tests + audits). **Ne pas committer ici.**
