#!/bin/bash

# Exit on error
set -e

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Load environment variables
source .env

# List of required environment variables
required_vars=(
    STACK_NAME

    # Server Names
    ADMIN_SERVER_NAME
    APP_SERVER_NAME

    # Database Configuration
    APP_DB_NAME
    DJANGO_DB_NAME
    DB_HOST
    DB_PORT

    # Registry Configuration
    REGISTRY_URL

    # External Services
    SPORTS_API_URL

    # S3 Configuration
    AWS_S3_ENDPOINT_URL
    S3_ROOT_URL
)

export NEXT_PUBLIC_S3_ROOT="${S3_ROOT_URL}/media"

# Check for required environment variables
missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

# Validate DB_PORT is a number
if [[ ! "${DB_PORT}" =~ ^[0-9]+$ ]]; then
    echo "Error: DB_PORT must be a number"
    exit 1
fi

# Validate DB_PORT is in valid range
if [ "${DB_PORT}" -lt 1024 ] || [ "${DB_PORT}" -gt 65535 ]; then
    echo "Error: DB_PORT must be between 1024 and 65535"
    exit 1
fi

# Check for required secrets
required_secrets=(
    # AWS S3 credentials
    aws_s3_access_key_id
    aws_s3_secret_access_key

    # Cache invalidation key for inter-service communication
    cache_invalidate_key

    # Database credentials
    db_app_user             # Application database user
    db_app_password         # Application database password
    db_django_user          # Django database user
    db_django_password      # Django database password

    # Redis credentials
    redis_user              # Redis username
    redis_password          # Redis password

    # Django configuration
    django_secret_key       # Django SECRET_KEY
    django_superuser_email  # Django admin email
    django_superuser_username  # Django admin username
    django_superuser_password  # Django admin password

    # SSL certificates
    cert.crt                # SSL certificate
    cert.key                # SSL private key
)

# Check if secrets exist
missing_secrets=()
for secret in "${required_secrets[@]}"; do
    if ! docker secret ls | grep -q "$secret"; then
        missing_secrets+=("$secret")
    fi
done

# Print errors if any variables or secrets are missing
if [ ${#missing_vars[@]} -ne 0 ] || [ ${#missing_secrets[@]} -ne 0 ]; then
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "Error: Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
    fi

    if [ ${#missing_secrets[@]} -ne 0 ]; then
        echo "Error: Missing required Docker secrets:"
        for secret in "${missing_secrets[@]}"; do
            echo "  - $secret"
        done
        echo "Please create missing secrets using: docker secret create <secret_name> -"
    fi
    exit 1
fi

# Deploy the stack
docker stack deploy -c docker-compose.yml ${STACK_NAME}

echo "Stack deployed successfully!"
