# Device Sync Management API Contract

This document outlines the available API endpoints, request/response formats, and authentication requirements for the Device Sync Management API.

## Base URL

All endpoints are prefixed with `/pisync`

## Authentication

### Token Format

Authentication is handled using JWT (JSON Web Tokens). For protected endpoints, include the token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

The token expires after 1 hour.

## Endpoints

### Authentication

#### Register User

- **URL**: `/auth/register`
- **Method**: `POST`
- **Authentication**: None
- **Request Body**:
  ```json
  {
    "username": "john_doe",
    "password": "securePassword123"
  }
  ```
- **Success Response**:
  - **Code**: 201 Created
  - **Content**:
    ```json
    {
      "message": "User registered successfully.",
      "token": "<jwt_token_here>"
    }
    ```
- **Error Responses**:
  - **Code**: 400 Bad Request
    - **Content**: `{ "message": "Username already exists" }`
  - **Code**: 500 Internal Server Error
    - **Content**: `{ "message": "Server error during registration" }`

#### Login User

- **URL**: `/auth/login`
- **Method**: `POST`
- **Authentication**: None
- **Request Body**:
  ```json
  {
    "username": "john_doe",
    "password": "securePassword123"
  }
  ```
- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "message": "Login successful.",
      "token": "<jwt_token_here>"
    }
    ```
- **Error Responses**:
  - **Code**: 401 Unauthorized
    - **Content**: `{ "message": "Invalid username or password." }`
  - **Code**: 500 Internal Server Error
    - **Content**: `{ "message": "Server error during login" }`

### Devices

All device endpoints require authentication.

#### Get All Devices

- **URL**: `/devices`
- **Method**: `GET`
- **Authentication**: Required
- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "count": 5,
      "devices": [
        {
          "device_id": 101,
          "name": "Raspberry Pi 4B",
          "type": "Pi4",
          "last_sync_at": "2025-04-23T14:30:25.000Z",
          "sync_status_code": 200,
          "error_message": null,
          "last_attempt_at": "2025-04-23T14:30:25.000Z"
        }
        // ... more devices
      ]
    }
    ```
- **Error Responses**:
  - **Code**: 401 Unauthorized
    - **Content**: `{ "message": "No auth token provided" }` or `{ "message": "Invalid auth token" }`
  - **Code**: 500 Internal Server Error
    - **Content**: `{ "message": "Server error while fetching devices" }`

#### Sync Device

- **URL**: `/devices/:id`
- **Method**: `GET`
- **URL Parameters**: `id` - Device ID to sync
- **Authentication**: Required
- **Success Response**:
  - **Code**: 200 OK
  - **Content**:
    ```json
    {
      "message": "Device synced successfully",
      "device": {
        "device_id": 101,
        "name": "Raspberry Pi 4B",
        "type": "Pi4",
        "last_sync_at": "2025-04-28T10:30:25.000Z",
        "sync_status_code": 200,
        "error_message": null,
        "last_attempt_at": "2025-04-28T10:30:25.000Z"
      }
    }
    ```
- **Error Responses**:
  - **Code**: 400 Bad Request
    - **Content**: `{ "message": "Sync failed: Connection Timeout", "device": {...} }`
  - **Code**: 404 Not Found
    - **Content**: `{ "message": "Device with ID 123 not found" }` or
      `{ "message": "Sync failed: Server Not Reachable", "device": {...} }`
  - **Code**: 500 Internal Server Error
    - **Content**: `{ "message": "Sync failed: Unknown Sync Error", "device": {...} }` or
      `{ "message": "Server error while syncing device" }`
  - **Code**: 401 Unauthorized
    - **Content**: `{ "message": "No auth token provided" }` or `{ "message": "Invalid auth token" }`

## Status Codes and Error Messages

The API uses the following status codes for sync operations:

| Status Code | Description  | Possible Error Messages                        |
| ----------- | ------------ | ---------------------------------------------- |
| 200         | Success      | None                                           |
| 400         | Bad Request  | "Connection Timeout", "Authentication Failure" |
| 404         | Not Found    | "Server Not Reachable", "Device not found"     |
| 500         | Server Error | "Unknown Sync Error", "Server Not Reachable"   |

## Data Models

### User

```typescript
interface User {
  id: number;
  username: string;
  password: string; // Hashed, never returned to client
}
```

### Device

```typescript
interface Device {
  device_id: number;
  name: string;
  type: string;
  last_sync_at: string | null;
  sync_status_code: number | null;
  error_message: string | null;
  last_attempt_at: string | null;
}
```

## Notes for Frontend Implementation (Which Is again done by me 😅)

1. **Authentication Handling**:

   - Store the JWT token securely (e.g., in HttpOnly cookies or localStorage)
   - Include the token in all requests to protected endpoints
   - Implement token refresh or redirect to login when the token expires

2. **Error Handling**:

   - Implement robust error handling for different status codes
   - Display appropriate user-friendly messages based on error responses
   - Handle network failures gracefully

3. **Sync Status Visualization**:

   - Use status codes to display appropriate sync status indicators
   - Show last successful sync time and last attempt time
   - Display error messages when sync fails

4. **Sync Operation**:

   - The sync operation has an 80% chance of success and 20% chance of failure (simulated)
   - Handle both success and error cases in your UI
   - Provide retry functionality for failed syncs

5. **Testing**:
   - You can use the mock credentials provided in the mock data:
   - Username: "john_doe", Password: "password123"
   - Username: "jane_smith", Password: "securePass456"
