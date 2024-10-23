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

# Copy the application files into the container
COPY . /var/www/html

# Set permissions for Symfony folders
RUN chown -R www-data:www-data /var/www/html/var \
    && chmod -R 775 /var/www/html/var

# Install Composer dependencies for production
RUN composer install --no-dev --optimize-autoloader

# Ensure PHP-FPM listens on the port specified by Heroku
RUN echo "listen = 0.0.0.0:${PORT}" >> /usr/local/etc/php-fpm.d/www.conf

# Expose the port
EXPOSE ${PORT}

# Start PHP-FPM
CMD ["php-fpm"]
