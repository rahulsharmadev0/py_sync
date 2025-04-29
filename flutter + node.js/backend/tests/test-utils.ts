import { Express } from "express";
import request from "supertest";
import jwt, { Secret } from "jsonwebtoken";
import { config } from "../src/config";

/**
 * Helper function to generate valid JWT token for testing
 */
export const generateTestToken = (
  userId: number = 1,
  username: string = "testuser"
) => {
  return jwt.sign({ userId, username }, config.jwtSecret as Secret, {
    expiresIn: config.jwtExpiresIn,
  });
};

/**
 * Helper function to make authenticated requests
 */
export const authRequest = (
  app: Express,
  token: string = generateTestToken()
) => {
  return {
    get: (url: string) =>
      request(app).get(url).set("Authorization", `Bearer ${token}`),
    post: (url: string, body?: any) =>
      request(app).post(url).set("Authorization", `Bearer ${token}`).send(body),
    put: (url: string, body?: any) =>
      request(app).put(url).set("Authorization", `Bearer ${token}`).send(body),
    delete: (url: string) =>
      request(app).delete(url).set("Authorization", `Bearer ${token}`),
  };
};
