import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { config } from "../config";

interface TokenPayload {
  userId: number;
  username: string;
}

declare global {
  namespace Express {
    interface Request {
      user?: TokenPayload;
    }
  }
}

export const authMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: "No auth token provided" });
  }

  // Get the token part from "Bearer {token}"
  const token = authHeader.split(" ")[1];

  try {
    // Verify token with explicit types
    const secretKey = String(config.jwtSecret);
    const decoded = jwt.verify(token, secretKey) as TokenPayload;
    req.user = decoded;
    return next();
  } catch (error) {
    return res.status(401).json({ message: "Invalid auth token" });
  }
};
