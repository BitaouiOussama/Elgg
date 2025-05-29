FROM php:7.4-apache

# Installer les dépendances système nécessaires pour certaines extensions
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libldap2-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libmcrypt-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    && apt-get clean

# Installer les extensions PHP nécessaires
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-install -j$(nproc) \
        mysqli \
        pdo_mysql \
        xml \
        mbstring \
        curl \
        zip \
        intl \
        gd \
        soap \
        bcmath \
        opcache \
        ldap

# Activer le module rewrite d'Apache
RUN a2enmod rewrite

# Copier le code source Elgg dans le conteneur
WORKDIR /var/www/html/elgg
COPY . .

# Installer Composer (via installation officielle recommandée)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Installer les dépendances PHP avec Composer
RUN composer install --no-dev --no-scripts --no-progress --optimize-autoloader

# Donner les bons droits à www-data
RUN chown -R www-data:www-data /var/www/html/elgg

# Exposer le port 80
EXPOSE 80

# Lancer Apache au premier plan
CMD ["apache2-foreground"]
