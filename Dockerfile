# Use the official PHP 8.3 FPM image as the base image
FROM php:8.3-fpm

# Set the working directory inside the container
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
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

# Copy entrypoint script
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose a default port (e.g., 8080)
EXPOSE ${PORT}

# Use the entrypoint script to start PHP-FPM
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
