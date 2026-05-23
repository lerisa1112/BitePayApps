// ===============================
// models/Notification.js
// ===============================

const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    // ===============================
    // RECEIVER (USER / VENDOR / ADMIN)
    // ===============================
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    receiverType: {
      type: String,
      enum: ["user", "vendor", "admin"],
      required: true,
    },

    // ===============================
    // NOTIFICATION CONTENT
    // ===============================
    title: {
      type: String,
      required: true,
    },

    message: {
      type: String,
      required: true,
    },

    type: {
      type: String,
      enum: [
        "order",
        "payment",
        "admin",
        "general",
      ],
      default: "general",
    },

    // ===============================
    // STATUS
    // ===============================
    isRead: {
      type: Boolean,
      default: false,
    },

    readAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

// ===============================
// INDEXING (FAST QUERY)
// ===============================
notificationSchema.index({ user: 1, createdAt: -1 });

module.exports = mongoose.model("Notification", notificationSchema);