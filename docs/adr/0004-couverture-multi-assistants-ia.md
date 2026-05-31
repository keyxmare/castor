# ADR 0004 — Couverture multi-assistants IA (Claude, Codex, Gemini)

- Statut : accepté
- Date : 2026-05-31

## Contexte

Castor embarque la configuration IA de l'équipe **versionnée et auto-chargée** (cf.
[`0001`](0001-stack-et-archi.md)). Cette config est aujourd'hui **mono-assistant** :
tout vit dans `.claude/` (standards `CLAUDE.md`, skills, agents, hooks, settings) et
`.mcp.json`. Quiconque ouvre le dépôt avec **Codex** (OpenAI) ou **Gemini** (Google)
n'hérite ni des standards d'équipe, ni des serveurs MCP, ni des garde-fous.

On veut couvrir ces assistants **sans dupliquer les standards de façon divergente** :
`CLAUDE.md` doit rester la **source unique** du référentiel.

Conventions vérifiées sur les sources officielles au moment de la décision :

| Outil | Standards (mémoire) | Config projet versionnée | Commandes/skills versionnables |
| --- | --- | --- | --- |
| Codex CLI | `AGENTS.md` (fusionné racine→dossier, lu nativement) | `.codex/config.toml` (chargé si projet *trusted*) | `.codex/skills/<nom>/SKILL.md` (`SKILL.md` = standard inter-agents) |
| Gemini CLI | `GEMINI.md` par défaut, redéfinissable via `context.fileName` | `.gemini/settings.json` (auto-chargé par projet) | `.gemini/commands/<nom>.toml` (injection `@{fichier}`, args `{{args}}`) |

Les prompts custom Codex sont **dépréciés** et **non versionnables** (`~/.codex/prompts`
seulement) ; le véhicule repo-partageable est désormais le **skill** (`SKILL.md`).

## Décision

### `AGENTS.md` = point d'entrée inter-outils unique ; `CLAUDE.md` fait foi

Un seul `AGENTS.md` à la racine sert de point d'entrée à tout assistant. Il **renvoie à
`.claude/CLAUDE.md` comme référentiel faisant foi** et rappelle inline les garde-fous **non
négociables** (toolchain Docker exclusive, code EN sans commentaire, Fetch natif, Conventional
Commits, trunk-based, ordre des gates CI, secrets/PII). Pas de `GEMINI.md` : Gemini est pointé
sur `AGENTS.md` via `context.fileName` dans `.gemini/settings.json`. Codex lit `AGENTS.md`
nativement.

### MCP rejoué par outil, miroir de `.mcp.json`

Les serveurs `github` et `sentry` sont déclarés dans chaque format natif :
`.gemini/settings.json` (`mcpServers` en `httpUrl`) et `.codex/config.toml`
(`[mcp_servers.<id>]` en `url`).

### Workflow porté sans duplication de logique

`SKILL.md` étant un standard inter-agents, la logique des skills reste **unique** dans
`.claude/skills/` :

- **Gemini** : `.gemini/commands/<nom>.toml` minces — le `prompt` injecte la SKILL.md
  canonique via `@{.claude/skills/<nom>/SKILL.md}` et passe `{{args}}`.
- **Codex** : `.codex/skills/<nom>/SKILL.md` minces — délèguent au fichier canonique
  `.claude/skills/<nom>/...`.

### Frontière de portabilité assumée

Ne sont **pas** réplicables hors Claude Code et restent Claude-only :

- **Subagents d'audit** (standards/security/perf/correctness/a11y-i18n) : sous Codex/Gemini,
  l'audit se fait en passe inline.
- **Hooks** (`commit-gate.sh`, `protect-main.sh`) : non exécutés → sous Codex/Gemini, lancer
  `make check-fast` explicitement avant commit et ne jamais committer sur `main`.

Le **vrai garde-fou inter-outils** reste la **CI + la protection de branche** (rouge = pas de
merge), indépendante de l'assistant.

## Alternatives écartées

- **Symlinks `AGENTS.md`/`GEMINI.md` → `CLAUDE.md`** : zéro drift mais fragile sous Windows ;
  l'entête de `CLAUDE.md` est rédigé « pour Claude Code ».
- **Copie complète des standards par fichier** : duplication divergente garantie — l'inverse
  de l'objectif.
- **Génération des fichiers via une cible `make`** : machinerie + risque de staleness,
  contraire à « clarté avant astuce ».
- **Méga-config par-IA dans un seul fichier** : sur-ingénierie, chaque outil a son format natif.
- **Prompts custom Codex** : dépréciés et non versionnables → écartés au profit des skills.

## Conséquences

- Cloner le dépôt = standards + MCP + workflow disponibles sous Claude, Codex **et** Gemini,
  sans installation globale.
- `CLAUDE.md` et `.claude/skills/` restent la **source unique** ; les fichiers Codex/Gemini
  sont des points d'entrée minces qui y renvoient.
- Codex ne charge `.codex/config.toml` et `.codex/skills/` que pour un projet **trusted** :
  l'utilisateur doit approuver le projet une fois (documenté au README).
- **Triple déclaration MCP** (`.mcp.json`, `.gemini/settings.json`, `.codex/config.toml`) :
  risque de divergence à terme, accepté car limité à deux serveurs.
- Les garde-fous locaux (hooks) ne protègent que sous Claude ; la robustesse inter-outils
  repose sur la CI. À garder en tête si la protection de branche n'est pas active.
- `install.sh` et `castor-init` restent inchangés : comme `.claude/`, ces fichiers de config
  sont réutilisables d'un projet à l'autre (aucun renommage projet).
