#!/bin/bash
set -e

echo "🚀 Starting Blue-Green deployment..."

# Detect which environment (blue/green) is currently active
active_container=$(docker ps --format "{{.Names}}" | grep -E "blue|green" || true)

if echo "$active_container" | grep -q "blue"; then
  new_env="green"
  old_env="blue"
else
  new_env="blue"
  old_env="green"
fi

echo "🟢 New environment: $new_env"
echo "🔵 Old environment: $old_env"

echo "Starting new container..."
docker-compose up -d --no-deps --build "$new_env"

sleep 5

echo "Updating NGINX configuration..."
nginx_conf="./nginx/upstream_app.conf"

if [ "$new_env" = "blue" ]; then
  sed -i 's/green:3000/blue:3000/g' "$nginx_conf"
else
  sed -i 's/blue:3000/green:3000/g' "$nginx_conf"
fi

docker exec nginx-proxy nginx -s reload

echo "Checking health of $new_env..."
health=$(curl -s http://localhost/health || true)

if echo "$health" | grep -q "UP"; then
  echo "✅ $new_env is healthy!"
  echo "Stopping old container: $old_env"
  docker stop "$old_env" >/dev/null 2>&1 || true
  docker rm "$old_env" >/dev/null 2>&1 || true
  echo "🎉 Deployment complete! $new_env is now active."
else
  echo "❌ Health check failed! Rolling back..."
  if [ "$new_env" = "blue" ]; then
    sed -i 's/blue:3000/green:3000/g' "$nginx_conf"
  else
    sed -i 's/green:3000/blue:3000/g' "$nginx_conf"
  fi
  docker exec nginx-proxy nginx -s reload
  docker stop "$new_env" >/dev/null 2>&1 || true
  echo "🔄 Rolled back to $old_env."
fi
