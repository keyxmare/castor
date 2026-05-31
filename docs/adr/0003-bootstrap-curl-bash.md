# ADR 0003 — Bootstrap projet via `curl | bash`

- Statut : accepté
- Date : 2026-05-31

## Contexte

L'`install.sh` initial liait le contenu de `.claude/` vers `~/.claude/` pour rendre les
standards et skills disponibles globalement. Cette installation globale est devenue
**redondante** : `.claude/` est versionné dans le dépôt et se charge automatiquement à
l'ouverture du projet (cf. [`0001`](0001-stack-et-archi.md)). Elle était même **fragile**,
le `settings.json` ne pouvant être lié globalement (hooks projet-relatifs via
`$CLAUDE_PROJECT_DIR`).

Par ailleurs, l'onboarding depuis une machine neuve restait manuel (cloner, copier `.env`,
build, up), sans garde-fou sur les prérequis.

## Décision

### `install.sh` devient un bootstrap from-zero

Le script est récupérable depuis une URL et exécutable en une commande :

```bash
curl -fsSL https://raw.githubusercontent.com/keyxmare/castor/main/install.sh | bash -s -- mon-app
```

Déroulé, avec vérification des prérequis **au plus près de leur usage** :

1. vérifie `git` (requis pour cloner) ;
2. clone le dépôt dans le dossier passé en argument (défaut `castor`), sans écraser un
   dossier existant, puis repart d'un **dépôt git neuf** (`rm -rf .git && git init`, sans
   commit initial) sauf `CASTOR_KEEP_GIT=1` — uniquement après un clone frais, jamais sur un
   dossier réutilisé ;
3. vérifie **Docker** (binaire, démon démarré, plugin `compose` v2) ;
4. vérifie `make` ;
5. copie `.env.dist` → `.env` si absent ;
6. `make build && make up` ;
7. attend le healthcheck applicatif (`/api/health`) ;
8. ouvre l'application dans le navigateur et affiche les liens.

Paramétrable sans édition via `CASTOR_REPO`, `CASTOR_REF`, `CASTOR_DIR`, `CASTOR_URL`,
`CASTOR_HEALTH_TIMEOUT`, `CASTOR_KEEP_GIT`, `CASTOR_NO_OPEN`.

### Abandon de l'installation globale des standards

Le symlink de `.claude/` vers `~/.claude/` est supprimé : il n'apporte plus rien face au
chargement automatique de la config versionnée.

## Alternatives écartées

- **Deux scripts** (`install.sh` standards + `bootstrap.sh` projet) : inutile une fois
  l'installation globale abandonnée.
- **Script unifié à sous-commandes** : complexité sans bénéfice, responsabilité unique.
- **Cible `make bootstrap`** : ne couvre pas le cas from-zero (aucun dépôt cloné quand on
  exécute `curl … | bash`).

## Conséquences

- Onboarding en une commande, prérequis vérifiés avec des messages explicites.
- Le one-liner suppose un dépôt **public** nommé `keyxmare/castor` ; tant que le dépôt n'est
  pas renommé, `CASTOR_REPO` permet de pointer ailleurs.
- Le `curl | bash` exécute du code distant : caveat assumé pour ce type d'outil ; le script
  reste minimal, sans `eval`, en `set -euo pipefail`.
- Le vrai parcours from-zero (réseau + Docker réels) n'est pas testé en CI ; il reste un
  smoke test manuel. La CI se limite au lint shell et au contrôle de syntaxe.
- `castor-init` retire désormais aussi le logo du README, cohérent avec la suppression de la
  mascotte à l'initialisation d'un projet.
