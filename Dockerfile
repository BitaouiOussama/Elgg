FROM php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev unzip git curl \
    libonig-dev libmcrypt-dev libldap2-dev \
    libssl-dev libcurl4-openssl-dev \
    libicu-dev zlib1g-dev zip \
    && docker-php-ext-install pdo pdo_mysql mysqli xml mbstring intl zip soap gd bcmath opcache \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy Elgg project files (use this if cloning locally during build)
COPY . .

# OR if you want Docker to clone the repo during build, replace COPY with:
# RUN git clone -b 3.3 https://github.com/BitaouiOussama/Elgg.git /var/www/html

# Install composer globally
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install PHP dependencies
RUN composer install --no-dev --no-scripts --no-progress --optimize-autoloader

# Create data folder
RUN mkdir -p /var/elgg_data && \
    chown -R www-data:www-data /var/elgg_data /var/www/html && \
    chmod -R 777 /var/elgg_data

# Apache config: Ensure AllowOverride All for .htaccess
RUN echo "<Directory /var/www/html/> \
    AllowOverride All \
    Require all granted \
</Directory>" >> /etc/apache2/apache2.conf

# Expose HTTP port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
