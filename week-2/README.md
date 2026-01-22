# User Management System (Week 2)

A production-ready User Management REST API built with Node.js, Express, and PostgreSQL, deployed on AWS using Terraform and GitHub Actions.

## Architecture

- **Application Layer**: Node.js (Express) running in Docker containers.
- **Compute**: AWS Auto Scaling Group (ASG) behind an Application Load Balancer (ALB).
- **Database**: Self-managed PostgreSQL on a dedicated EC2 instance.
- **Infrastructure**: VPC with public and private subnets across multiple AZs.
- **CI/CD**: GitHub Actions for automated testing and infrastructure deployment.

## Tech Stack

- **Backend**: Node.js v20, Express, Sequelize ORM
- **Database**: PostgreSQL 16
- **IaC**: Terraform v1.14.3
- **DevOps**: Docker, Docker Compose, GitHub Actions, AWS ECR

## Quick Start

### Local Development

1. Clone the repository
2. Install dependencies:
   ```bash
   cd user-management-api
   npm install
   ```
3. Run with Docker Compose:
   ```bash
   docker-compose up --build
   ```
4. Access the API at `http://localhost:3000`

### Running Tests

```bash
cd user-management-api
npm test
```

## Project Structure

```
week-2/
├── user-management-api/   # Node.js Application
├── terraform/             # Infrastructure as Code
├── .github/workflows/      # CI/CD Pipelines
├── docs/                  # Detailed Documentation
└── screenshots/           # Implementation Evidence
```

## Security

- JWT Authentication for protected routes.
- BCrypt for password hashing.
- Private subnets for application and database instances.
- Least privilege Security Group rules.
- S3 Backend for Terraform with encryption and locking.

## Documentation

- [Application Setup](./docs/01-application-setup.md)
- [Database Integration](./docs/02-database-integration.md)
- [Docker Compose Guide](./docs/03-docker-compose.md)
- [AWS Deployment](./docs/04-aws-deployment.md)
- [API Documentation](./docs/API-documentation.md)
