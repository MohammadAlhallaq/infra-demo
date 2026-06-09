set -e

echo " Starting deployment..."

cd /home/ubuntu/laravel-app

echo " Pulling latest code..."
git pull origin main

echo " Building and starting containers..."
docker compose down
docker compose up -d --build

echo " Waiting for app container to be ready..."
until docker exec laravel_app php -v > /dev/null 2>&1; do
    sleep 1
done

echo " Installing Composer dependencies..."
docker exec -w /var/www laravel_app composer install --no-dev --optimize-autoloader

echo " Setting up environment..."
if [ ! -f .env ]; then
    cp .env.example .env
    docker exec -w /var/www laravel_app php artisan key:generate
fi

echo " Setting permissions..."
docker exec laravel_app chown -R www-data:www-data storage bootstrap/cache

echo " Running Laravel setup..."
docker exec -w /var/www laravel_app php artisan migrate --force
docker exec -w /var/www laravel_app php artisan config:cache
docker exec -w /var/www laravel_app php artisan route:cache
docker exec -w /var/www laravel_app php artisan view:cache

echo " Cleaning old images..."
docker image prune -f

echo " Deployment completed successfully!"
