# Für Apple Silicon (ARM64) und andere Architekturen optimiert
ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-apache

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
    ffmpeg \
    imagemagick \
    libmagickwand-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli zip intl exif \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# ImageMagick-Konfiguration optimieren
RUN echo '<policy domain="resource" name="memory" value="256MiB"/>' > /etc/ImageMagick-6/policy.xml \
    && echo '<policy domain="resource" name="map" value="512MiB"/>' >> /etc/ImageMagick-6/policy.xml \
    && echo '<policy domain="resource" name="width" value="8KP"/>' >> /etc/ImageMagick-6/policy.xml \
    && echo '<policy domain="resource" name="height" value="8KP"/>' >> /etc/ImageMagick-6/policy.xml

# XDebug für Profiling installieren
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Composer installieren
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node.js und npm installieren (neueste LTS Version)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Apache Module aktivieren (inklusive SSL)
RUN a2enmod rewrite headers expires ssl
COPY apache-vhost.conf /etc/apache2/sites-available/000-default.conf

# SSL-Verzeichnisse erstellen
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# Arbeitsverzeichnis setzen
WORKDIR /var/www/html

# XDebug-Konfiguration
RUN echo "xdebug.mode=develop,debug,profile" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.output_dir=/var/www/html/profiler" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# PHP-Konfiguration für bessere Performance
RUN echo "upload_max_filesize = 64M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "opcache.enable=1" > /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.revalidate_freq=0" >> /usr/local/etc/php/conf.d/opcache.ini

# Volume für Profiler-Daten
RUN mkdir -p /var/www/html/profiler && chmod 777 /var/www/html/profiler
