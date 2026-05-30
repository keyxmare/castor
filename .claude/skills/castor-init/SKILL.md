---
name: castor-init
description: Transforme le scaffold Castor en un nouveau projet — renomme partout (compose, packages, README, i18n), remplace la page d'accueil de démo et retire la mascotte, puis propose (en confirmant) de repartir d'un historique git neuf. À lancer UNE seule fois, sur un clone frais de Castor, juste avant de commencer un projet. Opération destructive : confirme à chaque étape.
argument-hint: <nom du nouveau projet>
---

# castor-init — du scaffold Castor à ton projet

Personnalise le scaffold pour en faire un projet propre. **Opération destructive et unique** : à lancer sur un **clone frais** de Castor, pas sur le dépôt du scaffold lui-même.

## Pré-requis & garde-fous

- Confirmer qu'on est bien sur un **clone destiné à un nouveau projet** (pas le dépôt scaffold de référence). En cas de doute → **s'arrêter et demander**.
- Chaque étape qui supprime ou réécrit du contenu est **confirmée** avant exécution.
- Cette commande **ne lance pas** `make build/up/check` d'office : la validation reste à la main de l'utilisateur (proposée en fin de course).

## Procédure

### 1. Nom du projet

Demander (ou lire l'argument) :
- **slug** technique en kebab-case (ex. `mon-app`) — sert aux identifiants Docker/paquets ;
- **nom affiché** (ex. `Mon App`) — sert au README et à l'UI.

### 2. Renommer partout

Remplacer le nom `castor` / `Castor` par le nouveau, dans :
- `compose.yaml` → `name:` ;
- `.env.dist` → `COMPOSE_PROJECT_NAME=` (et rappeler de refaire `cp .env.dist .env`) ;
- `frontend/package.json` → `name` (ex. `<slug>-frontend`) ;
- `backend/composer.json` → `name` s'il est défini ;
- `README.md` → titre H1 + mentions de Castor ;
- `frontend/i18n/locales/*.json` → `home.title` et les libellés qui mentionnent Castor ;
- `nuxt.config.ts` → `app.head.title` et `meta` description.

### 3. Nettoyer la page d'accueil & la mascotte

- Remplacer `frontend/app/pages/index.vue` par une **home minimale** : nom du projet + un seul panneau « santé de l'API » (réutiliser `useHealthStore`), `<style scoped>`, sans mascotte ni contenu marketing de démo.
- Supprimer les assets de la mascotte : `frontend/public/castor.png`, `frontend/public/favicon-16.png`, `frontend/public/favicon-32.png`, `frontend/public/apple-touch-icon.png`.
- Mettre à jour `nuxt.config.ts` (`app.head.link`) pour ne plus référencer ces favicons, ou pointer vers les nouveaux assets du projet.
- Réduire `frontend/i18n/locales/*.json` aux seules clés encore utilisées par la home minimale.

### 4. (Option, confirmée) Historique git neuf

⚠️ **Destructif et irréversible** : efface tout l'historique git du clone. Demander une **confirmation explicite** avant.

Si confirmé :
```
rm -rf .git
git init
git add -A
git commit -m "chore: init from Castor"
```
Sinon, **conserver** l'historique et ne rien faire ici.

### 5. Fin

- Lister les changements et rappeler la suite, **sans l'exécuter** :
  > Vérifie quand tu veux : `cp .env.dist .env && make build && make up && make check`.
- Si la stack tournait sous l'ancien nom de projet Docker, signaler que les conteneurs/volumes `castor-*` sont orphelins (`docker compose -p castor down -v` pour nettoyer).

## Règles

- Respecter `CLAUDE.md` (code EN sans commentaire, conventions stack, toolchain Docker).
- Ne jamais réécrire ou supprimer sans confirmation préalable.
- En cas d'ambiguïté sur le périmètre (ce qui doit rester vs partir) → **demander**, ne pas deviner.
