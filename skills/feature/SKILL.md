---
name: feature
description: Orchestrateur du workflow de dev complet — conception → planification → développement → durcissement (tests, nettoyage, audits conformité/sécurité/perf) → review → commit. S'arrête aux gates de validation définis dans workflow.json. À invoquer pour développer une feature ou un fix de bout en bout ("/feature", "développe X", "implémente Y"). Les phases sont aussi disponibles seules via /design, /plan, /dev.
argument-hint: <description de la feature ou du fix>
---

# feature — orchestrateur du workflow

Déroule le cycle complet **conception → planification → développement → durcissement → review → commit**, en s'arrêtant aux gates de validation utilisateur.

## 0. Charger la configuration

Lire la config des gates et des audits, par ordre de priorité :

1. `.claude/workflow.json` à la racine du projet courant (surcharge locale) ;
2. sinon le `workflow.json` à la racine du répertoire de configuration Claude actif (`~/.claude` ou `~/.claude-motoblouz` selon le profil) ;
3. sinon valeurs par défaut : tous les gates `true`, tous les audits actifs.

Un gate à `true` = **stop + demande de validation explicite** avant la phase suivante. Un gate à `false` = on enchaîne sans s'arrêter.

## 1. Conception → skill `design`

Invoquer `design`. Produit une approche technique argumentée (recherche déléguée à l'agent `Explore` si besoin). **Aucune édition de prod.**

**Gate `afterDesign`** : présenter l'approche, attendre validation avant de continuer.

## 2. Planification → skill `plan`

Invoquer `plan`. Découpe l'approche validée en étapes ordonnées + liste de tâches.

**Gate `afterPlan`** : présenter le plan, attendre validation.

## 3. Développement → skill `dev`

Invoquer `dev`. Implémente le plan étape par étape, en respectant `CLAUDE.md`.

## 4. Durcissement (automatique)

Dans l'ordre :

1. Audit `deadcode` actif → skill `simplify` (édite : nettoyage code mort + simplification).
2. Skill `test` (écrit/complète et lance les tests).
3. **Lancer les agents d'audit actifs** via l'outil **`Agent`** (un appel par agent, avec le `subagent_type` correspondant). Les émettre **en parallèle** : tous les appels `Agent` dans **un seul message**. Chaque agent est read-only et renvoie ses findings (il n'édite rien). Mapping audit → `subagent_type` :
   - `standards`   → `standards-auditor` (conformité `CLAUDE.md`) ;
   - `security`    → `security-auditor` ;
   - `perf`        → `perf-auditor` ;
   - `correctness` → `reviewer`.

   N'appeler que les agents dont la clé figure dans `audits` (cf. §0).
4. Agréger les findings et appliquer les corrections nécessaires.
5. Skill `check` (format → lint → analyse statique → tests, dans Docker). Stop à la première erreur, corriger, relancer.

## 5. Review → synthèse

Présenter : le diff, le résultat des tests, et les findings d'audit (résolus / restants).

**Gate `afterReview`** : attendre validation avant de committer.

## 6. Commit → skill `commit`

Invoquer `commit` (Conventional Commits). Le hook `commit-gate` rebloque si `check` échoue.

**Gate `beforeCommit`** : si actif, présenter le message de commit proposé + le diff stagé, attendre le feu vert avant de créer le commit.

## Règles

- On ne saute jamais un gate `true` en silence.
- Toute modification respecte `CLAUDE.md` (code EN, zéro commentaire, conventions stack).
- Si une phase bloque, s'arrêter et remonter le problème — ne pas contourner.
