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
  last_sync_at: string | null; // pi device last sync time to server
  sync_status_code: number | null; // sync status code from server
  error_message: string | null; // error message if pi device sync failed to server
  last_attempt_at: string | null;
}

// Could be possible Sync Status codes
// While pi device is syncing to server
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
