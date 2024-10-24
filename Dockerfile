# Use the official PHP image as the base image
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install intl opcache pdo pdo_mysql zip mbstring

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory
WORKDIR /var/www/symfony

# Copy the project files to the container
COPY . .

# Install Symfony dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions for Symfony var directory
RUN chown -R www-data:www-data /var/www/symfony/var

# Expose the port that PHP-FPM will run on
EXPOSE 9000

# Start the PHP-FPM service
CMD ["php-fpm"]
