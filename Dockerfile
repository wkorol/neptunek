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

# Expose port 8000 for Heroku (Heroku will map it to the dynamic port)
EXPOSE 8000

# Heroku provides a dynamic port that you should bind to
CMD symfony server:start --port $PORT --no-tls
