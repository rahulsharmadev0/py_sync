import { DeviceController } from "../../src/controllers/device.controller";
import { Request, Response } from "express";
import { SyncStatusCode } from "../../src/models/models";

// Mock the mock-data
jest.mock("../../src/utils/mock-data", () => {
  const mockDevices = [
    {
      device_id: "test-device-1",
      name: "Test Device 1",
      type: "Test",
      last_sync_at: "2025-04-20T12:00:00.000Z",
      sync_status_code: 200,
      error_message: null,
      last_attempt_at: "2025-04-20T12:00:00.000Z",
    },
    {
      device_id: "test-device-2",
      name: "Test Device 2",
      type: "Test",
      last_sync_at: "2025-04-18T10:00:00.000Z",
      sync_status_code: 400,
      error_message: "Test Error",
      last_attempt_at: "2025-04-25T10:00:00.000Z",
    },
    {
      device_id: "test-device-3",
      name: "Test Device 3",
      type: "Test",
      last_sync_at: "2025-04-15T08:00:00.000Z",
      sync_status_code: 200,
      error_message: null,
      last_attempt_at: "2025-04-15T08:00:00.000Z",
    },
  ];

  return {
    mockData: {
      devices: mockDevices,
    },
  };
});

// Mock Math.random to control sync simulation
const mockMath = Object.create(global.Math);
mockMath.random = jest.fn();
global.Math = mockMath;

describe("DeviceController", () => {
  let deviceController: DeviceController;
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let responseJson: jest.Mock;
  let responseStatus: jest.Mock;

  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();

    // Mock response functions
    responseJson = jest.fn();
    responseStatus = jest.fn().mockReturnValue({ json: responseJson });

    mockRequest = {
      query: {},
      params: {},
    };

    mockResponse = {
      status: responseStatus,
      json: responseJson,
    };

    // Create controller instance
    deviceController = new DeviceController();
  });

  describe("getAllDevices", () => {
    it("should return all devices with default pagination", () => {
      deviceController.getAllDevices(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseJson).toHaveBeenCalledWith(
        expect.objectContaining({
          page: 1,
          limit: 10,
          totalItems: 3,
          totalPages: 1,
          data: expect.arrayContaining([
            expect.objectContaining({ device_id: "test-device-1" }),
            expect.objectContaining({ device_id: "test-device-2" }),
            expect.objectContaining({ device_id: "test-device-3" }),
          ]),
        })
      );
    });

    it("should filter devices by sync_status_code", () => {
      mockRequest.query = { sync_status_code: "200" };

      deviceController.getAllDevices(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseJson).toHaveBeenCalledWith(
        expect.objectContaining({
          totalItems: 2,
          data: expect.arrayContaining([
            expect.objectContaining({ device_id: "test-device-1" }),
            expect.objectContaining({ device_id: "test-device-3" }),
          ]),
        })
      );
    });

    it("should filter devices by negated sync_status_code", () => {
      mockRequest.query = { sync_status_code: "!200" };

      deviceController.getAllDevices(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseJson).toHaveBeenCalledWith(
        expect.objectContaining({
          totalItems: 1,
          data: expect.arrayContaining([
            expect.objectContaining({ device_id: "test-device-2" }),
          ]),
        })
      );
    });

    it("should sort devices by last_sync_at in descending order by default", () => {
      deviceController.getAllDevices(
        mockRequest as Request,
        mockResponse as Response
      );

      const result = responseJson.mock.calls[0][0];
      expect(result.data[0].device_id).toBe("test-device-1"); // Most recent first
      expect(result.data[2].device_id).toBe("test-device-3"); // Oldest last
    });

    it("should sort devices by last_sync_at in ascending order when specified", () => {
      mockRequest.query = { sort_by: "last_sync_at", order: "asc" };

      deviceController.getAllDevices(
        mockRequest as Request,
        mockResponse as Response
      );

      const result = responseJson.mock.calls[0][0];
      expect(result.data[0].device_id).toBe("test-device-3"); // Oldest first
      expect(result.data[2].device_id).toBe("test-device-1"); // Most recent last
    });

    it("should sort devices by last_attempt_at when specified", () => {
      mockRequest.query = { sort_by: "last_attempt_at", order: "desc" };

      deviceController.getAllDevices(
        mockRequest as Request,
        mockResponse as Response
      );

      const result = responseJson.mock.calls[0][0];
      expect(result.data[0].device_id).toBe("test-device-2"); // Most recent attempt
    });

    it("should apply pagination correctly", () => {
      mockRequest.query = { page: "1", limit: "2" };

      deviceController.getAllDevices(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseJson).toHaveBeenCalledWith(
        expect.objectContaining({
          page: 1,
          limit: 2,
          totalItems: 3,
          totalPages: 2,
          data: expect.arrayContaining([
            expect.objectContaining({ device_id: "test-device-1" }),
            expect.objectContaining({ device_id: "test-device-2" }),
          ]),
        })
      );
    });

    it("should handle errors gracefully", () => {
      // Force an error by making the device list a non-iterable
      Object.defineProperty(deviceController, "devices", {
        get: () => {
          throw new Error("Test error");
        },
      });

      deviceController.getAllDevices(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseStatus).toHaveBeenCalledWith(500);
      expect(responseJson).toHaveBeenCalledWith({
        message: "Server error while fetching devices",
      });
    });
  });

  describe("syncDevice", () => {
    it("should successfully sync a device when random < 0.8", () => {
      mockRequest.params = { id: "test-device-1" };
      mockMath.random.mockReturnValue(0.7); // Success case

      deviceController.syncDevice(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseStatus).toHaveBeenCalledWith(200);
      expect(responseJson).toHaveBeenCalledWith(
        expect.objectContaining({
          message: "Device synced successfully",
          device: expect.objectContaining({
            device_id: "test-device-1",
            sync_status_code: SyncStatusCode.Success,
            error_message: null,
          }),
        })
      );
    });

    it("should return an error when sync fails (random >= 0.8)", () => {
      mockRequest.params = { id: "test-device-1" };
      mockMath.random.mockReturnValue(0.9); // Failure case

      deviceController.syncDevice(
        mockRequest as Request,
        mockResponse as Response
      );

      // One of the error types will be used, we just check that it's an error
      expect(responseStatus).toHaveBeenCalledWith(expect.any(Number));
      expect(responseJson).toHaveBeenCalledWith(
        expect.objectContaining({
          message: expect.stringContaining("Sync failed:"),
          device: expect.objectContaining({
            device_id: "test-device-1",
          }),
        })
      );
    });

    it("should return 404 when device is not found", () => {
      mockRequest.params = { id: "non-existent-device" };

      deviceController.syncDevice(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseStatus).toHaveBeenCalledWith(404);
      expect(responseJson).toHaveBeenCalledWith({
        message: "Device with ID non-existent-device not found",
      });
    });

    it("should handle errors gracefully", () => {
      mockRequest.params = { id: "test-device-1" };

      // Force an error
      jest.spyOn(deviceController, "syncDevice").mockImplementationOnce(() => {
        throw new Error("Test error");
      });

      deviceController.syncDevice(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseStatus).toHaveBeenCalledWith(500);
      expect(responseJson).toHaveBeenCalledWith({
        message: "Server error while syncing device",
      });
    });
  });
});
