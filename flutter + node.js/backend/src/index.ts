import express from "express";
import cors from "cors";
import { config } from "./config";
import { authRoutes } from "./routes/auth.routes";
import { deviceRoutes } from "./routes/device.routes";

// Initialize Express app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// API Routes
app.use("/pisync/auth", authRoutes);
app.use("/pisync/devices", deviceRoutes);

// Root route
app.get("/", (req, res) => {
  res.json({
    message: "Device Sync Management API",
    version: "1.0.1",
    developer: "@rahulsharmadev (Rahul Sharma)",
    endpoints: {
      auth: "/pisync/auth",
      devices: "/pisync/devices",
    },
  });
});

// Handle 404 routes
app.use("*", (req, res) => {
  res.status(404).json({ message: "Route not found" });
});

// Start server only if not in test environment
if (process.env.NODE_ENV !== "test") {
  const PORT = config.port;
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

export default app;
