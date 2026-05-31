<p align="center">
  <img src="frontend/public/castor.png" alt="Castor" width="180">
</p>

# Castor 🦫 — scaffold Symfony + Nuxt (config IA intégrée)

Monorepo dockerisé servant de **base aux projets de l'équipe** : une API **Symfony**
(`backend/`) et un frontend **Nuxt** (`frontend/`), entièrement dockerisés. Les services
portent les **labels Traefik** pour être routés par un reverse proxy présent sur le même
réseau Docker — **aucun Traefik n'est embarqué**. Toute la toolchain s'exécute exclusivement
dans Docker.

Le dépôt **embarque aussi la configuration IA de l'équipe** : standards, skills, agents,
hooks et workflow vivent dans `.claude/`, et sont **relayés à Codex et Gemini** via
`AGENTS.md`, `.codex/` et `.gemini/`. Tout se charge **automatiquement** à l'ouverture du
projet, quel que soit l'assistant : cloner ce dépôt = workflow d'équipe immédiat, **sans
aucune installation globale**.

## Stack

| Domaine | Techno | Version |
| --- | --- | --- |
| Backend | PHP / Symfony | 8.5 / 8.0 |
| Frontend | Nuxt / Vue | 4.4 / 3.5 |
| Runtime JS | Node.js | 26 |
| Paquets | Composer / pnpm | 2.x / 11.4 (Corepack) |
| Base de données | PostgreSQL | 18 |
| Reverse proxy | compatible Traefik (labels, non embarqué) | — |

Le détail des choix est consigné dans [`docs/adr/0001-stack-et-archi.md`](docs/adr/0001-stack-et-archi.md).

## Prérequis

- **Docker** et **Docker Compose** uniquement. Aucun binaire (php, composer, node, pnpm)
  n'est requis ni exécuté sur l'hôte.

## Démarrage express (une commande)

Depuis une machine neuve — vérifie les prérequis, clone, build et démarre la stack, puis
ouvre l'application :

```bash
curl -fsSL https://raw.githubusercontent.com/keyxmare/castor/main/install.sh | bash -s -- mon-app
```

`mon-app` est le dossier créé (défaut `castor` si omis). Le script vérifie `git`, puis clone,
puis vérifie **Docker** (démon démarré) et **make**, copie `.env`, lance `make build`, `make install`
puis `make up`, attend le healthcheck et ouvre http://localhost. Le clone repart d'un **dépôt git neuf** (pas
d'historique du scaffold) ; le renommage en projet se fait ensuite avec `/castor-init`. Réglable
par variables d'environnement : `CASTOR_REPO`, `CASTOR_REF`, `CASTOR_DIR`, `CASTOR_URL`,
`CASTOR_HEALTH_TIMEOUT`, `CASTOR_KEEP_GIT` (conserver l'historique), `CASTOR_NO_OPEN`.

## Démarrage manuel

Depuis un clone existant :

```bash
cp .env.dist .env
make build
make install
make up
```

| URL | Description |
| --- | --- |
| http://localhost | Frontend Nuxt |
| http://localhost/api/health | Healthcheck applicatif (vérifie la base) |
| http://localhost/api/greeting | Endpoint d'exemple (JSON) |

> En local, le serveur de dev Nuxt sert le front et **proxifie `/api`** vers le backend
> (origine unique, pas de CORS). Aucun Traefik n'est lancé : les services conservent leurs
> **labels Traefik** pour être routés en prod par un Traefik sur le même réseau Docker.

## Configuration IA intégrée (multi-assistants)

Tout est **versionné avec le projet** et **auto-chargé** dès qu'on ouvre le projet avec son
assistant — rien à installer.

### Claude Code (`.claude/`)

| Chemin | Rôle |
| --- | --- |
| `.claude/CLAUDE.md` | Référentiel de standards techniques (stack, conventions, git, tests, sécurité…). Mémoire projet auto-chargée. **Fait foi.** |
| `.claude/skills/` | Skills du workflow : orchestrateur `feature` + phases (`design`, `plan`, `dev`, `test`, `check`, `commit`, `simplify`) + `triage` Sentry. |
| `.claude/agents/` | Subagents d'audit read-only : conformité, sécurité, perf, correctness, a11y/i18n. |
| `.claude/hooks/` | `commit-gate.sh` (lance `make check-fast` avant commit) et `protect-main.sh` (interdit le commit direct sur `main`). |
| `.claude/settings.json` | Permissions + hooks. Hooks projet-relatifs via `$CLAUDE_PROJECT_DIR`. |
| `.claude/workflow.json` | Config du workflow : chemin rapide, gates, nettoyage, audits. |
| `.mcp.json` | Serveurs MCP du projet (GitHub + Sentry), exploités par `triage`. |

### Codex & Gemini (couverture inter-outils)

Les **mêmes standards** s'appliquent sous Codex (OpenAI) et Gemini (Google), **sans
duplication** : `AGENTS.md` est le point d'entrée commun et **renvoie à `.claude/CLAUDE.md`
qui fait foi**. Le workflow y est rejoué en délégant aux skills canoniques `.claude/skills/`.

| Chemin | Rôle |
| --- | --- |
| `AGENTS.md` | Point d'entrée inter-outils : garde-fous non négociables + renvoi au référentiel `.claude/CLAUDE.md`. Lu nativement par Codex, chargé par Gemini via `context.fileName`. |
| `.codex/config.toml` | Serveurs MCP (GitHub + Sentry) pour Codex. |
| `.codex/skills/` | Workflow porté en skills Codex (délèguent aux skills canoniques `.claude/skills/`). |
| `.gemini/settings.json` | Point d'entrée (`context.fileName`) + serveurs MCP (GitHub + Sentry) pour Gemini. |
| `.gemini/commands/` | Workflow porté en commandes Gemini (injectent les skills canoniques `.claude/skills/`). |

> **Frontière de portabilité.** Les **subagents d'audit** et les **hooks** (`commit-gate`,
> `protect-main`) sont spécifiques à Claude Code et **ne s'exécutent pas** sous Codex/Gemini :
> l'audit se fait alors en passe inline et `make check-fast` est lancé à la main avant commit.
> Le **vrai garde-fou inter-outils reste la CI** (rouge = pas de merge).
>
> **Codex** ne charge `.codex/` que pour un projet **trusted** : approuve le projet une fois.
> Décision détaillée : [`docs/adr/0004-couverture-multi-assistants-ia.md`](docs/adr/0004-couverture-multi-assistants-ia.md).

### Workflow de dev (`/feature`)

Pipeline outillé, avec gates configurables et **chemin rapide** pour les changements triviaux :

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

Chaque phase est aussi invocable seule (`/design`, `/plan`, `/dev`, `/test`, `/check`,
`/commit`, `/simplify`) — sous Codex via les skills `.codex/skills/`, sous Gemini via les
commandes `.gemini/commands/`, qui délèguent toutes aux mêmes skills canoniques. L'auto-review
(étape 5) **ne remplace pas** la revue humaine sur la PR. La config se règle dans
`.claude/workflow.json` (`fastPath`, `gates`, `cleanup`, `audits`).

### Faire évoluer les standards / le workflow

1. Créer une branche. 2. Modifier `.claude/CLAUDE.md` (ou les skills/agents/hooks).
3. Ouvrir une PR → revue d'équipe → merge. Le changement profite immédiatement à
quiconque travaille dans le projet.

## Structure

```
AGENTS.md   Point d'entrée IA inter-outils (Codex, Gemini) → renvoie à .claude/CLAUDE.md
.claude/    Config Claude Code de l'équipe (standards, skills, agents, hooks, workflow)
.codex/     Config Codex (serveurs MCP, skills du workflow)
.gemini/    Config Gemini (serveurs MCP, commandes du workflow)
backend/    API Symfony (contrôleurs fins + DTO, Doctrine, PHPStan, php-cs-fixer)
frontend/   Application Nuxt (Composition API, Pinia, i18n, ESLint/Prettier)
docker/     Dockerfiles et configuration (php, node, nginx)
compose.yaml, Makefile  Orchestration et commandes
.github/workflows/ci.yml  Pipeline CI
docs/adr/   Décisions d'architecture
```

## Commandes

`make help` liste toutes les cibles. Les principales :

| Commande | Effet |
| --- | --- |
| `make up` / `make down` | Démarre / arrête la stack |
| `make build` | Construit les images |
| `make install` | Installe les dépendances backend + frontend |
| `make migrate` | Applique les migrations Doctrine |
| `make check-fast` | Gates rapides sans tests (format → lint → stan → typecheck) — appelé par `commit-gate` |
| `make check` | Pipeline qualité complet (voir ci-dessous) |
| `make test` | Tests PHPUnit + Vitest |
| `make coverage` | Couverture back (pcov) + front (v8) |
| `make e2e` | Tests end-to-end Playwright |
| `make audit` | Audit des dépendances (composer + pnpm) |
| `make sh-php` / `make sh-node` | Shell dans un conteneur |

> Seules les cibles de **test** (`test-php`, `coverage-php`, `migrate`) démarrent
> PostgreSQL ; le formatage, le lint et l'analyse statique tournent en `--no-deps`
> (le `commit-gate` n'attend donc pas la base).

## Qualité

`make check` enchaîne les gates dans l'ordre, en s'arrêtant à la première erreur :

```
format (php-cs-fixer + prettier) → lint (eslint) → analyse statique (phpstan niveau 8)
→ typecheck (vue-tsc) → tests (phpunit + vitest)
```

`make check-fast` exécute les mêmes gates **sans les tests** : c'est la cible appelée par
le hook `commit-gate` avant chaque commit (la suite complète tourne au push / en CI).
L'analyse statique inclut les extensions PHPStan **Symfony** et **Doctrine**.

La CI (`.github/workflows/ci.yml`) exécute exactement les mêmes commandes dans Docker,
puis les tests end-to-end. Elle **cache** les dépendances (vendor, node_modules, store
pnpm) et les **layers Docker** (buildx + `compose.ci.yaml`, sans impacter le build local),
et lance un job **audit** non bloquant (composer + pnpm). Rouge = pas de merge.

## Tests

- **Backend** : PHPUnit (`make test`). Couverture via **pcov** (`make coverage-php`).
- **Frontend** : Vitest (`make test`, couverture **v8** via `make coverage-front`) et
  Playwright (`make e2e`, image dédiée `docker/playwright/` — dépendances figées au build,
  pas d'installation au runtime). Le e2e couvre aussi l'**accessibilité** (axe-core).

## Observabilité

- **Sentry** est câblé côté backend et frontend. Inactif tant que `SENTRY_DSN` est vide ;
  renseignez-le dans `.env` pour activer la remontée d'erreurs. Le skill `triage` part
  d'une issue Sentry (via le MCP de `.mcp.json`) jusqu'au fix testé.
- **Logs JSON structurés** en environnement de production (Monolog vers `stderr`).

## Déploiement

- Construire les images de production et fournir les variables d'environnement
  (`APP_ENV=prod`, `APP_SECRET`, `DATABASE_URL`, `SENTRY_DSN`) via le gestionnaire de
  secrets de la cible.
- Compiler les variables Symfony : `composer dump-env prod`.
- Appliquer les migrations : `make migrate`.

## Durcissement production

Les Dockerfiles sont **multi-stage** : le stage `dev` (utilisé par `compose.yaml`) embarque
l'outillage et pcov ; le stage `prod` est durci par construction.

```bash
docker build --target prod -f docker/php/Dockerfile  -t mon-app-php  .
docker build --target prod -f docker/node/Dockerfile -t mon-app-node .
```

- **PHP prod** : code copié dans l'image (plus de bind-mount), `composer install --no-dev`
  + autoloader optimisé, **utilisateur non-root** (`www-data`), OPcache figé
  (`validate_timestamps=0` + `preload`, cf. `docker/php/php.prod.ini`), sans pcov.
- **Node prod** : build SSR Nuxt (`.output`) servi par `node .output/server/index.mjs`,
  **utilisateur non-root** (`node`).

Réglages restant à fournir par la cible de déploiement :

- **Reverse proxy** : la stack n'embarque pas de Traefik. En prod, place les conteneurs sur
  le réseau Docker d'un Traefik existant (les labels de routage sont déjà fournis) et sers
  en HTTPS ; en local, le port `80` est publié directement par le service `node`.
- **Secrets** : fournir `APP_SECRET`, `POSTGRES_PASSWORD`, `DATABASE_URL`, `SENTRY_DSN`
  via le gestionnaire de secrets de la cible ; jamais de valeur par défaut en prod.
- **Dépendances** : `make audit` (composer + pnpm), également joué en CI.

## Points de vigilance

- **Symfony 8.0** : fin de support actif en **juillet 2026** ; une migration de version
  majeure est à planifier rapidement.
- **Node 26** : ligne *Current* (passage en LTS en octobre 2026).
