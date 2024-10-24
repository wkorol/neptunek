#!/bin/sh

# Check if $PORT is available and log it
echo "Using port: ${PORT}"

# Update PHP-FPM config to listen on the correct port at runtime
if [ -z "$PORT" ]; then
  echo "Error: \$PORT is not set"
  exit 1
fi

# Configure PHP-FPM to listen on the dynamic port
# This specifically targets lines with 'listen = 127.0.0.1:9000'
sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:'${PORT}'/' /usr/local/etc/php-fpm.d/www.conf

# Display the updated configuration for debugging
cat /usr/local/etc/php-fpm.d/www.conf

# Start PHP-FPM
php-fpm
