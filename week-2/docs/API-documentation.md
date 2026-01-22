# API Documentation

The User Management API provides endpoints for user registration, authentication, and CRUD operations.

## Base URL
`http://<alb-dns-name>`

## Authentication
JWT-based authentication. Include the token in the `Authorization` header:
`Authorization: Bearer <token>`

## Endpoints

### 1. Health Check
- **URL**: `/api/health`
- **Method**: `GET`
- **Auth**: None
- **Success Response**: `200 OK`

### 2. User Registration
- **URL**: `/api/users`
- **Method**: `POST`
- **Auth**: None
- **Body**:
  ```json
  {
    "username": "johndoe",
    "email": "john@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }
  ```

### 3. User Login
- **URL**: `/api/users/login`
- **Method**: `POST`
- **Auth**: None
- **Body**:
  ```json
  {
    "username": "johndoe",
    "password": "password123"
  }
  ```
- **Response**: `{ "token": "..." }`

### 4. Get All Users
- **URL**: `/api/users`
- **Method**: `GET`
- **Auth**: Required

### 5. Get User by ID
- **URL**: `/api/users/:id`
- **Method**: `GET`
- **Auth**: Required

### 6. Update User
- **URL**: `/api/users/:id`
- **Method**: `PUT`
- **Auth**: Required

### 7. Delete User
- **URL**: `/api/users/:id`
- **Method**: `DELETE`
- **Auth**: Required (Admin only)
