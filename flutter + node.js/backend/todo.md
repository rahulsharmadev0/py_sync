Backend with Node.js (Express.js):

- POST /register: Registers a new user by providing a username and password.

Request Body:

```
{
  "username": "john_doe",
  "password": "securePassword123"
}
```

Response:

```
{
  "message": "User registered successfully.",
  "token": "jwt_token_here"
}
```

- POST /login → Purpose: Authenticates an existing user by their username and password.
  Request Body:
  ```
  {
  "username": "john_doe",
  "password": "securePassword123"
  }
  ```

Response (if successful):

```
{
  "message": "Login successful.",
  "token": "jwt_token_here"
}
```

Response (if failure):

```
{
"message": "Invalid username or password."
}

```

- GET /devices → returns list of devices
- POST /devices/:id/sync → mock "Sync Now" action
- GET /errors → returns recent error logs

Data will be hardcoded in arrays/objects inside the server.

Here’s a refined and slightly expanded version of your idea:

#### Data Models:

1. **PiUser**

- **Attributes**:
  - `name`: (string) The user’s name.
  - `password`: (string) User's password (could be hashed).

2. **Device Sync Table**

- **Attributes**:
  - `device_id`: (int) Unique identifier for each device.
  - `last_sync_at`: (ISO-8601 string) The last successful sync timestamp in format `yyyy-MM-ddTHH:mm:ss.mmmuuuZ`.
  - `sync_status_code`: (int) Status code representing the sync result.
    - Possible values:
      - `200 OK` – Success
      - `202 Accepted` – Pending
      - `400 Bad Request` – Failed
      - `404 Not Found` – Failed
      - `500 Internal Server Error` – Failed
  - `error_message`: (string) Error message corresponding to `sync_status_code`. Examples include:
    - "Connection Timeout"
    - "Storage Full"
    - "Unknown Sync Error"
    - "Authentication Failure"
    - "Server Not Reachable"
  - `last_attempt_at`: (ISO-8601 string) The timestamp of the last sync attempt in format `yyyy-MM-ddTHH:mm:ss.mmmuuuZ`.

#### Rules:

- `last_sync_at <= last_attempt_at`: The timestamp of the last successful sync must always be before or equal to the last sync attempt.
