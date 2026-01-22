# Database Integration

## Overview

The application uses **PostgreSQL** as its primary database and **Sequelize** as the Object-Relational Mapper (ORM).

## Schema (User Model)

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary Key (Auto-generated) |
| username | String | Unique, Required |
| email | String | Unique, Required, Validated |
| password | String | Hashed using BCrypt |
| firstName | String | Optional |
| lastName | String | Optional |
| role | Enum | 'admin' or 'user' |
| isActive | Boolean | Defaults to true |

## Configuration

The database connection is managed in `src/config/database.js`. It supports connection pooling and uses environment variables for flexibility.

## Development vs Production

- **Local**: Uses the `db` service in `docker-compose.yml`.
- **AWS**: Connects to a self-managed PostgreSQL instance on a dedicated EC2 within the private subnet.

## Syncing

The application uses `sequelize.sync()` on startup to ensure the schema exists. In a larger production environment, Sequelize Migrations would be preferred.
