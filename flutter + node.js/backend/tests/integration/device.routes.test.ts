import request from "supertest";
import jwt from "jsonwebtoken";
import { Express } from "express";
import express from "express";
import { SyncStatusCode } from "../../src/models/models";
import { deviceRoutes } from "../../src/routes/device.routes";
import { generateTestToken } from "../test-utils";

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
      createUsers: jest
        .fn()
        .mockResolvedValue([
          { id: 1, username: "testuser", password: "hashed_password" },
        ]),
      devices: mockDevices,
    },
  };
});

// Mock Math.random to control sync simulation
const mockMath = Object.create(global.Math);
mockMath.random = jest.fn().mockReturnValue(0.7); // Default to successful sync (< 0.8)
global.Math = mockMath;

// Mock JWT verification
jest.mock("jsonwebtoken");
(jwt.verify as jest.Mock).mockReturnValue({ userId: 1, username: "testuser" });

// Create a test app instance for better isolation
let app: Express;

describe("Device API", () => {
  const validToken = "valid_token";

  beforeAll(() => {
    // Create a fresh app instance for testing
    app = express();
    app.use(express.json());

    // Mock middleware to apply the auth middleware effect
    app.use("/pisync/devices", (req, res, next) => {
      // Skip auth for tests with Authorization header
      if (req.headers.authorization) {
        return next();
      }
      // Simulate auth middleware rejection
      return res.status(401).json({ message: "No auth token provided" });
    });

    app.use("/pisync/devices", deviceRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();
    mockMath.random.mockReturnValue(0.7); // Reset to success case
  });

  describe("GET /pisync/devices", () => {
    it("should return 401 without authentication", async () => {
      const response = await request(app).get("/pisync/devices");

      expect(response.status).toBe(401);
      expect(response.body).toEqual({ message: "No auth token provided" });
    });

    it("should return 401 with invalid token", async () => {
      (jwt.verify as jest.Mock).mockImplementationOnce(() => {
        throw new Error("Invalid token");
      });

      const response = await request(app)
        .get("/pisync/devices")
        .set("Authorization", "Bearer invalid_token");

      expect(response.status).toBe(401);
      expect(response.body).toEqual({ message: "Invalid auth token" });
    });

    it("should return devices with valid authentication", async () => {
      const response = await request(app)
        .get("/pisync/devices")
        .set("Authorization", `Bearer ${validToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("data");
      expect(response.body.data.length).toBe(3);
      expect(response.body).toEqual(
        expect.objectContaining({
          page: 1,
          limit: 10,
          totalItems: 3,
          totalPages: 1,
        })
      );
    });

    it("should filter devices by sync_status_code", async () => {
      const response = await request(app)
        .get("/pisync/devices?sync_status_code=200")
        .set("Authorization", `Bearer ${validToken}`);

      expect(response.status).toBe(200);
      expect(response.body.data.length).toBe(2);
      expect(response.body.data[0].sync_status_code).toBe(200);
      expect(response.body.data[1].sync_status_code).toBe(200);
    });

    it("should filter devices by negated sync_status_code", async () => {
      const response = await request(app)
        .get("/pisync/devices?sync_status_code=!200")
        .set("Authorization", `Bearer ${validToken}`);

      expect(response.status).toBe(200);
      expect(response.body.data.length).toBe(1);
      expect(response.body.data[0].sync_status_code).toBe(400);
    });

    it("should sort devices by specified field and order", async () => {
      const response = await request(app)
        .get("/pisync/devices?sort_by=last_attempt_at&order=desc")
        .set("Authorization", `Bearer ${validToken}`);

      expect(response.status).toBe(200);
      expect(response.body.data[0].device_id).toBe("test-device-2"); // Most recent attempt
    });

    it("should apply pagination correctly", async () => {
      const response = await request(app)
        .get("/pisync/devices?page=1&limit=2")
        .set("Authorization", `Bearer ${validToken}`);

      expect(response.status).toBe(200);
      expect(response.body.page).toBe(1);
      expect(response.body.limit).toBe(2);
      expect(response.body.totalItems).toBe(3);
      expect(response.body.totalPages).toBe(2);
      expect(response.body.data.length).toBe(2);
    });
  });

  describe("GET /pisync/devices/:id", () => {
    it("should return 401 without authentication", async () => {
      const response = await request(app).get("/pisync/devices/test-device-1");

      expect(response.status).toBe(401);
    });

    it("should sync a device successfully", async () => {
      mockMath.random.mockReturnValue(0.7); // Success case (< 0.8)

      const response = await request(app)
        .get("/pisync/devices/test-device-1")
        .set("Authorization", `Bearer ${validToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toEqual(
        expect.objectContaining({
          message: "Device synced successfully",
          device: expect.objectContaining({
            device_id: "test-device-1",
            sync_status_code: SyncStatusCode.Success,
          }),
        })
      );
    });

    it("should return error when sync fails", async () => {
      mockMath.random.mockReturnValue(0.9); // Failure case (>= 0.8)

      const response = await request(app)
        .get("/pisync/devices/test-device-1")
        .set("Authorization", `Bearer ${validToken}`);

      // Status code will be one of the error codes
      expect([400, 404, 500]).toContain(response.status);
      expect(response.body.message).toMatch(/^Sync failed:/);
    });

    it("should return 404 when device is not found", async () => {
      const response = await request(app)
        .get("/pisync/devices/non-existent-device")
        .set("Authorization", `Bearer ${validToken}`);

      expect(response.status).toBe(404);
      expect(response.body).toEqual({
        message: "Device with ID non-existent-device not found",
      });
    });
  });
});
