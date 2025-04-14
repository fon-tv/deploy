# Fon-TV Deployment Configuration

This repository contains the deployment configuration for the Fon-TV application using Docker Compose. The setup includes multiple services working together to provide a complete streaming platform.

## Architecture Overview

The deployment consists of the following main components:

### Services

1. **Nginx** (`nginx`)
   - Acts as a reverse proxy and load balancer
   - Handles SSL termination
   - Routes traffic to admin and app services
   - Configurable server names for different environments

2. **Redis** (`redis`)
   - Used for caching and session management
   - Runs on port 6385
   - Includes authentication and custom configuration

3. **Admin Service** (`admin`)
   - Django-based administration panel
   - Handles content management and system configuration
   - Integrates with AWS S3 for media storage
   - Connects to PostgreSQL database

4. **App Service** (`app`)
   - Next.js-based frontend application
   - Serves the main user interface
   - Connects to both Redis and PostgreSQL

## Configuration

### Environment Variables

The deployment requires several environment variables to be set:

- `ADMIN_SERVER_NAME`: Domain name for the admin interface
- `APP_SERVER_NAME`: Domain name for the main application
- `CACHE_SERVER_NAME`: Domain name for caching service
- `REGISTRY_URL`: Docker registry URL for images
- `DB_HOST`: Database host address
- `DB_PORT`: Database port
- `APP_DB_NAME`: Application database name
- `DJANGO_DB_NAME`: Django admin database name
- `AWS_S3_ENDPOINT_URL`: S3-compatible storage endpoint
- `SPORTS_API_URL`: External sports API endpoint
- `NEXT_PUBLIC_S3_ROOT`: Public S3 root URL for media

### Secrets

The following secrets must be configured externally:

- AWS S3 credentials
- Database credentials
- Redis credentials
- Django secrets
- SSL certificates

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
4. Create the external network `intranet`

### Required Environment Variables

The following environment variables must be set in your `.env` file:

- `ADMIN_SERVER_NAME`: Domain name for the admin interface
- `APP_SERVER_NAME`: Domain name for the main application
- `APP_DB_NAME`: Application database name
- `DJANGO_DB_NAME`: Django admin database name
- `DB_HOST`: Database host address
- `DB_PORT`: Database port (must be between 1024 and 65535)
- `REGISTRY_URL`: Docker registry URL for images
- `SPORTS_API_URL`: External sports API endpoint
- `AWS_S3_ENDPOINT_URL`: S3-compatible storage endpoint
- `NEXT_PUBLIC_S3_ROOT`: Public S3 root URL for media

### Required Docker Secrets

The following secrets must be created in Docker Swarm before deployment:

- AWS S3 credentials:
  - `aws_s3_access_key_id`
  - `aws_s3_secret_access_key`
- Cache invalidation:
  - `cache_invalidate_key`
- Database credentials:
  - `db_app_user`
  - `db_app_password`
  - `db_django_user`
  - `db_django_password`
- Redis credentials:
  - `redis_user`
  - `redis_password`
- Django configuration:
  - `django_secret_key`
  - `django_superuser_email`
  - `django_superuser_username`
  - `django_superuser_password`
- SSL certificates:
  - `cert.crt`
  - `cert.key`

### Deployment Steps

1. Ensure all prerequisites are met
2. Run the deployment script:

```bash
./deploy.sh
```

The script will validate all requirements and deploy the stack if all checks pass.

## Scaling

The services are configured for replication with the following settings:
- All services run with 1 replica by default
- Update configuration includes:
  - Parallelism: 1
  - Delay: 10s
  - Order: start-first

## Network Configuration

- All services communicate through the `intranet` network
- Nginx exposes ports 80 and 443 for HTTP and HTTPS traffic
- Redis is accessible on port 6385

## Volumes

The deployment uses the following persistent volumes:
- `db_data`: For PostgreSQL data
- `redis_data`: For Redis data

## Security

- SSL/TLS termination at the Nginx level
- Service-to-service communication within internal network
- Authentication required for Redis access
- Secure credential management through Docker secrets

## Maintenance

### Container Management with Swarmpit

The deployment uses Swarmpit for container orchestration and management, which provides:

- Web-based interface for managing Docker Swarm clusters
- Real-time monitoring of services and nodes
- Visual deployment and scaling of services
- Secret and configuration management
- Network and volume management
- Log streaming and container inspection

### Update Procedures

To update the deployment:

1. Update the Docker images
2. Modify the configuration files
3. Update environment variables in `.env` if needed
4. Run the deployment script:

```bash
./deploy.sh
```

The script will validate the configuration and deploy the stack. You can then monitor the deployment in Swarmpit.

### Useful Docker Commands

While Swarmpit provides a web interface, these commands can be useful for quick checks:

- View service status:
  ```bash
  docker service ls
  ```

- Check service logs:
  ```bash
  docker service logs fon-tv_<service_name>
  ```

- Monitor container health:
  ```bash
  docker ps
  ```

### Troubleshooting

Common maintenance tasks:

1. **Service Scaling**
   ```bash
   docker service scale fon-tv_<service_name>=<replicas>
   ```

2. **Service Update**
   ```bash
   docker service update --image <new_image> fon-tv_<service_name>
   ```

3. **Service Rollback**
   ```bash
   docker service rollback fon-tv_<service_name>
   ```

4. **Network Inspection**
   ```bash
   docker network inspect intranet
   ```

5. **Secret Management**
   ```bash
   docker secret ls
   ```

For more detailed monitoring and management, use the Swarmpit web interface.

## Monitoring

The deployment includes basic health checks and monitoring capabilities through Docker Swarm's built-in features. 