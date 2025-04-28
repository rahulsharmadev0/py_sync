import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { config } from "../config";
import { mockData } from "../utils/mock-data";

export class AuthController {
  private users: any[] = [];

  constructor() {
    // Initialize users when the controller is created
    this.initializeUsers();
  }

  private async initializeUsers() {
    this.users = await mockData.createUsers();
  }

  public register = async (req: Request, res: Response) => {
    try {
      const { username, password } = req.body;

      // Check if username exists
      const existingUser = this.users.find(
        (user) => user.username === username
      );
      if (existingUser) {
        return res.status(400).json({ message: "Username already exists" });
      }

      // Hash password
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);

      // Create new user
      const newUser = {
        id: this.users.length + 1,
        username,
        password: hashedPassword,
      };

      this.users.push(newUser);

      // Use a different approach to sign the JWT token
      const payload = { userId: newUser.id, username: newUser.username };
      const secretKey = String(config.jwtSecret);
      const expiresIn = String(config.jwtExpiresIn);

      // Sign with explicit types
      const token = jwt.sign(payload, secretKey, {
        expiresIn,
      } as jwt.SignOptions);

      return res.status(201).json({
        message: "User registered successfully.",
        token,
      });
    } catch (error) {
      console.error("Registration error:", error);
      return res
        .status(500)
        .json({ message: "Server error during registration" });
    }
  };

  public login = async (req: Request, res: Response) => {
    try {
      const { username, password } = req.body;

      // Find user
      const user = this.users.find((user) => user.username === username);
      if (!user) {
        return res
          .status(401)
          .json({ message: "Invalid username or password." });
      }

      // Verify password
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res
          .status(401)
          .json({ message: "Invalid username or password." });
      }

      // Use a different approach to sign the JWT token
      const payload = { userId: user.id, username: user.username };
      const secretKey = String(config.jwtSecret);
      const expiresIn = String(config.jwtExpiresIn);

      // Sign with explicit types
      const token = jwt.sign(payload, secretKey, {
        expiresIn,
      } as jwt.SignOptions);

      return res.status(200).json({
        message: "Login successful.",
        token,
      });
    } catch (error) {
      console.error("Login error:", error);
      return res.status(500).json({ message: "Server error during login" });
    }
  };
}
