# ADR 0001 — Stack technique et architecture du scaffold

- Statut : accepté
- Date : 2026-05-28

## Contexte

Initialisation d'un scaffold monorepo servant de base aux projets de l'équipe :
une API backend et un frontend, entièrement dockerisés, conformes au référentiel
de standards techniques partagé.

## Décision

### Architecture

- **Monorepo** : `backend/` (Symfony) et `frontend/` (Nuxt), orchestrés à la racine
  par `compose.yaml` et un `Makefile`.
- **Reverse proxy Traefik** en façade : `/` est routé vers Nuxt, `/api` vers l'API
  Symfony. Le routage par préfixe de chemin évite toute configuration CORS.
- **API en contrôleurs Symfony classiques** (pas d'API Platform) : contrôleurs fins,
  Serializer et DTO de sortie typés.
- **Toolchain exclusivement dans Docker** : aucun binaire (php, composer, node, pnpm)
  n'est exécuté sur l'hôte.

### Versions

Politique retenue : **dernière version stable GA** de chaque techno à l'init
(non-beta, non-RC), vérifiée à la source officielle le 2026-05-28.

| Domaine | Techno | Version |
| --- | --- | --- |
| Backend | PHP | 8.5 |
| Framework backend | Symfony | 8.0 |
| Frontend | Nuxt | 4.4 |
| Frontend | Vue | 3.5 |
| Runtime JS | Node.js | 26 |
| Paquets PHP | Composer | 2.x |
| Paquets JS | pnpm | 11.4 (Corepack) |
| Base de données | PostgreSQL | 18 |

## Conséquences

- **Symfony 8.0** : fin de support actif en juillet 2026. Une migration de version
  majeure est à planifier rapidement après l'init.
- **Node 26** : ligne *Current* (non-LTS jusqu'à octobre 2026), donc fenêtre de
  support sécurité plus courte. Choix assumé au titre de la politique « dernière
  version stable » plutôt que « dernière LTS ».
- Le routage par préfixe via Traefik impose de gérer la double URL d'API : `/api`
  côté navigateur, URL interne `http://nginx/api` côté SSR Nuxt.
