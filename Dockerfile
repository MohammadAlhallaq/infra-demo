FROM php:8.4-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libzip-dev zip default-mysql-client \
    && docker-php-ext-install pdo pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . .

ARG COMPOSER_AUTH=
RUN COMPOSER_AUTH="$COMPOSER_AUTH" composer install --no-dev --optimize-autoloader

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
