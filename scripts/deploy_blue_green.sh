#!/bin/bash

set -e

IMAGE=$1
COMPOSE="/var/jenkins_home/workspace/bg-pipeline/docker-compose.yml"

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

docker compose -f $COMPOSE stop $TARGET || true
docker compose -f $COMPOSE rm -f $TARGET || true
docker compose -f $COMPOSE up -d $TARGET

echo "Reloading Nginx..."
docker exec $(docker ps --filter "name=nginx" -q) nginx -s reload

echo "Deployment to $TARGET completed!"
