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
  // New mock data begins here
  {
    device_id: "PBX00106",
    name: "Pi Zero 2W",
    type: "PiZero2",
    last_sync_at: "2025-04-20T11:42:15.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-20T11:42:15.000Z",
  },
  {
    device_id: "PBX00107",
    name: "Raspberry Pi 4 - 8GB",
    type: "Pi4-8GB",
    last_sync_at: "2025-04-22T09:33:18.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-22T09:33:18.000Z",
  },
  {
    device_id: "PBX00109",
    name: "Raspberry Pi 3A+",
    type: "Pi3A",
    last_sync_at: "2025-04-18T08:55:42.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-18T08:55:42.000Z",
  },
  {
    device_id: "PBX00110",
    name: "Pi 4 - Kiosk Display",
    type: "Pi4",
    last_sync_at: "2025-04-14T10:22:35.000Z",
    sync_status_code: SyncStatusCode.BadRequest,
    error_message: "Configuration error",
    last_attempt_at: "2025-04-27T16:45:12.000Z",
  },
  {
    device_id: "PBX00111",
    name: "Pi Zero - Camera Module",
    type: "PiZero",
    last_sync_at: "2025-04-11T07:33:19.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-11T07:33:19.000Z",
  },
  {
    device_id: "PBX00112",
    name: "Pi 3B - Weather Station",
    type: "Pi3",
    last_sync_at: "2025-04-17T12:40:27.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-17T12:40:27.000Z",
  },
  {
    device_id: "PBX00113",
    name: "Compute Module 3+",
    type: "CM3",
    last_sync_at: "2025-04-02T16:18:55.000Z",
    sync_status_code: SyncStatusCode.ServerError,
    error_message: "Database connection failed",
    last_attempt_at: "2025-04-25T08:12:33.000Z",
  },
  {
    device_id: "PBX00114",
    name: "Pi 4 - Lab Controller",
    type: "Pi4",
    last_sync_at: "2025-04-21T15:23:41.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-21T15:23:41.000Z",
  },
  {
    device_id: "PBX00115",
    name: "Pi 3B+ Media Center",
    type: "Pi3",
    last_sync_at: "2025-04-19T18:11:02.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-19T18:11:02.000Z",
  },
  {
    device_id: "PBX00116",
    name: "Pi Zero W - IoT Sensor",
    type: "PiZero",
    last_sync_at: "2025-04-03T09:27:14.000Z",
    sync_status_code: SyncStatusCode.BadRequest,
    error_message: "Sensor calibration error",
    last_attempt_at: "2025-04-24T11:36:50.000Z",
  },
  {
    device_id: "PBX00117",
    name: "CM4 - Industrial Control",
    type: "CM4",
    last_sync_at: "2025-04-16T07:55:23.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-16T07:55:23.000Z",
  },
  {
    device_id: "PBX00118",
    name: "Pi 400 - Educational Kit",
    type: "Pi400",
    last_sync_at: "2025-04-24T13:45:19.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-24T13:45:19.000Z",
  },

  {
    device_id: "PBX00120",
    name: "Pi 3A+ - Digital Signage",
    type: "Pi3A",
    last_sync_at: "2025-04-13T14:38:27.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-13T14:38:27.000Z",
  },
  {
    device_id: "PBX00124",
    name: "Pi Zero - Wildlife Camera",
    type: "PiZero",
    last_sync_at: "2025-04-09T06:12:33.000Z",
    sync_status_code: SyncStatusCode.BadRequest,
    error_message: "Low power mode active",
    last_attempt_at: "2025-04-25T16:45:22.000Z",
  },
  {
    device_id: "PBX00125",
    name: "Pi 4 - Home Assistant",
    type: "Pi4",
    last_sync_at: "2025-04-01T10:18:42.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-01T10:18:42.000Z",
  },
  {
    device_id: "PBX00126",
    name: "CM4 - Robotics Platform",
    type: "CM4",
    last_sync_at: "2025-04-06T15:30:58.000Z",
    sync_status_code: SyncStatusCode.ServerError,
    error_message: "API version mismatch",
    last_attempt_at: "2025-04-28T08:22:17.000Z",
  },
  {
    device_id: "PBX00127",
    name: "Pi 3B+ - NAS Server",
    type: "Pi3",
    last_sync_at: "2025-04-07T09:44:51.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-07T09:44:51.000Z",
  },
  {
    device_id: "PBX00128",
    name: "Pi 400 - Classroom",
    type: "Pi400",
    last_sync_at: "2025-04-04T11:28:37.000Z",
    sync_status_code: SyncStatusCode.Success,
    error_message: null,
    last_attempt_at: "2025-04-04T11:28:37.000Z",
  },
];

// Export mock data
export const mockData = {
  createUsers,
  devices,
};
