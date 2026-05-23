// ===============================
// routes/notificationRoutes.js
// ===============================

const express = require("express");
const router = express.Router();

const {
  getMyNotifications,
  markAsRead,
  deleteNotification,
  getAdminNotifications,
  clearAllNotifications,
} = require("../controllers/notificationController");

const { protect } = require("../middleware/authMiddleware");

// ===============================
// USER / VENDOR NOTIFICATIONS
// ===============================
router.get("/", protect, getMyNotifications);

// ===============================
// ADMIN NOTIFICATIONS
// ===============================
router.get("/admin", protect, getAdminNotifications);


router.delete("/clear-all", protect, clearAllNotifications);

// ===============================
// MARK AS READ
// ===============================
router.put("/read/:id", protect, markAsRead);

// ===============================
// DELETE NOTIFICATION
// ===============================
router.delete("/:id", protect, deleteNotification);

module.exports = router;