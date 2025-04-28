import { Request, Response } from "express";
import { mockData } from "../utils/mock-data";
import { Device, SyncStatusCode } from "../models/models";

export class DeviceController {
  private devices: Device[] = [];

  constructor() {
    // Initialize with mock data
    this.devices = [...mockData.devices];
  }

  public getAllDevices = (req: Request, res: Response) => {
    try {
      return res.status(200).json({
        count: this.devices.length,
        devices: this.devices,
      });
    } catch (error) {
      console.error("Error fetching devices:", error);
      return res
        .status(500)
        .json({ message: "Server error while fetching devices" });
    }
  };

  public syncDevice = (req: Request, res: Response) => {
    try {
      const { id } = req.params;

      // Find device by ID
      const deviceIndex = this.devices.findIndex(
        (device) => device.device_id === id
      );

      if (deviceIndex === -1) {
        return res
          .status(404)
          .json({ message: `Device with ID ${id} not found` });
      }

      // Update device sync status
      const now = new Date().toISOString();

      // Simulate a successful sync 80% of the time, an error 20% of the time
      // 😅 Let's see how can I handle at frontend
      if (Math.random() < 0.8) {
        this.devices[deviceIndex] = {
          ...this.devices[deviceIndex],
          last_sync_at: now,
          sync_status_code: SyncStatusCode.Success,
          error_message: null,
          last_attempt_at: now,
        };

        return res.status(200).json({
          message: "Device synced successfully",
          device: this.devices[deviceIndex],
        });
      } else {
        // Simulate a random error
        const errorTypes = [
          { code: SyncStatusCode.BadRequest, message: "Connection Timeout" },
          { code: SyncStatusCode.NotFound, message: "Server Not Reachable" },
          { code: SyncStatusCode.ServerError, message: "Unknown Sync Error" },
        ];

        const randomError =
          errorTypes[Math.floor(Math.random() * errorTypes.length)];

        this.devices[deviceIndex] = {
          ...this.devices[deviceIndex],
          last_sync_at: this.devices[deviceIndex].last_sync_at, // Keep the last successful sync
          sync_status_code: randomError.code,
          error_message: randomError.message,
          last_attempt_at: now,
        };

        return res.status(randomError.code).json({
          message: `Sync failed: ${randomError.message}`,
          device: this.devices[deviceIndex],
        });
      }
    } catch (error) {
      console.error("Error syncing device:", error);
      return res
        .status(500)
        .json({ message: "Server error while syncing device" });
    }
  };
}
