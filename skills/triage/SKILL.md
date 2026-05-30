---
name: triage
description: Ferme la boucle observabilité (CLAUDE.md §8) — part d'une erreur Sentry, la comprend via le MCP Sentry (stack trace, occurrences, release, contexte), reproduit, écrit un test de non-régression rouge, puis enchaîne sur le fix via `feature`. À invoquer pour "triage", "regarde l'erreur Sentry X", "/triage <issue>".
argument-hint: <id ou URL de l'issue Sentry>
---

# triage — de l'erreur Sentry au fix testé

Transforme une erreur de production remontée à **Sentry** (§8) en correctif testé, sans court-circuiter le workflow.

## Pré-requis

Le MCP Sentry doit être disponible (cf. `templates/mcp.json`). Sinon, demander à l'utilisateur de le configurer ou fournir manuellement la stack trace.

## Procédure

1. **Récupérer l'issue.** Via les outils MCP Sentry : détails de l'issue, dernier événement, **stack trace**, fréquence/occurrences, **release** et environnement concernés, breadcrumbs/contexte. Si un outil d'analyse automatique (type Seer) est disponible, s'en servir comme piste — pas comme vérité.
2. **Localiser dans le code.** Relier la stack trace aux fichiers du dépôt (frame applicative la plus haute). Lire le code incriminé et son contexte.
3. **Diagnostiquer.** Formuler la cause racine probable et les conditions de déclenchement (entrée nulle, cas limite, concurrence…). Distinguer le constaté du supposé.
4. **Reproduire par un test.** Écrire un test de non-régression qui **reproduit l'erreur et échoue** (red). C'est la preuve du diagnostic.
5. **Corriger.** Enchaîner sur le skill `feature` (chemin rapide si le fix est localisé) pour implémenter le correctif, repasser le test au vert, durcir et committer. Le message de commit `fix(...)` référence l'issue Sentry.

## Données personnelles

Le contexte Sentry peut contenir des **PII** (§7). Ne pas les recopier dans le code, les tests ou les commits ; n'utiliser que des données anonymisées pour reproduire.

## Sortie

Diagnostic (cause racine + déclencheur), test rouge qui reproduit, puis fix vert via `feature`.
