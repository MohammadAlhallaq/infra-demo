set -e

echo " Starting deployment..."

cd /home/ubuntu/infra-demo

echo " Pulling latest code..."
git pull origin main

echo " Setting up environment..."
if [ ! -f .env ]; then
    cp .env.example .env
fi

echo " Building and starting containers..."
docker compose down
docker compose up -d --build

echo " Waiting for app container to be ready..."
until docker exec app php -v > /dev/null 2>&1; do
    sleep 1
done

echo " Generating app key if missing..."
docker exec -w /var/www app php artisan key:generate --force

echo " Installing Composer dependencies..."
docker exec -w /var/www app composer install --no-dev --optimize-autoloader

echo " Setting permissions..."
docker exec app chown -R www-data:www-data storage bootstrap/cache

echo " Creating database if it doesn't exist..."
docker exec -w /var/www app bash -c "
  source .env && mysql -h \$DB_HOST -u \$DB_USERNAME -p\$DB_PASSWORD -e \"CREATE DATABASE IF NOT EXISTS \$DB_DATABASE\" 2>/dev/null || true
"

echo " Running Laravel setup..."
docker exec -w /var/www app php artisan migrate --force
docker exec -w /var/www app php artisan config:cache
docker exec -w /var/www app php artisan route:cache
docker exec -w /var/www app php artisan view:cache

echo " Cleaning old images..."
docker image prune -f

echo " Deployment completed successfully!"
