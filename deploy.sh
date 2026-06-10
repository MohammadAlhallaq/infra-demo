set -e

echo " Starting deployment..."

cd /home/ubuntu/infra-demo

echo " Pulling latest code..."
git pull origin main

echo " Setting up environment..."
if [ ! -f .env ]; then
    cp .env.example .env
fi

echo " Cleaning up Docker disk space..."
docker system prune -af

echo " Building and starting containers..."
docker compose down

echo " Logging into ECR..."
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 518473019356.dkr.ecr.us-west-2.amazonaws.com

if [ -n "$IMAGE" ]; then
  docker pull "$IMAGE"
  docker tag "$IMAGE" infra-demo-app:latest
  docker compose up -d
else
  docker compose up -d --build
fi

echo " Waiting for app container to be ready..."
until docker exec app php -v > /dev/null 2>&1; do
    sleep 1
done

echo " Generating app key if missing..."
docker exec -w /var/www app php artisan key:generate --force

echo " Installing Composer dependencies..."
docker exec -w /var/www app composer install --no-dev --optimize-autoloader

echo " Installing AWS CLI if missing..."
if ! command -v aws &> /dev/null; then
  if command -v apt-get &> /dev/null; then
    sudo apt-get update -y 2>/dev/null || true
    sudo apt-get install -y unzip 2>/dev/null || true
  fi

  if command -v unzip &> /dev/null; then
    curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && sudo /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip
  fi

  if ! command -v aws &> /dev/null; then
    pip3 install awscli --user 2>/dev/null || pip install awscli --user 2>/dev/null || true
  fi
fi

if ! command -v aws &> /dev/null; then
  echo " ERROR: AWS CLI could not be installed. Aborting."
  exit 1
fi

echo " Fetching DB_PASSWORD from SSM..."
set -a && source .env && set +a
DB_PASSWORD=$(aws ssm get-parameter \
  --name "/infra-demo/DB_PASSWORD" \
  --with-decryption \
  --region us-west-2 \
  --query Parameter.Value \
  --output text)
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASSWORD|" .env

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
