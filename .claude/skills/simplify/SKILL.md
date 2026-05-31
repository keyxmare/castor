---
name: simplify
description: Nettoie le code mort et simplifie le diff en cours — supprime code/imports/variables inutilisés, factorise les répétitions, réduit la complexité, aligne sur CLAUDE.md (zéro commentaire, code auto-explicite). Qualité uniquement, sans changer le comportement (ne cherche pas les bugs — c'est le rôle de l'agent `reviewer`).
---

# simplify — nettoyage & simplification

Améliore la qualité du code en cours **sans changer son comportement**.

## Cibles

- **Code mort** : fonctions, variables, imports, branches jamais atteints.
- **Duplication** : factoriser ce qui se répète.
- **Complexité** : aplatir l'imbriqué, early-returns, nommer l'intention.
- **Conformité `CLAUDE.md`** : supprimer les commentaires (code auto-explicite), repasser identifiants/strings en anglais si besoin.

## Règles

- Comportement **inchangé** : les tests doivent rester verts.
- Ne pas chasser les bugs ici (rôle de l'agent `reviewer`).
- Pas de refonte d'architecture non demandée.
