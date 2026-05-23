// ===============================
// controllers/notificationController.js
// ===============================

const Notification = require("../models/Notification");

// ===============================
// GET MY NOTIFICATIONS (USER / VENDOR)
// ===============================
const getMyNotifications = async (req, res) => {
  try {
    const userId = req.user._id;
    const role = req.user.role;

    const notifications = await Notification.find({
      user: userId,
      receiverType: role,
    })
      .sort({ createdAt: -1 })
      .limit(50);

    const unreadCount = await Notification.countDocuments({
      user: userId,
      receiverType: role,
      isRead: false,
    });

    res.json({
      success: true,
      totalNotifications: notifications.length,
      unreadCount,
      notifications,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ===============================
// MARK AS READ (SECURE)
// ===============================
const markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found",
      });
    }

    notification.isRead = true;
    notification.readAt = new Date(); // 🔥 extra improvement
    await notification.save();

    res.json({
      success: true,
      message: "Notification marked as read",
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ===============================
// DELETE NOTIFICATION (SECURE)
// ===============================
const deleteNotification = async (req, res) => {
  try {
    const notification = await Notification.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found",
      });
    }

    await notification.deleteOne();

    res.json({
      success: true,
      message: "Notification deleted",
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ===============================
// ADMIN NOTIFICATIONS
// ===============================
const getAdminNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({
      receiverType: "admin",
    }).sort({ createdAt: -1 });

    const unreadCount = await Notification.countDocuments({
      receiverType: "admin",
      isRead: false,
    });

    res.json({
      success: true,
      unreadCount,
      notifications,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const clearAllNotifications = async (req, res) => {
  try {
    const userId = req.user._id;
    const role = req.user.role;

    const result = await Notification.deleteMany({
      user: userId,
      receiverType: role,
    });

    res.json({
      success: true,
      message: "All notifications cleared",
      deletedCount: result.deletedCount,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ===============================
module.exports = {
  getMyNotifications,
  markAsRead,
  clearAllNotifications,
  deleteNotification,
  getAdminNotifications,
};