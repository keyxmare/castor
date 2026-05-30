# Makefile de référence — SI de l'équipe (cf. CLAUDE.md §2 & §6).
# Toute la toolchain passe par Docker (jamais sur l'hôte).
# À copier à la racine d'un projet, puis adapter PHP_SVC / NODE_SVC aux services réels.
# Retirer les cibles d'une techno absente du projet.

PHP_SVC  ?= php
NODE_SVC ?= node
DC       := docker compose
DC_RUN   := $(DC) run --rm

.DEFAULT_GOAL := help

.PHONY: help build up down install \
        cs cs-fix stan php-test \
        front-lint front-typecheck front-test \
        check-fast check

help: ## Liste les cibles
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n",$$1,$$2}'

build: ## Build des images Docker
	$(DC) build

up: ## Démarre la stack
	$(DC) up -d

down: ## Arrête la stack
	$(DC) down

install: ## Installe les dépendances (dans Docker)
	$(DC_RUN) $(PHP_SVC) composer install
	$(DC_RUN) $(NODE_SVC) pnpm install --frozen-lockfile

## --- PHP / Symfony ---
cs: ## php-cs-fixer (dry-run, ruleset @PER-CS)
	$(DC) exec $(PHP_SVC) vendor/bin/php-cs-fixer fix --dry-run --diff

cs-fix: ## php-cs-fixer (applique)
	$(DC) exec $(PHP_SVC) vendor/bin/php-cs-fixer fix

stan: ## PHPStan niveau 8
	$(DC) exec $(PHP_SVC) vendor/bin/phpstan analyse --level=8

php-test: ## PHPUnit
	$(DC) exec $(PHP_SVC) vendor/bin/phpunit

## --- Vue / Nuxt ---
front-lint: ## ESLint
	$(DC) exec $(NODE_SVC) pnpm run lint

front-typecheck: ## vue-tsc / nuxi typecheck
	$(DC) exec $(NODE_SVC) pnpm run typecheck

front-test: ## Vitest
	$(DC) exec $(NODE_SVC) pnpm run test

## --- Gates agrégés (ordre CLAUDE.md §6 : format -> lint -> static -> typecheck -> tests) ---
check-fast: cs stan front-lint front-typecheck ## Gates rapides (sans tests) — utilisé par le hook commit-gate
check: cs stan front-lint front-typecheck php-test front-test ## Gates complets — pré-push / CI
