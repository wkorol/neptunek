#!/bin/sh
# Update PHP-FPM config to listen on the correct port at runtime
sed -i 's/listen = \/run\/php\/php-fpm.sock/listen = 0.0.0.0:'${PORT}'/' /usr/local/etc/php-fpm.d/www.conf

# Display the updated configuration for debugging
cat /usr/local/etc/php-fpm.d/www.conf

# Start PHP-FPM
php-fpm
