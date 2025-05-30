FROM php:7.4-apache

# Installer les dépendances système nécessaires
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

# Activer les modules Apache nécessaires
RUN a2enmod rewrite

# Copier la configuration Apache personnalisée
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Définir le dossier de travail
WORKDIR /var/www/html/elgg

# Copier le code source Elgg dans le conteneur
COPY . .

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer self-update --1

# Installer les dépendances PHP avec Composer
RUN composer install --no-dev --no-scripts --no-progress --optimize-autoloader || true

# Donner les bons droits à Apache
RUN chown -R www-data:www-data /var/www/html/elgg

# Exposer le port
EXPOSE 80

# Lancer Apache
CMD ["apache2-foreground"]
