# Fiche PHP — check

Indice de présence : `composer.json` (racine ou sous-projet).

## Outils & ordre (alignés CLAUDE.md)

| Famille | Outil | Réglage attendu |
| --- | --- | --- |
| Format | php-cs-fixer | ruleset `@PER-CS` |
| Analyse statique | PHPStan | **niveau 8**, sans baseline qui grossit |
| Tests | PHPUnit | cible couverture 80 % (code métier) |

## Trouver la commande (par ordre de préférence)

1. **Cible `make`** — à confirmer en lisant le `Makefile`. Candidates fréquentes :
   - format : `make cs`, `make cs-fix`, `make php-cs-fixer`, `make fix`
   - static : `make stan`, `make phpstan`, `make analyse`
   - tests : `make test`, `make tests`, `make phpunit`
2. **Fallback `docker compose`** (service PHP typique : `php`, `app`, `fpm`) :
   - `docker compose exec <svc> vendor/bin/php-cs-fixer fix`
   - `docker compose exec <svc> vendor/bin/phpstan analyse --level=8`
   - `docker compose exec <svc> vendor/bin/phpunit`
   - stack non démarrée → `docker compose run --rm <svc> …`

Ne **jamais** lancer `composer` / `vendor/bin/...` sur l'hôte.
