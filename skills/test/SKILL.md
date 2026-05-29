---
name: test
description: Écrit/complète et lance les tests couvrant la feature ou le fix en cours (unitaires, fonctionnels, e2e selon le périmètre), exclusivement via Docker. PHPUnit côté PHP, Vitest + Playwright côté front. Cible 80% sur le code métier. Ne lance pas le pipeline complet (c'est le rôle de `check`).
---

# test — écriture & exécution des tests

Couvre le changement en cours par des tests **pertinents et déterministes**.

## Périmètre

- **PHP** : PHPUnit (unitaires + fonctionnels).
- **Front** : Vitest (unit / composants), Playwright (e2e) si parcours utilisateur.
- Un bug corrigé ⇒ **test de non-régression** qui échoue avant le fix.

## Règles

- Tests **déterministes** : pas d'appel réseau réel, pas de dépendance à l'horloge ou à l'ordre d'exécution.
- Cible de couverture : **80 %**, en priorité sur le code métier (indicateur, pas une fin).
- Exécution **dans Docker** uniquement (`make` / `docker compose`), jamais sur l'hôte.

## Lancer les tests (Docker)

Détecter la stack (`composer.json` → PHP ; `nuxt.config.*`/dép `nuxt` → Nuxt ; `.vue` + `vite.config.*` sans Nuxt → Vue). Pour la **commande exacte** (cible `make` ou fallback `docker compose`), réutiliser les fiches du skill `check` (`php.md` / `nuxt.md` / `vue.md`). Ne rien lancer sur l'hôte.

Itérer vite : lancer d'abord le **fichier / cas ciblé**, puis la suite complète une fois vert.

## Sortie

Tests ajoutés + résultat d'exécution. Échecs remontés clairement.
