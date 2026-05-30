ARG PHP_VERSION=8.5
ARG COMPOSER_VERSION=2.8

FROM composer:${COMPOSER_VERSION} AS composer

FROM php:${PHP_VERSION}-fpm-alpine AS base

RUN apk add --no-cache \
        icu-libs \
        libpq \
    && apk add --no-cache --virtual .build-deps \
        icu-dev \
        postgresql-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j"$(nproc)" intl pdo_pgsql \
    && apk del .build-deps

COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /app

FROM base AS dev

RUN apk add --no-cache git unzip \
    && apk add --no-cache --virtual .pcov-deps $PHPIZE_DEPS \
    && pecl install pcov \
    && docker-php-ext-enable pcov \
    && apk del .pcov-deps

COPY docker/php/php.ini /usr/local/etc/php/conf.d/zz-app.ini

FROM base AS prod

ENV APP_ENV=prod

COPY docker/php/php.prod.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY backend/ ./

RUN apk add --no-cache --virtual .composer-deps git unzip \
    && composer install --no-dev --no-scripts --no-interaction --no-progress --prefer-dist --classmap-authoritative \
    && composer dump-autoload --no-dev --classmap-authoritative \
    && composer clear-cache \
    && apk del .composer-deps \
    && mkdir -p var/cache var/log \
    && chown -R www-data:www-data var

USER www-data
