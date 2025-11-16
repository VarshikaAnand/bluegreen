#!/bin/bash

set -e

IMAGE=$1

echo "Pulling image..."
docker pull $IMAGE

echo "Updating Blue or Green..."
RUNNING=$(docker ps --filter "name=blue" --format "{{.ID}}")

if [ "$RUNNING" = "" ]; then
    TARGET="blue"
else
    TARGET="green"
fi

echo "Deploying to $TARGET..."
docker compose stop $TARGET
docker compose rm -f $TARGET

docker compose up -d $TARGET

echo "Reloading Nginx..."
docker exec $(docker ps --filter "name=nginx" -q) nginx -s reload

echo "Deployment to $TARGET completed!"
