#!/bin/sh

# Check if $PORT is available and log it
echo "Using port: ${PORT}"

# Update PHP-FPM config to listen on the correct port at runtime
if [ -z "$PORT" ]; then
  echo "Error: \$PORT is not set"
  exit 1
fi

# Configure PHP-FPM to listen on the dynamic port
sed -i 's/listen = \/run\/php\/php-fpm.sock/listen = 127.0.0.1:'${PORT}'/' /usr/local/etc/php-fpm.d/www.conf

# Display the updated configuration for debugging
cat /usr/local/etc/php-fpm.d/www.conf

# Start PHP-FPM
php-fpm
