FROM php:8.2-fpm-alpine

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apk update && apk add --no-cache \
    curl \
    git \
    unzip \
    libpq-dev \
    libpng-dev \
    libzip-dev \
    zip unzip \
    git && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo pdo_pgsql pgsql && \
    docker-php-ext-enable pdo pdo_pgsql pgsql && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install gd && \
    docker-php-ext-install zip

COPY php.ini /usr/local/etc/php/conf.d/php.ini


# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Node.js
RUN curl -sL https://unofficial-builds.nodejs.org/download/release/v20.10.0/node-v20.10.0-linux-x64-musl.tar.gz | tar xz -C /usr/local --strip-components=1


# Create system user to run Composer and Artisan Commands
RUN addgroup -g 1000 --system $user
RUN adduser -G $user --system -D -s /bin/sh -u $uid $user && \
    adduser jocker www-data && \
    adduser jocker root

RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user