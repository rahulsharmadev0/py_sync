// User model
export interface User {
  id: number;
  username: string;
  password: string;
}

// Device model
export interface Device {
  device_id: string;
  name: string;
  type: string;
  last_sync_at: string | null;
  sync_status_code: number | null;
  error_message: string | null;
  last_attempt_at: string | null;
}

// Sync Status codes
export enum SyncStatusCode {
  Success = 200,
  BadRequest = 400,
  NotFound = 404,
  ServerError = 500,
}
// 😅 Again hardcoded...
export enum SyncStatusCodeMessage {
  Success = "Sync Successful",
  BadRequest = "Authentication Failure",
  NotFound = "Connection Timeout",
  ServerError = "Server Not Reachable",
}
