---
name: test
description: Écrit/complète et lance les tests couvrant la feature ou le fix en cours (unitaires, fonctionnels, e2e selon le périmètre), exclusivement via Docker. PHPUnit côté PHP, Vitest + Playwright côté front. Pour un bug, le test de non-régression est écrit AVANT le fix (red-green). Cible 80% sur le code métier. Ne lance pas le pipeline complet (c'est le rôle de `check`).
---

# test — écriture & exécution des tests

Couvre le changement en cours par des tests **pertinents et déterministes**.

## Périmètre

- **PHP** : PHPUnit (unitaires + fonctionnels).
- **Front** : Vitest (unit / composants), Playwright (e2e) si parcours utilisateur.

## Red-green pour les fixes

Un bug corrigé ⇒ **test de non-régression**. L'ordre compte : écrire d'abord le test qui **reproduit le bug et échoue** (rouge), puis appliquer/valider le correctif jusqu'au vert. Un test de non-régression qui n'a jamais été vu rouge ne prouve rien.

Dans le pipeline `feature`, cette phase passe **avant** `simplify` : le nettoyage s'appuie sur le filet des tests verts.

## Règles

- Tests **déterministes** : pas d'appel réseau réel, pas de dépendance à l'horloge ou à l'ordre d'exécution.
- Cible de couverture : **80 %**, en priorité sur le code métier (indicateur, pas une fin).
- Exécution **dans Docker** uniquement (`make` / `docker compose`), jamais sur l'hôte.

## Lancer les tests (Docker)

Détecter la stack (`composer.json` → PHP ; `nuxt.config.*`/dép `nuxt` → Nuxt ; `.vue` + `vite.config.*` sans Nuxt → Vue). Pour la **commande exacte** (cible `make` ou fallback `docker compose`), réutiliser les fiches du skill `check` (`php.md` / `nuxt.md` / `vue.md`). Ne rien lancer sur l'hôte.

Itérer vite : lancer d'abord le **fichier / cas ciblé**, puis la suite complète une fois vert.

## Sortie

Tests ajoutés + résultat d'exécution. Échecs remontés clairement.
