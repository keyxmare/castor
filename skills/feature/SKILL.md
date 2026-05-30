---
name: feature
description: Orchestrateur du workflow de dev complet — conception → planification → développement → durcissement (tests, nettoyage, audits conformité/sécurité/perf/a11y) → review → commit → push. Chemin rapide pour les changements triviaux. S'arrête aux gates de validation définis dans workflow.json. À invoquer pour développer une feature ou un fix de bout en bout ("/feature", "développe X", "implémente Y"). Les phases sont aussi disponibles seules via /design, /plan, /dev.
argument-hint: <description de la feature ou du fix>
---

# feature — orchestrateur du workflow

Déroule le cycle complet **conception → planification → développement → durcissement → review → commit → push**, en s'arrêtant aux gates de validation utilisateur.

## 0. Charger la configuration

Lire la config, par ordre de priorité :

1. `.claude/workflow.json` à la racine du projet courant (surcharge locale) ;
2. sinon le `workflow.json` du répertoire de configuration Claude actif (`${CLAUDE_CONFIG_DIR:-~/.claude}`) ;
3. sinon valeurs par défaut : `fastPath` actif, tous les gates `true`, `cleanup` actif, tous les audits actifs.

Clés :
- `gates` : un gate à `true` = **stop + validation explicite** avant la phase suivante ; `false` = on enchaîne.
- `cleanup` : `true` = passer le skill `simplify` en durcissement.
- `audits` : liste des **agents read-only** à lancer en durcissement (`standards`, `security`, `perf`, `correctness`, `a11y-i18n`).
- `fastPath` : `true` = autorise le chemin rapide (§0.ter).
- `branch.create` / `branch.base` : créer une branche de feature depuis `base` si on est dessus.

## 0.bis Branche de feature

Workflow trunk-based (CLAUDE.md §4) : on ne développe **jamais** sur `main`. Si `branch.create` est `true` et que la branche courante est `main`/`master` (ou `branch.base`), créer une branche courte avant tout dev :

```
git switch -c <type>/<sujet-court>
```

`<type>` ∈ `feat|fix|refactor|chore|docs|perf`. Si on est déjà sur une branche de feature, la réutiliser.

## 0.ter Chemin rapide (changement trivial)

Si `fastPath` est actif **et** que le changement est manifestement trivial (≤ ~quelques lignes, sans impact d'archi : typo, libellé, constante, petit fix localisé couvert par un test existant), **sauter `design` et `plan`** : aller directement à `dev` puis au durcissement allégé (test + `check`, audits selon pertinence). En cas de doute sur la trivialité → dérouler le pipeline complet. Annoncer explicitement le chemin choisi.

## 1. Conception → skill `design`

Invoquer `design`. Produit une approche technique argumentée (recherche déléguée à l'agent `Explore` si besoin). **Aucune édition de prod.** Pour une décision d'archi notable, `design` rédige aussi l'ADR (`docs/adr/NNN-*.md`, cf. CLAUDE.md §9).

**Gate `afterDesign`** : présenter l'approche, attendre validation avant de continuer.

## 2. Planification → skill `plan`

Invoquer `plan`. Découpe l'approche validée en étapes ordonnées + liste de tâches.

**Gate `afterPlan`** : présenter le plan, attendre validation.

## 3. Développement → skill `dev`

Invoquer `dev`. Implémente le plan étape par étape, en respectant `CLAUDE.md`.

## 4. Durcissement (automatique)

Ordre **important** — on sécurise par les tests avant de toucher au code :

1. **Tests d'abord** → skill `test`. Pour un **fix**, écrire le test de non-régression qui **échoue avant** le correctif (red-green). Amener la suite ciblée au vert.
2. **Nettoyage** (si `cleanup` actif) → skill `simplify` (édite : code mort + simplification), **sous filet des tests** de l'étape 1.
3. **Re-test** après `simplify` : confirmer que le comportement est inchangé (tests toujours verts).
4. **Audits** (read-only) → lancer **en parallèle** (tous les appels `Agent` dans **un seul message**) les agents dont la clé figure dans `audits`. Chacun renvoie ses findings, **n'édite rien**. Mapping :
   - `standards`   → `standards-auditor` (conformité `CLAUDE.md`) ;
   - `security`    → `security-auditor` ;
   - `perf`        → `perf-auditor` ;
   - `correctness` → `reviewer` ;
   - `a11y-i18n`   → `a11y-i18n-auditor` (front Vue/Nuxt).
5. **Appliquer** les corrections issues des findings.
6. **Convergence** : si l'étape 5 a modifié du code de prod de façon non triviale, **relancer les audits concernés** sur le nouveau diff. Boucler jusqu'à ne laisser que des findings acceptés/justifiés.
7. **Doc** : si le changement modifie la façon de lancer / tester / déployer, mettre le **README à jour** (CLAUDE.md §9).
8. **Gates qualité** → skill `check` (format → lint → analyse statique → typecheck → tests, dans Docker). Stop à la première erreur, corriger, relancer.

## 5. Review → synthèse (auto-review)

Présenter une **auto-review** : le diff de la feature (`git diff $(git merge-base HEAD <base>)..HEAD` + working tree), le résultat des tests, et les findings d'audit (résolus / restants justifiés).

> Cette review est l'auto-contrôle de Claude. Elle **ne remplace pas** la revue humaine sur la PR exigée par CLAUDE.md §4.

**Gate `afterReview`** : attendre validation avant de committer.

## 6. Commit → skill `commit`

Invoquer `commit` (Conventional Commits). Plusieurs sujets distincts → plusieurs commits. Le hook `commit-gate` rebloque si les gates échouent.

**Gate `beforeCommit`** : si actif, présenter le message proposé + le diff stagé, attendre le feu vert avant de créer le commit.

## 7. Push / PR

Pousser la branche : `git push -u origin <branche>`. **Ne pas créer la PR automatiquement** : proposer à l'utilisateur d'ouvrir la PR (une PR = un sujet, revue humaine avant merge — CLAUDE.md §4) et fournir un titre + résumé prêts à coller.

## Règles

- On ne saute jamais un gate `true` en silence.
- Toute modification respecte `CLAUDE.md` (code EN, zéro commentaire, conventions stack).
- Si une phase bloque, s'arrêter et remonter le problème — ne pas contourner.
