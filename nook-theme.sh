curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv

chmod -R 755 storage/* bootstrap/cache
composer install --no-dev --optimize-autoloader
composer install --no-dev --optimize-autoloader
php artisan view:clear
php artisan config:clear

# If using NGINX or Apache (not on CentOS):
chown -R www-data:www-data /var/www/pterodactyl/*

php artisan queue:restart
php artisan up
