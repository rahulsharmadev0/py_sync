import { Router } from "express";
import { DeviceController } from "../controllers/device.controller";
import { authMiddleware } from "../middlewares/auth.middleware";

const router = Router();
const deviceController = new DeviceController();

// Apply auth middleware to all device routes
router.use(authMiddleware);

// Device routes
router.get("/", deviceController.getAllDevices);
router.get("/:id", deviceController.syncDevice);

export const deviceRoutes = router;
