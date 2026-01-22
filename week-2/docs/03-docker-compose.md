# Docker Compose Guide

## Overview

Docker Compose is used for local development and integration testing. It orchestrates the API and the PostgreSQL database.

## Services

1. **api**:
   - Built from `./user-management-api/Dockerfile`.
   - Exposed on port `3000`.
   - Depends on the `db` service.
2. **db**:
   - Uses `postgres:16-alpine`.
   - Includes a health check to ensure the API only starts when the DB is ready.

## Usage

### Start Services

```bash
docker-compose up -d
```

### Stop Services

```bash
docker-compose down
```

### View Logs

```bash
docker-compose logs -f api
```

### Rebuild API

```bash
docker-compose up -d --build api
```
