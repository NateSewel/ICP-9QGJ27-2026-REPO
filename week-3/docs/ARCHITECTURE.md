# Architecture Overview

```mermaid
graph TD
    User((User)) --> ALB[Application Load Balancer]
    ALB --> EC2_1[API Gateway - EC2]
    ALB --> EC2_2[Microservice - EC2]
    
    EC2_1 --> Redis[(ElastiCache Redis)]
    EC2_1 --> SQS[[AWS SQS]]
    EC2_1 --> RDS[(RDS PostgreSQL)]
    EC2_1 --> Vault[HashiCorp Vault]
    
    EC2_2 --> RDS
    EC2_2 --> SQS
    
    EC2_1 --> WeatherAPI[External Weather API]
    EC2_1 --> Stripe[External Payment API]
```

## Component Details

### 1. API Gateway
The primary entry point for all requests. Handles rate limiting, authentication (via Vault), and request aggregation.

### 2. Caching Layer
Redis is used for:
- API response caching (e.g., weather data)
- Session management
- Distributed locking

### 3. Messaging
SQS handles asynchronous tasks such as:
- Sending emails
- Processing payments
- Background data synchronization

### 4. Database
PostgreSQL 16 stores persistent data:
- User profiles
- Transaction history
- System configurations
