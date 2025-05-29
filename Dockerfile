FROM php:7.4-apache

# Mise à jour du système et installation des dépendances système équivalentes à ton playbook Ansible
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libapache2-mod-php7.4 \
    php7.4 \
    php7.4-cli \
    php7.4-mysql \
    php7.4-xml \
    php7.4-mbstring \
    php7.4-curl \
    php7.4-zip \
    php7.4-intl \
    php7.4-gd \
    php7.4-soap \
    php7.4-bcmath \
    php7.4-json \
    php7.4-opcache \
    php7.4-ldap \
    && apt-get clean

# Activer les modules Apache nécessaires
RUN a2enmod rewrite

# Copier le code source Elgg dans le conteneur
WORKDIR /var/www/html/elgg
COPY . .

# Installer Composer via apt comme dans ton playbook
RUN apt-get update && apt-get install -y composer

# Installer les dépendances PHP sans les dev, scripts ou output inutile
RUN composer install --no-dev --no-scripts --no-progress --optimize-autoloader

# Donner les bons droits
RUN chown -R www-data:www-data /var/www/html/elgg

# Exposer le port web
EXPOSE 80

# Lancer Apache en mode non détaché
CMD ["apache2-foreground"]
