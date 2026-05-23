const Order = require("../models/Order");

const Wallet = require("../models/Wallet");

const User = require("../models/User");

const Notification =
  require("../models/Notification");

const sendPushNotification =
  require("../utils/sendPushNotification");

const sendOrderPlacedMail =
  require("../utils/sendOrderPlacedMail");

const sendOrderAcceptedMail =
  require("../utils/sendOrderAcceptedMail");

const sendOrderReadyMail =
  require("../utils/sendOrderReadyMail");

const sendOrderCompletedMail =
  require("../utils/sendOrderCompletedMail");

const generateQR =
  require("../utils/qr");


// ======================================
// PLACE ORDER
// ======================================
const placeOrder = async (req, res) => {
  try {
    const io = req.app.get("io");
    const userSocketMap = req.app.get("userSocketMap");

    const {
      vendor,
      items,
      totalAmount,
      pickupTime,
      pickupSlotId,
    } = req.body;

    console.log("🔥 PLACE ORDER STARTED");

    // ======================================
    // WALLET CHECK
    // ======================================
    const wallet = await Wallet.findOneAndUpdate(
      {
        user: req.user._id,
        balance: { $gte: totalAmount },
      },
      {
        $inc: { balance: -totalAmount },
        $push: {
          transactions: {
            type: "debit",
            amount: totalAmount,
            note: "Food Order Payment",
            canteenName: vendor,
            createdAt: new Date(),
          },
        },
      },
      { new: true }
    );

    if (!wallet) {
      console.log("❌ WALLET INSUFFICIENT");
      return res.status(400).json({
        success: false,
        message: "Insufficient balance",
      });
    }

    // ======================================
    // CREATE ORDER
    // ======================================
    let order = await Order.create({
      orderId: "ORD-" + Date.now(),
      user: req.user._id,
      vendor,
      items,
      totalAmount,
      pickupTime,
      pickupSlot: pickupSlotId,
      paymentMethod: "Wallet",
      orderStatus: "Pending",
    });

    console.log("✅ ORDER CREATED:", order.orderId);

    // ======================================
    // POPULATE DATA
    // ======================================
    order = await Order.findById(order._id)
      .populate("user", "name email phone")
      .populate("vendor", "name canteenName email fcmToken");

    console.log("👤 USER:", order.user.name);
    console.log("🏪 VENDOR:", order.vendor.name);

    // ======================================
    // QR GENERATE
    // ======================================
    const qr = await generateQR({
      orderId: order._id,
      user: req.user._id,
      pickupTime,
    });

    order.qrCode = qr;
    await order.save();

    // ======================================
    // FOOD MESSAGE
    // ======================================
    const userName = order.user.name;

    const foodNames = order.items
      .map((i) => i.foodName)
      .join(", ");

    const time = new Intl.DateTimeFormat("en-IN", {
      dateStyle: "medium",
      timeStyle: "short",
    }).format(new Date());

    const message = `${userName} placed a new order: ${foodNames}\n🕒 ${time}`;

    console.log("📩 NOTIFICATION MESSAGE:", message);

    // ======================================
    // SAVE NOTIFICATION (IMPORTANT FIX)
    // ======================================
    const notification = await Notification.create({
      user: order.vendor._id,
      title: "New Order",
      message: message,
      receiverType: "vendor",   //
      type: "order",
    });

    console.log("🔔 NOTIFICATION SAVED:", notification._id);

    // ======================================
    // PUSH NOTIFICATION
    // ======================================
    if (order.vendor?.fcmToken) {
      await sendPushNotification({
        token: order.vendor.fcmToken,
        title: "New Order ",
        body: message,
      });

      console.log("📲 PUSH SENT");
    } else {
      console.log("❌ NO FCM TOKEN");
    }

    // ======================================
    // EMAIL
    // ======================================
    await sendOrderPlacedMail(
      order.vendor.email,
      order.vendor.name,
      order.orderId
    );

    console.log("📧 EMAIL SENT");

    // ======================================
    // SOCKET EVENT
    // ======================================
    const vendorSocket = userSocketMap.get(vendor?.toString());

    if (vendorSocket && io) {
      io.to(vendorSocket).emit("new_order", order);
      console.log("⚡ SOCKET SENT");
    }

    // ======================================
    // RESPONSE
    // ======================================
    res.json({
      success: true,
      message: "Order placed successfully",
      order,
      qrCode: qr,
    });

  } catch (error) {
    console.log("❌ ERROR:", error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// ======================================
// USER ORDERS
// ======================================
const getMyOrders = async (
  req,
  res
) => {

  try {

    const orders =
      await Order.find({

        user:
            req.user._id,

      })

      .populate(
        "vendor",
        "name canteenName"
      )

      .sort({
        createdAt: -1,
      });

    res.json({

      success: true,

      orders,

    });

  } catch (error) {

    res.status(500).json({

      success: false,

      message:
          error.message,

    });

  }

};


// ======================================
// VENDOR ORDERS
// ======================================
const getVendorOrders =
  async (
    req,
    res
  ) => {

    try {

      const orders =
        await Order.find({

          vendor:
              req.user._id,

        })

        .populate({

          path: "user",

          select:
              "name email phone",

        })

        .populate({

          path: "vendor",

          select:
              "name canteenName",

        })

        .sort({
          createdAt: -1,
        });

      res.json({

        success: true,

        orders,

      });

    } catch (error) {

      res.status(500).json({

        success: false,

        message:
            error.message,

      });

    }

  };


// ======================================
// ACCEPT ORDER
// ======================================
const acceptOrder = async (req, res) => {
  try {
    const io = req.app.get("io");
    const userSocketMap = req.app.get("userSocketMap");

    // ======================================
    // FIND ORDER
    // ======================================
    const order = await Order.findById(req.params.id)
      .populate("user", "name email fcmToken");

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    // ======================================
    // UPDATE STATUS
    // ======================================
    order.orderStatus = "Preparing";
    await order.save();

    // ======================================
    // USER + FOOD DETAILS
    // ======================================
    const userName = order.user.name;

    const foodNames = order.items
      .map((i) => i.foodName)
      .join(", ");

    const message = `Hi ${userName}, your order (${foodNames}) has been accepted and is being prepared 🍔`;

    // ======================================
    // SAVE NOTIFICATION
    // ======================================
    await Notification.create({
      user: order.user._id,
      title: "Order Accepted ",
      message,
      type: "order",
      receiverType: "user",
    });

    // ======================================
    // PUSH NOTIFICATION
    // ======================================
    if (order.user?.fcmToken) {
      await sendPushNotification({
        token: order.user.fcmToken,
        title: "Order Accepted ",
        body: message,
      });
    }

    // ======================================
    // EMAIL
    // ======================================
    await sendOrderAcceptedMail(
      order.user.email,
      order.user.name,
      order.orderId
    );

    // ======================================
    // SOCKET EVENT
    // ======================================
    const userSocket = userSocketMap.get(
      order.user._id?.toString()
    );

    if (userSocket && io) {
      io.to(userSocket).emit("order_accepted", {
        order,
        message,
      });
    }

    // ======================================
    // RESPONSE
    // ======================================
    res.json({
      success: true,
      message: "Order accepted successfully",
      order,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ======================================
// ORDER READY
// ======================================
const markOrderReady = async (req, res) => {
  try {
    const io = req.app.get("io");
    const userSocketMap = req.app.get("userSocketMap");

    // ======================================
    // FIND ORDER
    // ======================================
    const order = await Order.findById(req.params.id)
      .populate("user", "name email fcmToken")
      .populate("vendor", "name canteenName");

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    // ======================================
    // UPDATE STATUS
    // ======================================
    order.orderStatus = "Ready";
    await order.save();

    // ======================================
    // USER + FOOD DETAILS
    // ======================================
    const userName = order.user.name;

    const foodNames = order.items
      .map((i) => i.foodName)
      .join(", ");

    const message = `Hi ${userName}, your order (${foodNames}) is ready for pickup 🍕`;

    // ======================================
    // SAVE NOTIFICATION (USER)
    // ======================================
    await Notification.create({
      user: order.user._id,
      title: "Order Ready ",
      message,
      type: "order",
      receiverType: "user",
    });

    // ======================================
    // PUSH NOTIFICATION
    // ======================================
    if (order.user?.fcmToken) {
      await sendPushNotification({
        token: order.user.fcmToken,
        title: "Order Ready ",
        body: message,
      });
    }

    // ======================================
    // EMAIL
    // ======================================
    await sendOrderReadyMail(
      order.user.email,
      order.user.name,
      order.orderId
    );

    // ======================================
    // SOCKET EVENT
    // ======================================
    const userSocket = userSocketMap.get(
      order.user._id?.toString()
    );

    if (userSocket && io) {
      io.to(userSocket).emit("order_ready", {
        order,
        message,
      });
    }

    // ======================================
    // RESPONSE
    // ======================================
    res.json({
      success: true,
      message: "Order marked as ready",
      order,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// ======================================
// COMPLETE ORDER
// ======================================
const completeOrder =
  async (
    req,
    res
  ) => {

    try {

      const order =
        await Order.findById(
          req.params.id
        );

      if (!order) {

        return res.status(404).json({

          success: false,

          message:
              "Order not found",

        });

      }

      order.orderStatus =
        "Completed";

      await order.save();

      const user =
        await User.findById(
          order.user
        );

      // ======================================
      // SAVE NOTIFICATION
      // ======================================

      await Notification.create({

        user:
            user._id,

        title:
            "Order Completed 🎉",

        message:
            `Order ${order.orderId} completed`,

        type:
            "order",

        role:
            "user",

      });

      // ======================================
      // PUSH NOTIFICATION
      // ======================================

      if (
        user?.fcmToken
      ) {

        await sendPushNotification({

          token:
              user.fcmToken,

          title:
              "Order Completed 🎉",

          body:
              "Enjoy your meal",

        });

      }

      // ======================================
      // EMAIL
      // ======================================

      await sendOrderCompletedMail(

        user.email,

        user.name,

        order.orderId

      );

      res.json({

        success: true,

        message:
            "Order completed successfully",

        order,

      });

    } catch (error) {

      res.status(500).json({

        success: false,

        message:
            error.message,

      });

    }

  };


// ======================================
// GET USER ORDERS
// ======================================
const getOrdersByUser =
  async (
    req,
    res
  ) => {

    try {

      const {
        userId,
      } = req.params;

      const orders =
        await Order.find({

          user: userId,

        })

        .populate(
          "vendor",
          "name canteenName"
        )

        .populate(
          "user",
          "name email phone"
        )

        .sort({
          createdAt: -1,
        });

      res.json({

        success: true,

        total:
            orders.length,

        orders,

      });

    } catch (error) {

      res.status(500).json({

        success: false,

        message:
            error.message,

      });

    }

  };


// ======================================
// WALLET ORDERS
// ======================================
const getWalletOrders =
  async (
    req,
    res
  ) => {

    try {

      const orders =
        await Order.find({

          user:
              req.user._id,

          paymentMethod:
              "Wallet",

        })

        .populate(
          "vendor",
          "name canteenName"
        )

        .sort({
          createdAt: -1,
        });

      res.json({

        success: true,

        total:
            orders.length,

        orders,

      });

    } catch (error) {

      res.status(500).json({

        success: false,

        message:
            error.message,

      });

    }

  };


// ======================================
// EXPORTS
// ======================================
module.exports = {

  placeOrder,

  getMyOrders,

  getVendorOrders,

  acceptOrder,

  markOrderReady,

  completeOrder,

  getOrdersByUser,

  getWalletOrders,

};