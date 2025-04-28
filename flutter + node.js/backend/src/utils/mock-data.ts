import {
  User,
  Device,
  SyncStatusCodeMessage,
  SyncStatusCode,
} from "../models/models";
import bcrypt from "bcrypt";

// Function to create hashed password
const createHashPassword = async (password: string): Promise<string> => {
  const salt = await bcrypt.genSalt(10);
  return await bcrypt.hash(password, salt);
};

// Create mock users with hashed passwords
const createUsers = async (): Promise<User[]> => {
  const salt = await bcrypt.genSalt(10);

  return [
    {
      id: 1,
      username: "rahulsharma",
      password: await createHashPassword("rahulsharma123"),
    },
    {
      id: 2,
      username: "rahulsharmadev",
      password: await createHashPassword("rahulsharmadev123"),
    },
    {
      id: 2,
      username: "admin",
      password: await createHashPassword("admin123"),
    },
  ];
};

// Mock devices with data from April 1-28, 2025
const devices: Device[] = [
  {
    device_id: "PBX00121",
    name: "Raspberry Pi 4B",
    type: "Pi4",
    last_sync_at: "2025-04-23T14:30:25.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-23T14:30:25.000Z",
  },
  {
    device_id: "PBX00122",
    name: "Pi Zero W",
    type: "PiZero",
    last_sync_at: "2025-04-15T09:45:12.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-26T11:20:33.000Z",
  },
  {
    device_id: "PBX00123",
    name: "Raspberry Pi 3B+",
    type: "Pi3",
    last_sync_at: "2025-04-10T16:22:08.000Z",
    sync_status_code: SyncStatusCode.BadRequest,
    error_message: "Connection Timeout",
    last_attempt_at: "2025-04-27T18:15:42.000Z",
  },
  {
    device_id: "PBX00104",
    name: "Compute Module 4",
    type: "CM4",
    last_sync_at: "2025-04-05T08:10:30.000Z",
    sync_status_code: SyncStatusCode.ServerError,
    error_message: SyncStatusCodeMessage.ServerError,
    last_attempt_at: "2025-04-25T10:05:18.000Z",
  },
  {
    device_id: "PBX00105",
    name: "Pi 400",
    type: "Pi400",
    last_sync_at: "2025-04-05T08:10:30.000Z",
    sync_status_code: SyncStatusCode.ServerError,
    error_message: SyncStatusCodeMessage.ServerError,
    last_attempt_at: "2025-04-25T10:05:18.000Z",
  },
];

// Export mock data
export const mockData = {
  createUsers,
  devices,
};
