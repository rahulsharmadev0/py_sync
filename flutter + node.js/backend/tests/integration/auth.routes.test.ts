import request from "supertest";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import { Express } from "express";
import express from "express";
import { AuthController } from "../../src/controllers/auth.controller";
import { authRoutes } from "../../src/routes/auth.routes";

// Mock dependencies
jest.mock("bcrypt");
jest.mock("jsonwebtoken");
jest.mock("../../src/utils/mock-data", () => ({
  mockData: {
    createUsers: jest
      .fn()
      .mockResolvedValue([
        { id: 1, username: "testuser", password: "hashed_password" },
      ]),
    devices: [],
  },
}));

// Create a test app instance for better isolation
let app: Express;

describe("Auth API", () => {
  beforeAll(() => {
    // Create a fresh app instance for testing
    app = express();
    app.use(express.json());
    app.use("/pisync/auth", authRoutes);
  });

  beforeEach(() => {
    jest.clearAllMocks();

    // Mock JWT sign
    (jwt.sign as jest.Mock).mockReturnValue("test_token");

    // Mock bcrypt functions
    (bcrypt.genSalt as jest.Mock).mockResolvedValue("salt");
    (bcrypt.hash as jest.Mock).mockResolvedValue("hashed_password");
    (bcrypt.compare as jest.Mock).mockResolvedValue(true);
  });

  describe("POST /pisync/auth/register", () => {
    it("should register a new user", async () => {
      const response = await request(app).post("/pisync/auth/register").send({
        username: "newuser",
        password: "password123",
      });

      expect(response.status).toBe(201);
      expect(response.body).toEqual({
        message: "User registered successfully.",
        token: "test_token",
      });
    });

    it("should return 400 if username already exists", async () => {
      const response = await request(app).post("/pisync/auth/register").send({
        username: "testuser", // Existing username
        password: "password123",
      });

      expect(response.status).toBe(400);
      expect(response.body).toEqual({
        message: "Username already exists",
      });
    });

    it("should return 500 on server error", async () => {
      // We need to mock both getUsers and bcrypt to ensure our test captures the right error case

      // First, ensure we're using a new username to pass the username check
      // Then make jwt.sign throw an error to simulate a server error after username validation
      (jwt.sign as jest.Mock).mockImplementationOnce(() => {
        throw new Error("Test error");
      });

      const response = await request(app).post("/pisync/auth/register").send({
        username: "erroruser", // New username to pass the duplicate check
        password: "password123",
      });

      expect(response.status).toBe(500);
      expect(response.body).toEqual({
        message: "Server error during registration",
      });
    });
  });

  describe("POST /pisync/auth/login", () => {
    it("should login successfully with correct credentials", async () => {
      const response = await request(app).post("/pisync/auth/login").send({
        username: "testuser",
        password: "password123",
      });

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        message: "Login successful.",
        token: "test_token",
      });
    });

    it("should return 401 with incorrect username", async () => {
      const response = await request(app).post("/pisync/auth/login").send({
        username: "wronguser",
        password: "password123",
      });

      expect(response.status).toBe(401);
      expect(response.body).toEqual({
        message: "Invalid username or password.",
      });
    });

    it("should return 401 with incorrect password", async () => {
      (bcrypt.compare as jest.Mock).mockResolvedValueOnce(false);

      const response = await request(app).post("/pisync/auth/login").send({
        username: "testuser",
        password: "wrongpassword",
      });

      expect(response.status).toBe(401);
      expect(response.body).toEqual({
        message: "Invalid username or password.",
      });
    });

    it("should return 500 on server error", async () => {
      // Force an error
      (bcrypt.compare as jest.Mock).mockImplementationOnce(() => {
        throw new Error("Test error");
      });

      const response = await request(app).post("/pisync/auth/login").send({
        username: "testuser",
        password: "password123",
      });

      expect(response.status).toBe(500);
      expect(response.body).toEqual({
        message: "Server error during login",
      });
    });
  });
});
