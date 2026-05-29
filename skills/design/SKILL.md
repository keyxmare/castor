---
name: design
description: Phase de conception — comprend la demande, explore le code existant (agent Explore) et propose une approche technique argumentée AVANT toute écriture de code de prod. Utilisable seule ou via l'orchestrateur `feature`. S'arrête pour validation utilisateur.
---

# design — conception

Objectif : transformer une demande en **approche technique validée**, sans écrire de code de prod.

## Procédure

1. **Clarifier la demande.** Reformuler le besoin et le résultat attendu ; lever les ambiguïtés (poser des questions si nécessaire).
2. **Explorer l'existant.** Déléguer la recherche via l'outil `Agent` (`subagent_type: Explore`) : conventions, code réutilisable, points d'intégration. Ne lire en détail que les fichiers pivots.
3. **Proposer une approche.** Décrire la solution : composants touchés, contrats/API, modèle de données, impacts, et alternatives écartées (avec le pourquoi). S'aligner sur `CLAUDE.md` (stack, archi, conventions).
4. **Risques & inconnues.** Lister ce qui pourrait coincer.

## Sortie

Une note de conception concise : approche retenue + alternatives + risques. **Aucune édition de fichier de prod.**

## Gate

Présenter l'approche et **attendre la validation** avant de planifier ou développer.
