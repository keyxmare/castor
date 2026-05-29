# allo-claude — standards techniques de l'équipe

Ce dépôt héberge le **référentiel de standards techniques** du SI, sous forme d'un
`CLAUDE.md` versionné. C'est une **configuration « globale » mais partagée et revue en équipe** :
chaque dev la lie à sa config Claude Code locale, et les règles s'appliquent alors à tous ses projets.

## Contenu

| Fichier | Rôle |
| --- | --- |
| `CLAUDE.md` | Les standards techniques (stack, conventions, git, tests, sécurité…). **Le cœur du dépôt.** |
| `skills/` | Skills du workflow de dev (orchestrateur `feature` + phases + qualité). |
| `agents/` | Subagents d'audit (conformité, sécurité, perf, correctness). |
| `hooks/` | Scripts de hooks (ex. `commit-gate.sh`). |
| `workflow.json` | Config par défaut des gates de validation et des audits. |
| `settings.json` | Réglages Claude Code partagés (permissions + hook commit-gate). Optionnel à diffuser. |
| `install.sh` | Crée les symlinks vers `~/.claude/` (avec sauvegarde de l'existant). |
| `.gitignore` | Ignore les réglages par machine (`settings.local.json`) et les secrets. |

## Installation (par dev)

```bash
./install.sh
```

Cela lie `~/.claude/CLAUDE.md` → ce dépôt. Les standards sont dès lors chargés
automatiquement par Claude Code sur **tous vos projets**.

> Pour lier aussi `settings.json`, lancez `LINK_SETTINGS=1 ./install.sh`
> (⚠️ cela écrase vos réglages globaux personnels).

### Alternative : import par projet

Si vous préférez n'appliquer les standards qu'à certains projets, plutôt que le symlink global,
ajoutez dans le `CLAUDE.md` d'un projet une ligne d'import :

```
@~/Projects/github.com/keyxmare/allo-claude/CLAUDE.md
```

## Workflow de dev (`/feature`)

Pipeline outillé : **conception → planification → développement → durcissement → review → commit**, avec gates de validation configurables.

```
1. CONCEPTION ...... /design  → propose une approche            [GATE]
2. PLANIFICATION ... /plan    → découpe en tâches               [GATE]
3. DÉVELOPPEMENT ... /dev     → implémente
4. DURCISSEMENT .... simplify + test + audits (//) + check       (auto)
5. REVIEW .......... synthèse des findings + diff               [GATE]
6. COMMIT .......... /commit  (hook commit-gate)                [GATE]
```

- **Orchestrateur** : `/feature "ma feature"` déroule tout. Chaque phase est aussi un skill seul (`/design`, `/plan`, `/dev`, `/test`, `/check`, `/commit`, `/simplify`).
- **Audits** (read-only, lancés en parallèle) : agents `standards-auditor` (conformité CLAUDE.md), `security-auditor`, `perf-auditor`, `reviewer` (correctness).
- **Gates configurables** dans `workflow.json` (ou `.claude/workflow.json` par projet) :

```json
{
  "gates":  { "afterDesign": true, "afterPlan": true, "afterReview": true, "beforeCommit": true },
  "audits": ["deadcode", "standards", "security", "perf", "correctness"]
}
```

Mettez un gate à `false` pour ne pas vous arrêter à cette étape ; retirez un audit de la liste pour le désactiver.

- **Hook `commit-gate`** : bloque `git commit` si `make check` échoue. ⚠️ Actif uniquement si vous liez aussi `settings.json` (`LINK_SETTINGS=1 ./install.sh`).

## Faire évoluer les standards

1. Créer une branche.
2. Modifier `CLAUDE.md`.
3. Ouvrir une PR → revue d'équipe → merge.

Chaque dev récupère ensuite la mise à jour via `git pull` (le symlink pointe vers le fichier du dépôt).

## À compléter

Le `CLAUDE.md` contient des marqueurs `⚠️ À COMPLÉTER` pour les décisions propres à l'équipe
(versions exactes, gestionnaire de paquets JS, seuils de couverture, stratégie de branches…).
À trancher ensemble avant adoption.
