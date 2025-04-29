## ✅ TODO – Pi Sync API

1. [x] **Update `/devices` endpoint in backend to support:**

   - Filtering by `sync_status_code`
   - Pagination (`page`, `limit`)
   - Sorting (`sort_by`, `order`)

2. [x] **Ensure proper JWT authentication on all protected routes**

3. [x] **Sync logic:**

   - Simulate 80% success / 20% failure
   - Attach error messages like "Connection Timeout", "Server Not Reachable"

4. [x] **Error response consistency:**

   - Follow status code mapping (400, 404, 500)
   - Use structured response format for errors

5. [x] **Frontend tasks:**

   - Store and attach JWT to requests
   - Handle token expiry (auto-logout or refresh)
   - Display sync status with color codes
   - Show `last_sync_at`, `last_attempt_at`
   - Retry syncs from UI

6. [x] **Add mock login support with:**

   - `rahulsharmadev / rahulsharmadev123`
   - `admin / admin123`

7. [x] **Optional: Export API docs**
   - [x] As PDF or Markdown
   - [x] Or import to Postman/Swagger if needed
