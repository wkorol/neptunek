# Use the official PHP image with FPM
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql zip intl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy the Symfony project files
COPY . .

# Install Symfony dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Set up environment variables
ENV APP_ENV=prod
ENV APP_SECRET=your-secret-key
ENV DATABASE_URL="postgresql://user:password@localhost:5432/dbname"

# Update PHP-FPM to listen on the dynamic $PORT provided by Heroku
RUN sed -i 's/listen = .*/listen = 0.0.0.0:$PORT/' /usr/local/etc/php-fpm.d/www.conf

# Limit the number of child processes for PHP-FPM
RUN echo "pm.max_children = 5" >> /usr/local/etc/php-fpm.d/www.conf
RUN echo "pm.start_servers = 2" >> /usr/local/etc/php-fpm.d/www.conf
RUN echo "pm.min_spare_servers = 2" >> /usr/local/etc/php-fpm.d/www.conf
RUN echo "pm.max_spare_servers = 3" >> /usr/local/etc/php-fpm.d/www.conf

HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost:$PORT/ || exit 1

RUN echo "log_errors = On" >> /usr/local/etc/php/php.ini
RUN echo "error_log = /var/log/php_errors.log" >> /usr/local/etc/php/php.ini

# Start PHP-FPM
CMD ["php-fpm", "-F"]

