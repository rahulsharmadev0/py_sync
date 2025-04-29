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

/*
First Things First:
- Deeply understand the current implementation of devices list.
- Understand routes, middleware and controllers & models ..etc.

- Thinking about What best and optimal way to implement additional requirements as per given below ?

- Start Coding.
- Write tests for all new code.
- Run all tests, See if all tests are passing.
- if not, debug and fix the issues.
- Write Separate documentation for new code

-------

Current implementation for devices list is like this:   
- GET: `{{base_url}}/devices [give me complete device list]
- Current no pagination implemented, so if we have 1000 devices, we will get all 1000 devices in one go.

What i want ?
- GET: `{{base_url}}/devices` - get all devices ✅
- GET: `{{base_url}}/devices?sync_status_code=!200 ` [get all devices with sync status code not equal to 200]
- GET: `{{base_url}}/devices?sync_status_code=200` [get all devices with sync status code equal to 200]

- Implement pagination for devices list.
- GET: `{{base_url}}/devices?page=1&limit=10` [get all devices with pagination, page 1, limit 10]

- Sorting on base of given query params.
- GET: `{{base_url}}/devices?sort_by=last_sync_at&order=desc` [get all devices with sorting on created_at in descending order]
- GET: `{{base_url}}/devices?sort_by=last_sync_at&order=asc` [get all devices with sorting on created_at in ascending order]
  Possibility for sort_by:
     sort_by = last_attempt_at, last_sync_at
     order = asc, desc (any one of them, default is desc)

*/
