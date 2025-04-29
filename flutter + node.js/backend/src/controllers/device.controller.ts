import { Request, Response } from "express";
import { mockData } from "../utils/mock-data";
import { Device, Logs, SyncStatusCode } from "../models/models";

export class DeviceController {
  private devices: Device[] = [];
  private logs: Logs[] = [];

  constructor() {
    // Initialize with mock data
    this.devices = [...mockData.devices];
    this.logs = [
      ...mockData.devices
        .filter((device) => device.sync_status_code !== 200)
        .map((device) => ({
          device_id: device.device_id,
          name: device.name,
          type: device.type,
          error_message: device.error_message,
          last_attempt_at: device.last_attempt_at,
        })),
    ];
  }

  public getAllDevices = (req: Request, res: Response) => {
    try {
      const {
        sync_status_code,
        page = "1",
        limit = "10",
        sort_by = "last_sync_at",
        order = "desc",
      } = req.query;

      // Start with all devices
      let filteredDevices = [...this.devices];

      //---------------
      // Filtering logic
      //---------------

      if (sync_status_code) {
        const filterValue = sync_status_code.toString();

        // Handle negation (e.g., !200)
        if (filterValue.startsWith("!")) {
          const statusCode = parseInt(filterValue.substring(1));
          filteredDevices = filteredDevices.filter(
            (device) => device.sync_status_code !== statusCode
          );
        } else {
          const statusCode = parseInt(filterValue);
          filteredDevices = filteredDevices.filter(
            (device) => device.sync_status_code === statusCode
          );
        }
      }

      //---------------
      // Sorting logic
      //---------------
      if (
        sort_by &&
        (sort_by === "last_sync_at" || sort_by === "last_attempt_at")
      ) {
        filteredDevices.sort((a, b) => {
          const dateA = a[sort_by as keyof Device] as string | null;
          const dateB = b[sort_by as keyof Device] as string | null;

          // Handle null values
          if (dateA === null && dateB === null) return 0;
          if (dateA === null) return order === "asc" ? -1 : 1;
          if (dateB === null) return order === "asc" ? 1 : -1;

          return order === "asc"
            ? new Date(dateA).getTime() - new Date(dateB).getTime()
            : new Date(dateB).getTime() - new Date(dateA).getTime();
        });
      }

      //---------------
      // Pagination logic
      //---------------

      const MAX_LIMIT = 100;
      const limitNum = Math.min(
        MAX_LIMIT,
        Math.max(1, parseInt(limit as string) || 10)
      );

      // Total items
      const totalItems = filteredDevices.length;
      const totalPages = Math.ceil(totalItems / limitNum);

      // pageNum if it's too high
      const safePage = Math.min(
        Math.max(1, parseInt(page as string) || 1),
        totalPages || 1
      );

      // Calculate indexes
      const startIndex = (safePage - 1) * limitNum;
      const endIndex = Math.min(startIndex + limitNum, totalItems);

      // Slice paginated data
      const paginatedDevices = filteredDevices.slice(startIndex, endIndex);

      // Return response
      res.json({
        page: safePage,
        limit: limitNum,
        totalItems,
        totalPages,
        data: paginatedDevices,
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

      //! Simulate a successful sync 70% of the time, an error 20% of the time
      //! 😅 Let's see how can I handle at frontend
      if (Math.random() < 0.7) {
        // Create a copy instead of modifying the original
        const updatedDevice = {
          ...this.devices[deviceIndex],
          last_sync_at: now,
          sync_status_code: SyncStatusCode.Success,
          error_message: null,
          last_attempt_at: now,
        };

        return res.status(200).json({
          message: "Device synced successfully",
          device: (this.devices[deviceIndex] = updatedDevice),
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

        this.logs.push({
          device_id: this.devices[deviceIndex].device_id,
          name: this.devices[deviceIndex].name,
          type: this.devices[deviceIndex].type,
          error_message: randomError.message,
          last_attempt_at: now,
        });

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

  public getAllLogs = (req: Request, res: Response) => {
    try {
      const {
        page = "1",
        limit = "10",
        sort_by = "last_attempt_at",
        order = "desc",
      } = req.query;

      // Start with all logs
      let filteredLogs = [...this.logs];

      //---------------
      // Sorting logic
      //---------------
      if (sort_by && sort_by === "last_attempt_at") {
        filteredLogs.sort((a, b) => {
          const dateA = a[sort_by as keyof Logs] as string | null;
          const dateB = b[sort_by as keyof Logs] as string | null;

          // Handle null values
          if (dateA === null && dateB === null) return 0;
          if (dateA === null) return order === "asc" ? -1 : 1;
          if (dateB === null) return order === "asc" ? 1 : -1;

          return order === "asc"
            ? new Date(dateA).getTime() - new Date(dateB).getTime()
            : new Date(dateB).getTime() - new Date(dateA).getTime();
        });
      }

      //---------------
      // Pagination logic
      //---------------

      const MAX_LIMIT = 100;
      const limitNum = Math.min(
        MAX_LIMIT,
        Math.max(1, parseInt(limit as string) || 10)
      );

      // Total items
      const totalItems = filteredLogs.length;
      const totalPages = Math.ceil(totalItems / limitNum);

      // pageNum if it's too high
      const safePage = Math.min(
        Math.max(1, parseInt(page as string) || 1),
        totalPages || 1
      );

      // Calculate indexes
      const startIndex = (safePage - 1) * limitNum;
      const endIndex = Math.min(startIndex + limitNum, totalItems);

      // Slice paginated data
      const paginatedLogs = filteredLogs.slice(startIndex, endIndex);

      // Return response
      res.json({
        page: safePage,
        limit: limitNum,
        totalItems,
        totalPages,
        data: paginatedLogs,
      });
    } catch (error) {
      console.error("Error fetching logs:", error);
      return res
        .status(500)
        .json({ message: "Server error while fetching logs" });
    }
  };
}
