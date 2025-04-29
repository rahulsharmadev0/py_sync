import { AuthController } from "../../src/controllers/auth.controller";
import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { config } from "../../src/config";

// Mock dependencies
jest.mock("bcrypt");
jest.mock("jsonwebtoken");
jest.mock("../../src/utils/mock-data", () => ({
  mockData: {
    createUsers: jest.fn().mockResolvedValue([
      { id: 1, username: "testuser1", password: "hashed_password1" },
      { id: 2, username: "testuser2", password: "hashed_password2" },
    ]),
  },
}));

describe("AuthController", () => {
  let authController: AuthController;
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let responseJson: jest.Mock;
  let responseStatus: jest.Mock;

  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();

    // Mock response functions
    responseJson = jest.fn().mockReturnThis();
    responseStatus = jest.fn().mockReturnValue({ json: responseJson });

    mockRequest = {
      body: {},
    };

    mockResponse = {
      status: responseStatus,
      json: responseJson,
    };

    // Create controller instance
    authController = new AuthController();
  });

  describe("register", () => {
    beforeEach(() => {
      mockRequest.body = {
        username: "newuser",
        password: "password123",
      };

      // Mock bcrypt functions
      (bcrypt.genSalt as jest.Mock).mockResolvedValue("salt");
      (bcrypt.hash as jest.Mock).mockResolvedValue("hashed_password");

      // Mock jwt sign
      (jwt.sign as jest.Mock).mockReturnValue("mock_token");
    });

    it("should register a new user and return token", async () => {
      await authController.register(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(bcrypt.genSalt).toHaveBeenCalledWith(10);
      expect(bcrypt.hash).toHaveBeenCalledWith("password123", "salt");
      expect(jwt.sign).toHaveBeenCalled();
      expect(responseStatus).toHaveBeenCalledWith(201);
      expect(responseJson).toHaveBeenCalledWith({
        message: "User registered successfully.",
        token: "mock_token",
      });
    });

    it("should return 400 if username already exists", async () => {
      mockRequest.body.username = "testuser1"; // Using existing username

      await authController.register(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseStatus).toHaveBeenCalledWith(400);
      expect(responseJson).toHaveBeenCalledWith({
        message: "Username already exists",
      });
    });
  });

  describe("login", () => {
    beforeEach(() => {
      mockRequest.body = {
        username: "testuser1",
        password: "password123",
      };

      // Mock bcrypt compare
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      // Mock jwt sign
      (jwt.sign as jest.Mock).mockReturnValue("mock_token");
    });

    it("should login a user and return token when credentials are valid", async () => {
      await authController.login(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(bcrypt.compare).toHaveBeenCalledWith(
        "password123",
        "hashed_password1"
      );
      expect(jwt.sign).toHaveBeenCalled();
      expect(responseStatus).toHaveBeenCalledWith(200);
      expect(responseJson).toHaveBeenCalledWith({
        message: "Login successful.",
        token: "mock_token",
      });
    });

    it("should return 401 when username is not found", async () => {
      mockRequest.body.username = "nonexistentuser";

      await authController.login(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(responseStatus).toHaveBeenCalledWith(401);
      expect(responseJson).toHaveBeenCalledWith({
        message: "Invalid username or password.",
      });
    });

    it("should return 401 when password is incorrect", async () => {
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await authController.login(
        mockRequest as Request,
        mockResponse as Response
      );

      expect(bcrypt.compare).toHaveBeenCalled();
      expect(responseStatus).toHaveBeenCalledWith(401);
      expect(responseJson).toHaveBeenCalledWith({
        message: "Invalid username or password.",
      });
    });
  });
});
