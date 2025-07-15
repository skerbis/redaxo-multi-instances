ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-fpm

# System-Abhängigkeiten installieren
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    unzip \
    git \
    curl \
    vim \
    mariadb-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli zip intl exif

# XDebug für Profiling installieren (versionsspezifisch)
RUN php_version=$(php -v | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2); \
    if [ "$php_version" = "7.4" ]; then \
    pecl install xdebug-3.1.6; \
    elif [ "$php_version" = "8.0" ]; then \
    pecl install xdebug-3.3.2; \
    else \
    pecl install xdebug; \
    fi && docker-php-ext-enable xdebug

# Composer installieren
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node.js und npm installieren
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Arbeitsverzeichnis setzen
WORKDIR /var/www/html

# XDebug-Konfiguration
RUN echo "xdebug.mode=develop,debug,profile" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.output_dir=/var/www/html/profiler" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# PHP-Konfiguration anpassen
RUN echo "upload_max_filesize = 64M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini

# PHP Error Reporting - nur loggen, nicht ausgeben
RUN echo "error_reporting = E_ALL" > /usr/local/etc/php/conf.d/error-reporting.ini \
    && echo "display_errors = Off" >> /usr/local/etc/php/conf.d/error-reporting.ini \
    && echo "display_startup_errors = Off" >> /usr/local/etc/php/conf.d/error-reporting.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/conf.d/error-reporting.ini \
    && echo "error_log = /var/log/php_errors.log" >> /usr/local/etc/php/conf.d/error-reporting.ini

# Volume für Profiler-Daten
RUN mkdir -p /var/www/html/profiler && chmod 777 /var/www/html/profiler
