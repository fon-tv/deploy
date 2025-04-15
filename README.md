# SWARM Django NextJS Deployment Configuration

This repository contains the deployment configuration for the NextJS application using Docker Swarm. The setup includes admin panel(Django), Redis for caching and Nginx as reverse-proxy.

## Architecture Overview

The deployment consists of the following main components:

### Services

1. **Nginx** (`nginx`)
   - Acts as a reverse proxy and load balancer
   - Handles SSL termination
   - Routes traffic to admin and app services
   - Configurable server names for different environments

2. **Db** (`db`)
   - Postgresql database
   - Runs on port 5432
   - Data storage

3. **Redis** (`redis`)
   - Used for caching and session management
   - Runs on port 6385
   - Includes authentication and custom configuration

4. **Admin Service** (`admin`)
   - Django-based administration panel
   - Handles content management and system configuration
   - Integrates with AWS S3 for media storage
   - Connects to PostgreSQL database

5. **App Service** (`app`)
   - Next.js-based frontend application
   - Serves the main user interface
   - Connects to both Redis and PostgreSQL

## Configuration

### Environment Variables

The deployment requires several environment variables to be set in your `.env` file:

#### Settings
- `STACK_NAME`: The name of stack in docker swarm

#### Server Names
- `ADMIN_SERVER_NAME`: Domain name for the admin interface
- `APP_SERVER_NAME`: Domain name for the main application

#### Database Configuration
- `DB_HOST`: Database host address
- `DB_PORT`: Database port (must be between 1024 and 65535)
- `APP_DB_NAME`: Application database name
- `DJANGO_DB_NAME`: Django admin database name

#### Registry Configuration
- `REGISTRY_URL`: Docker registry URL for images

#### External Services
- `SPORTS_API_URL`: External sports API endpoint

#### S3 Configuration
- `AWS_S3_ENDPOINT_URL`: S3-compatible storage endpoint
- `S3_MEDIA_URL`: Public S3 media URL

### Secrets

The following secrets must be created in Docker Swarm before deployment:

#### AWS S3 credentials
- `aws_s3_access_key_id`
- `aws_s3_secret_access_key`

#### Cache invalidation
- `cache_invalidate_key`

#### Database credentials
- `db_password`: Database root password
- `db_app_user`: Application database user
- `db_app_password`: Application database password
- `db_django_user`: Django database user
- `db_django_password`: Django database password

#### Redis credentials
- `redis_user`: Redis username
- `redis_password`: Redis password

#### Django configuration
- `django_secret_key`: Django SECRET_KEY
- `django_superuser_email`: Django admin email
- `django_superuser_username`: Django admin username
- `django_superuser_password`: Django admin password

#### SSL certificates
- `cert.crt`: SSL certificate
- `cert.key`: SSL private key

## Deployment

The deployment process is automated using the `deploy.sh` script, which:
- Validates the presence of required environment variables
- Checks for required Docker secrets
- Validates configuration values
- Deploys the stack with proper environment variable substitution

### Prerequisites

1. Create a `.env` file with all required environment variables
2. Create all required Docker secrets
3. Ensure Docker Swarm is initialized
4. Create the external network `intranet` in swarm scope
