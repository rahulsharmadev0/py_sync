# Pi Device Sync Management API

Node.js backend server built with TypeScript and Express to manage device synchronization.

## Overview

This API provides endpoints

- authenticating pisync admin users
- managing devices
- tracking synchronization statuses and error logs.
- It includes hardcoded mock data.

## Features

- User authentication with JWT
- Device management
- Device synchronization
- Error logging and tracking
- CORS-enabled for cross-origin requests

## Prerequisites

- Node.js (v14 or higher)
- npm or yarn

## Getting Started

### Installation

1. Clone the repository
2. Install dependencies
3. Ready to Run 🤘

```bash
npm install

npm run dev # Development Mode

npm run build #### Production Mode

npm start
```

The server will run at http://localhost:3000 by default.

## API Endpoints

### Authentication

- **POST /pisync/auth/register**: Register a new user
- **POST /pisync/auth/login**: Login with existing credentials

  ```bash
  # Same for both register & login
  {
    "username": "your_username",
    "password": "your_password"
  }
  ```

### Devices (Requires Authentication)

- **GET /pisync/devices**: Get all devices
- **GET /pisync/devices/:id**: Trigger synchronization for a specific device

## Authentication

All device endpoints require a valid JWT token. Include the token in the Authorization header:

```
Authorization: Bearer YOUR_JWT_TOKEN
```

## 😅 Why are you waiting for just run it...
