# Pi Device Sync Management API – Final Docs

This API helps you manage and sync your devices effortlessly. Below is the full breakdown – endpoints, request-response format, error handling, and all that jazz you already know.

---

## 🔗 Base URL

All endpoints start with:

```
/pisync
```

---

## 🔐 Authentication

We use **JWT tokens** for secure access. For protected routes:

```
Authorization: Bearer <your_jwt_token>
```

Token validity = **1 hour**.

---

## 🧑‍💻 Auth Endpoints

### POST `/auth/register`

Registers a new user.

#### Body:

```json
{
  "username": "john_doe",
  "password": "securePassword123"
}
```

#### Success:

```json
{
  "message": "User registered successfully.",
  "token": "<jwt_token_here>"
}
```

#### Errors:

- 400: `{ "message": "Username already exists" }`
- 500: `{ "message": "Server error during registration" }`

---

### POST `/auth/login`

Logs in a user.

#### Body:

```json
{
  "username": "john_doe",
  "password": "securePassword123"
}
```

#### Success:

```json
{
  "message": "Login successful.",
  "token": "<jwt_token_here>"
}
```

#### Errors:

- 401: `{ "message": "Invalid username or password." }`
- 500: `{ "message": "Server error during login" }`

---

## 📱 Device Endpoints

> All device-related endpoints **require auth**.

### GET `/devices`

Retrieves the device list with filtering, pagination, and sorting.

#### Query Params:

| Param              | Type             | Description                                                          | Default        |
| ------------------ | ---------------- | -------------------------------------------------------------------- | -------------- |
| `sync_status_code` | Number or String | Filter by sync status. Use `200` for success or `!200` for failures. | All devices    |
| `page`             | Number           | Page number for pagination.                                          | 1              |
| `limit`            | Number           | Number of items per page.                                            | 10             |
| `sort_by`          | String           | Sort field. Options: `last_sync_at`, `last_attempt_at`.              | `last_sync_at` |
| `order`            | String           | `asc` for ascending, `desc` for descending.                          | `desc`         |

#### Example Requests:

```bash
GET /devices
GET /devices?sync_status_code=200
GET /devices?sync_status_code=!200&page=2&limit=5&sort_by=last_attempt_at&order=asc
```

#### Success Response:

```json
{
  "total": 5,
  "page": 1,
  "limit": 10,
  "total_pages": 1,
  "devices": [
    {
      "device_id": "PBX00121",
      "name": "Raspberry Pi 4B",
      "type": "Pi4",
      "last_sync_at": "2025-04-23T14:30:25.000Z",
      "sync_status_code": 200,
      "error_message": null,
      "last_attempt_at": "2025-04-23T14:30:25.000Z"
    }
  ]
}
```

#### Errors:

- 401: Missing or invalid token
- 500: `{ "message": "Server error while fetching devices" }`

---

### GET `/devices/:id`

Triggers a sync for the device with the given ID.

#### URL Param: `id` (number or string depending on your system)

#### Success:

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

#### Errors:

- 400: `Sync failed: Connection Timeout`
- 404: `Device with ID 123 not found` or `Sync failed: Server Not Reachable`
- 500: `Sync failed: Unknown Sync Error`
- 401: Missing or invalid token

---

## ⚙️ Sync Status Codes

| Code | Meaning      | Possible Errors                                |
| ---- | ------------ | ---------------------------------------------- |
| 200  | Success      | –                                              |
| 400  | Bad Request  | "Connection Timeout", "Authentication Failure" |
| 404  | Not Found    | "Server Not Reachable", "Device not found"     |
| 500  | Server Error | "Unknown Sync Error", "Server Not Reachable"   |

---

## 🧬 Data Models

### `User`

```ts
interface User {
  id: number;
  username: string;
  password: string; // Hashed only, never returned
}
```

### `Device`

```ts
interface Device {
  device_id: number | string;
  name: string;
  type: string;
  last_sync_at: string | null;
  sync_status_code: number | null;
  error_message: string | null;
  last_attempt_at: string | null;
}
```
