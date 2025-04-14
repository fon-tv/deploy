#!/bin/sh
set -e

# Install envsubst if not present
if ! command -v envsubst >/dev/null 2>&1; then
    apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*
fi

# Read secrets from Docker secrets
if [ -f /run/secrets/redis_user ]; then
    export REDIS_USER=$(cat /run/secrets/redis_user)
fi
if [ -f /run/secrets/redis_password ]; then
    export REDIS_PASSWORD=$(cat /run/secrets/redis_password)
fi


# Generate final redis.conf from template
envsubst < /usr/local/etc/redis/redis.conf.template > /usr/local/etc/redis/redis.conf

# Execute the original Redis entrypoint
exec docker-entrypoint.sh "$@" 