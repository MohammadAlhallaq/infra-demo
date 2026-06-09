set -e

echo "🚀 Starting deployment..."

cd /home/ubuntu/laravel-app

echo "📥 Pulling latest code..."
git pull origin main

echo "🐳 Rebuilding containers..."
docker compose down
docker compose up -d --build

echo "⚙️ Running Laravel setup..."

docker exec laravel_app php artisan migrate --force || true
docker exec laravel_app php artisan config:cache
docker exec laravel_app php artisan route:cache
docker exec laravel_app php artisan view:cache

echo "🧹 Cleaning old images..."
docker image prune -f

echo "✅ Deployment completed successfully!"