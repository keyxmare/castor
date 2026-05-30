# allo-claude — standards techniques de l'équipe

Ce dépôt héberge le **référentiel de standards techniques** du SI, sous forme d'un
`CLAUDE.md` versionné. C'est une **configuration « globale » mais partagée et revue en équipe** :
chaque dev la lie à sa config Claude Code locale, et les règles s'appliquent alors à tous ses projets.

## Contenu

| Fichier | Rôle |
| --- | --- |
| `CLAUDE.md` | Les standards techniques (stack, conventions, git, tests, sécurité…). **Le cœur du dépôt.** |
| `skills/` | Skills du workflow de dev (orchestrateur `feature` + phases + qualité + `triage` Sentry). |
| `agents/` | Subagents d'audit (conformité, sécurité, perf, correctness, a11y/i18n). |
| `hooks/` | Scripts de hooks (`commit-gate.sh`, `protect-main.sh`). |
| `templates/` | Gabarits à copier dans un projet : `Makefile`, CI GitHub Actions, `mcp.json`. |
| `workflow.json` | Config par défaut : chemin rapide, gates, nettoyage, audits. |
| `settings.json` | Réglages Claude Code partagés (permissions + hooks). Optionnel à diffuser. |
| `install.sh` | Crée les symlinks vers `~/.claude/` (sauvegarde l'existant, purge les liens orphelins). |
| `.gitignore` | Ignore les réglages par machine (`settings.local.json`) et les secrets. |

## Installation (par dev)

```bash
./install.sh
```

Cela lie `~/.claude/CLAUDE.md` → ce dépôt (et les skills/agents/hooks/workflow). Les standards sont
dès lors chargés automatiquement par Claude Code sur **tous vos projets**. L'install **purge** au
passage les symlinks orphelins (skills/agents renommés ou supprimés). Respecte `CLAUDE_CONFIG_DIR`
si vous utilisez un répertoire de config alternatif.

> Pour lier aussi `settings.json`, lancez `LINK_SETTINGS=1 ./install.sh`.
> ⚠️ Cela **remplace** (symlink, pas de merge) votre `settings.json` global ; l'existant non-symlink
> est sauvegardé en `.bak`. Sans écrasement, copiez plutôt le contenu dans `.claude/settings.json`
> de chaque projet.

### Alternative : import par projet

Ajoutez dans le `CLAUDE.md` d'un projet une ligne d'import :

```
@~/Projects/github.com/keyxmare/allo-claude/CLAUDE.md
```

## Démarrer un projet conforme

Les skills `check` / `test` et le hook `commit-gate` s'appuient sur des cibles `make`. Pour qu'un
projet soit réellement « gardé », copiez les gabarits de `templates/` et adaptez-les :

- **`templates/Makefile`** → racine du projet. Fournit `check-fast` (format + lint + analyse statique
  + typecheck, **sans tests**) et `check` (suite complète). Adapter `PHP_SVC` / `NODE_SVC`.
- **`templates/ci.github-actions.yml`** → `.github/workflows/ci.yml`. La CI exécute exactement les
  mêmes cibles `make` qu'en local (zéro écart local/CI), dans l'ordre §6.
- **`templates/mcp.json`** → `.mcp.json` du projet (ou config MCP perso). Branche GitHub + Sentry
  (observabilité §8), exploités par le skill `triage`.

## Workflow de dev (`/feature`)

Pipeline outillé : **conception → planification → développement → durcissement → review → commit → push**, avec gates configurables et **chemin rapide** pour les changements triviaux.

```
0.   BRANCHE ........ crée une branche de feature si on est sur main      (auto)
0.b  FAST PATH ...... changement trivial → saute design/plan              (auto)
1.   CONCEPTION ..... /design  → approche (+ ADR si notable)             [GATE]
2.   PLANIFICATION .. /plan    → découpe en tâches                       [GATE]
3.   DÉVELOPPEMENT .. /dev     → implémente
4.   DURCISSEMENT ... test → simplify → re-test → audits (//) → fix
                      → re-audit (convergence) → doc → check              (auto)
5.   REVIEW ......... auto-review : diff + tests + findings              [GATE]
6.   COMMIT ......... /commit  (hook commit-gate)                        [GATE]
7.   PUSH / PR ...... push ; propose la PR (jamais créée d'office)
```

- **Orchestrateur** : `/feature "ma feature"`. Chaque phase est aussi un skill seul (`/design`, `/plan`, `/dev`, `/test`, `/check`, `/commit`, `/simplify`).
- **L'auto-review (étape 5) ne remplace pas** la revue humaine sur la PR (CLAUDE.md §4).
- **Ordre du durcissement** : les tests passent **avant** `simplify` (nettoyage sous filet) ; pour un fix, le test de non-régression est écrit **rouge avant** le correctif.
- **Audits** read-only lancés en parallèle, sur le **périmètre complet de la branche** (`git diff main...HEAD` + working tree). Agents : `standards-auditor`, `security-auditor`, `perf-auditor`, `reviewer` (correctness), `a11y-i18n-auditor`.
- **`/triage <issue>`** : de l'erreur Sentry au fix testé (reproduction → test rouge → fix via `feature`).

### Configuration (`workflow.json`, ou `.claude/workflow.json` par projet)

```json
{
  "fastPath": true,
  "branch": { "create": true, "base": "main" },
  "gates":  { "afterDesign": true, "afterPlan": true, "afterReview": true, "beforeCommit": true },
  "cleanup": true,
  "audits": ["standards", "security", "perf", "correctness", "a11y-i18n"]
}
```

- `fastPath` : autorise le chemin rapide pour les changements triviaux.
- `gates` : `false` pour ne pas s'arrêter à une étape.
- `cleanup` : passe `simplify` en durcissement (`false` pour le désactiver).
- `audits` : agents read-only à lancer (retirer une clé pour désactiver l'audit).

### Hooks (`PreToolUse` sur `git commit`)

- **`commit-gate`** : lance `make check-fast` (à défaut `make check`) avant le commit ; bloque si rouge. La suite complète (tests) tourne au push / en CI. **Non silencieux** : si le projet n'a pas de cible `make`, il prévient que les gates ne sont pas exécutés (au lieu de laisser croire que c'est gardé).
- **`protect-main`** : interdit un commit direct sur `main`/`master` (trunk-based §4).

Actifs uniquement si vous liez `settings.json` (`LINK_SETTINGS=1 ./install.sh`).

> **Note sécurité.** La `deny`-list de `settings.json` (force-push) est un garde-fou *anti-accident*,
> pas une frontière de sécurité (un matching de chaîne se contourne). La vraie protection des
> branches passe par les **branch protection rules** GitHub + la revue de PR.

> **Skills natifs vs maison.** Claude Code fournit des skills proches (`/code-review`, `/review`,
> `/simplify`). Les versions de ce dépôt sont **alignées sur `CLAUDE.md`** (ordre des gates Docker,
> code EN sans commentaire, périmètre branche) et orchestrées par `feature` ; c'est ce qui justifie
> de les maintenir ici.

## Faire évoluer les standards

1. Créer une branche.
2. Modifier `CLAUDE.md` (ou les skills/agents).
3. Ouvrir une PR → revue d'équipe → merge.

Chaque dev récupère ensuite la mise à jour via `git pull` (le symlink pointe vers le fichier du dépôt).

## À compléter

Le `CLAUDE.md` contient des marqueurs `⚠️ À COMPLÉTER` pour les décisions propres à l'équipe
(versions exactes, gestionnaire de paquets JS, seuils de couverture, stratégie de branches…).
À trancher ensemble avant adoption.
