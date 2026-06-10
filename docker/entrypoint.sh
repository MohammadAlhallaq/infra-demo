#!/bin/sh
set -e

# Fetch DB_PASSWORD from SSM and write it to .env
if [ -f /var/www/.env ]; then
  DB_PASSWORD=$(aws ssm get-parameter \
    --name "/infra-demo/DB_PASSWORD" \
    --with-decryption \
    --region us-west-2 \
    --query Parameter.Value \
    --output text)

  sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASSWORD|" /var/www/.env
fi

exec "$@"
