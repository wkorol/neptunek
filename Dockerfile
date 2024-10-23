# Use the official PHP 8.3 FPM image as the base image
FROM php:8.3-fpm

# Install Nginx and Supervisor
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files into the container
COPY . /var/www/html

# Ensure the var directory exists, and set correct permissions
RUN mkdir -p /var/www/html/var \
    && chown -R www-data:www-data /var/www/html/var \
    && chmod -R 775 /var/www/html/var

# Install Composer dependencies for production
RUN composer install --no-dev --optimize-autoloader

# Copy the Nginx configuration file
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy the Supervisor configuration file
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure PHP-FPM listens on the port provided by Heroku
RUN sed -i 's/listen = \/run\/php\/php-fpm.sock/listen = 127.0.0.1:9000/' /usr/local/etc/php-fpm.d/www.conf

# Expose the port that Heroku dynamically provides
EXPOSE ${PORT}

# Start Supervisor to run both Nginx and PHP-FPM
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
