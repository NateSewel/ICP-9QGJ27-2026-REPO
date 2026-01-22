# Application Setup

## Prerequisites

- Node.js v20 LTS
- npm v10+

## Installation

1. Navigate to the api directory:
   ```bash
   cd user-management-api
   ```
2. Install dependencies:
   ```bash
   npm install
   ```

## Environment Variables

Create a `.env` file in the `user-management-api` root:

```env
PORT=3000
DB_HOST=localhost
DB_NAME=user_management
DB_USER=postgres
DB_PASSWORD=password
JWT_SECRET=your_jwt_secret
```

## Available Scripts

- `npm start`: Runs the production server.
- `npm run dev`: Runs the server in development mode with nodemon.
- `npm test`: Runs the test suite using Jest.
- `npm run lint`: Runs ESLint for code quality checks.
- `npm run format`: Formats code with Prettier.
