class ApiConstants {

  static const baseUrl =
      "https://bitepay.onrender.com/api/auth";

  static const register =
      "$baseUrl/register";

  static const login =
      "$baseUrl/login";

  static const logout =
      "$baseUrl/logout";

  static const forgotPassword =
      "$baseUrl/forgot-password";

  static const sendOtp =
      "$baseUrl/send-otp";

  static const verifyOtp =
      "$baseUrl/verify-otp";

  static const resetPassword =
      "$baseUrl/reset-password";

  // =========================
  // VENDOR
  // =========================

  static const vendorProfile =
      "https://bitepay.onrender.com/api/vendor/profile";

  static const canteenStatus =
      "https://bitepay.onrender.com/api/vendor/canteen-status";

  static const updateCanteenInfo =
      "https://bitepay.onrender.com/api/vendor/canteen-info";

  // =========================
  // MENU
  // =========================

  static const addMenu =
      "https://bitepay.onrender.com/api/menu/add";

  static const getMyMenu =
      "https://bitepay.onrender.com/api/menu/my-menu";


  static const vendorDashboard =
    "https://bitepay.onrender.com/api/vendor-dashboard/dashboard";


  static const vendorOrders =
    "https://bitepay.onrender.com/api/orders/vendor-orders";

  static String acceptOrder(
    String orderId,
  ) =>
      "https://bitepay.onrender.com/api/orders/accept/$orderId";

  static String readyOrder(
    String orderId,
  ) =>
      "https://bitepay.onrender.com/api/orders/ready/$orderId";

  static const allVendorsWithMenu =
    "https://bitepay.onrender.com/api/vendor/vendors/all-details";


  static const createOrder = "https://bitepay.onrender.com/api/orders";

  static const String notifications =
    "https://bitepay.onrender.com/api/notifications";



      static String deleteNotification(String id) =>
      "https://bitepay.onrender.com/api/notifications/$id";

  static const clearAllNotifications =
      "https://bitepay.onrender.com/api/notifications/clear-all";

  static const wallet =
    "https://bitepay.onrender.com/api/wallet";


  static const String placeOrder = "https://bitepay.onrender.com/api/orders";


  static const addMoney =
    "https://bitepay.onrender.com/api/wallet/add";

static const String walletOrders =
    "https://bitepay.onrender.com/api/orders/wallet-orders";

    static const String getOrdersByUser =
    "https://bitepay.onrender.com/api/orders/user/";


    static const getUserProfile =
    "https://bitepay.onrender.com/api/user/me";




  static String updateMenuStock(
    String id,
  ) =>
      "https://bitepay.onrender.com/api/menu/stock/$id";

}