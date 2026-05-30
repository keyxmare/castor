DC := docker compose $(COMPOSE_FILES)
PHP := $(DC) run --rm --no-deps php
PHP_DB := $(DC) run --rm php
PHPTEST := $(DC) run --rm -e APP_ENV=test php
NODE := $(DC) run --rm --no-deps node

GITLEAKS_VERSION := v8.30.1

.DEFAULT_GOAL := help

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

build: ## Build des images Docker
	$(DC) build

up: ## Démarre la stack
	$(DC) up -d

down: ## Arrête la stack
	$(DC) down

logs: ## Suit les logs de la stack
	$(DC) logs -f

install: ## Installe les dépendances backend + frontend
	$(PHP) composer install
	$(NODE) pnpm install

sh-php: ## Ouvre un shell dans le conteneur php
	$(PHP) sh

sh-node: ## Ouvre un shell dans le conteneur node
	$(NODE) sh

migrate: ## Applique les migrations Doctrine
	$(PHP_DB) php bin/console doctrine:migrations:migrate --no-interaction

format: ## Vérifie le formatage PHP (php-cs-fixer, dry-run)
	$(PHP) vendor/bin/php-cs-fixer fix --dry-run --diff

fix: ## Corrige le formatage PHP
	$(PHP) vendor/bin/php-cs-fixer fix

stan: ## Analyse statique PHPStan
	$(PHP) vendor/bin/phpstan analyse

lint: ## Lint frontend (eslint)
	$(NODE) pnpm lint

typecheck: ## Typecheck frontend (vue-tsc)
	$(NODE) pnpm typecheck

test-php: ## Tests PHPUnit
	$(PHPTEST) php bin/console doctrine:database:create --if-not-exists --no-interaction
	$(PHPTEST) php bin/phpunit

test-front: ## Tests Vitest
	$(NODE) pnpm test

coverage-php: ## Couverture PHPUnit (texte + clover, via pcov)
	$(PHPTEST) php bin/console doctrine:database:create --if-not-exists --no-interaction
	$(PHPTEST) php bin/phpunit --coverage-text --coverage-clover var/coverage/clover.xml

coverage-front: ## Couverture Vitest (v8)
	$(NODE) pnpm test:coverage

coverage: coverage-php coverage-front ## Couverture back + front

e2e: ## Tests end-to-end Playwright
	$(DC) --profile e2e build playwright
	$(DC) run --rm playwright

test: test-php test-front ## Tests unitaires + fonctionnels

audit: ## Audit des dépendances (composer + pnpm)
	$(PHP) composer audit
	$(NODE) pnpm audit

secrets: ## Scan des secrets sur l'historique git (gitleaks, via Docker)
	docker run --rm -v "$(CURDIR):/repo:ro" zricethezav/gitleaks:$(GITLEAKS_VERSION) git /repo --redact --verbose

check-fast: ## Gates rapides sans tests (format -> lint -> stan -> typecheck) — utilisé par le hook commit-gate
	$(PHP) vendor/bin/php-cs-fixer fix --dry-run --diff
	$(NODE) pnpm format:check
	$(NODE) pnpm lint
	$(PHP) vendor/bin/phpstan analyse
	$(NODE) pnpm typecheck

check: ## Pipeline qualité complet (format -> lint -> stan -> typecheck -> tests)
	$(PHP) vendor/bin/php-cs-fixer fix --dry-run --diff
	$(NODE) pnpm format:check
	$(NODE) pnpm lint
	$(PHP) vendor/bin/phpstan analyse
	$(NODE) pnpm typecheck
	$(PHPTEST) php bin/console doctrine:database:create --if-not-exists --no-interaction
	$(PHPTEST) php bin/phpunit
	$(NODE) pnpm test

.PHONY: help build up down logs install sh-php sh-node migrate format fix stan lint typecheck test-php test-front coverage-php coverage-front coverage e2e test audit secrets check-fast check
