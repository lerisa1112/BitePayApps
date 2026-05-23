import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../../model/vendormodel.dart';

class AuthService {

  // =========================
  // REGISTER
  // =========================

  // =========================
// REGISTER
// =========================

static Future<Map<String, dynamic>> register(
    Map data) async {

  final res = await http.post(

    Uri.parse(ApiConstants.register),

    headers: {
      "Content-Type": "application/json",
    },

    body: jsonEncode(data),
  );

  final response =
      jsonDecode(res.body);

  if (response["token"] != null) {

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      "token",
      response["token"],
    );

    if (response["user"] != null) {

      await prefs.setString(
        "role",
        response["user"]["role"] ?? "",
      );

      await prefs.setString(
        "userId",
        response["user"]["_id"] ?? "",
      );
    }
  }

  return response;
}

// =========================
// LOGIN
// =========================

static Future<Map<String, dynamic>> login(
    Map data) async {

  final res = await http.post(

    Uri.parse(ApiConstants.login),

    headers: {
      "Content-Type": "application/json",
    },

    body: jsonEncode(data),
  );

  final response =
      jsonDecode(res.body);

  if (response["token"] != null) {

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      "token",
      response["token"],
    );

    if (response["user"] != null) {

      await prefs.setString(
        "role",
        response["user"]["role"] ?? "",
      );

      await prefs.setString(
        "userId",
        response["user"]["_id"] ?? "",
      );
    }
  }

  return response;
}


  // =========================
  // LOGOUT
  // =========================
static Future<Map<String, dynamic>> logout() async {

  try {

    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString("token");

    print("TOKEN => $token");

    final response = await http.post(

      Uri.parse(
        ApiConstants.logout,
      ),

      headers: {

        "Content-Type": "application/json",

        "Authorization":
            "Bearer $token",

      },

    );

    print(
      "LOGOUT STATUS => ${response.statusCode}",
    );

    print(
      "LOGOUT BODY => ${response.body}",
    );

    // ✅ SUCCESS CHECK
    if (response.statusCode == 200) {

      // REMOVE TOKEN & USER DATA
      await prefs.remove("token");
      await prefs.remove("role");
      await prefs.remove("userId");

      print("TOKEN REMOVED SUCCESS");

      return jsonDecode(response.body);



    } else {

      return {

        "success": false,

        "message": "Logout failed",

      };

    }

  } catch (e) {

    print(
      "LOGOUT ERROR => $e",
    );

    return {

      "success": false,

      "message": e.toString(),

    };

  }

}


// =========================
// UPDATE CANTEEN INFO
// =========================

static Future<Map<String, dynamic>>
    updateCanteenInfo({

  required String canteenName,
  required String managerName,

}) async {

  final token = await getToken();

  final res = await http.put(

    Uri.parse(
      ApiConstants.updateCanteenInfo,
    ),

    headers: {

      "Content-Type":
          "application/json",

      "Authorization":
          "Bearer $token",

    },

    body: jsonEncode({

      "canteenName":
          canteenName,

      "managerName":
          managerName,

    }),

  );

  return jsonDecode(res.body);

}


 // =========================
// GET MY MENU
// =========================

static Future<Map<String, dynamic>>
    getMyMenu() async {

  try {

    final token = await getToken();

    final response = await http.get(

      Uri.parse(
        ApiConstants.getMyMenu,
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

    );

    debugPrint(
      "GET MENU => ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    debugPrint(
      "GET MENU ERROR => $e",
    );

    return {

      "success": false,
      "message": e.toString(),

    };

  }

}


// =========================
// GET VENDOR DASHBOARD
// =========================

static Future<Map<String, dynamic>>
    getVendorDashboard() async {

  try {

    final token = await getToken();

    final response = await http.get(

      Uri.parse(
        ApiConstants.vendorDashboard,
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

    );

    debugPrint(
      "DASHBOARD => ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    debugPrint(
      "DASHBOARD ERROR => $e",
    );

    return {

      "success": false,
      "message": e.toString(),

    };

  }

}


// =========================
// GET VENDOR ORDERS
// =========================

static Future<Map<String, dynamic>>
    getVendorOrders() async {

  try {

    final token = await getToken();

    final response = await http.get(

      Uri.parse(
        ApiConstants.vendorOrders,
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

    );

    debugPrint(
      "VENDOR ORDERS => ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    debugPrint(
      "GET ORDERS ERROR => $e",
    );

    return {

      "success": false,
      "message": e.toString(),

    };

  }

}

// =========================
// ACCEPT ORDER
// =========================

static Future<Map<String, dynamic>>
    acceptOrder(
  String orderId,
) async {

  try {

    final token = await getToken();

    final response = await http.put(

      Uri.parse(
        ApiConstants.acceptOrder(
          orderId,
        ),
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

    );

    debugPrint(
      "ACCEPT ORDER => ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    debugPrint(
      "ACCEPT ORDER ERROR => $e",
    );

    return {

      "success": false,
      "message": e.toString(),

    };

  }

}


// =========================
// GET WALLET
// =========================
static Future<Map<String, dynamic>> getWallet() async {
  try {
    final token = await getToken();

    final res = await http.get(
      Uri.parse(ApiConstants.wallet),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(res.body);
  } catch (e) {
    return {
      "success": false,
      "message": e.toString(),
    };
  }
}

// =========================
// ADD MONEY
// =========================
static Future<Map<String, dynamic>> addMoneyToWallet(int amount) async {
  try {
    final token = await getToken();

    final res = await http.post(
      Uri.parse(ApiConstants.addMoney),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "amount": amount,
      }),
    );

    return jsonDecode(res.body);
  } catch (e) {
    return {
      "success": false,
      "message": e.toString(),
    };
  }
}


static Future<Map<String, dynamic>>
    getUserProfile() async {

  try {

    final token =
        await getToken();

    final response = await http.get(

      Uri.parse(
        ApiConstants.getUserProfile,
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

    );

    debugPrint(
      "USER PROFILE => ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    debugPrint(
      "GET PROFILE ERROR => $e",
    );

    return {

      "success": false,

      "message": e.toString(),

    };

  }

}

static Future<Map<String, dynamic>> getWalletOrders() async {

  try {

    final token = await getToken();

    final response = await http.get(

      Uri.parse(
        ApiConstants.walletOrders,
      ),

      headers: {

        "Content-Type": "application/json",

        "Authorization": "Bearer $token",

      },

    );

    return jsonDecode(response.body);

  } catch (e) {

    return {

      "success": false,

      "message": e.toString(),

    };
  }
}

static Future<List<VendorModel>> getAllVendorsWithMenu() async {
  try {
    final token = await getToken();

    final response = await http.get(
      Uri.parse(ApiConstants.allVendorsWithMenu),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final json = jsonDecode(response.body);

    final List data = json["data"];

    return data.map((e) => VendorModel.fromJson(e)).toList();

  } catch (e) {
    debugPrint("ALL VENDORS ERROR => $e");
    return [];
  }
}

static Future<Map<String, dynamic>> createOrder({
  required String vendorId,
  required List<Map<String, dynamic>> items,
  required double totalAmount,
  required String pickupTime,
}) async {
  try {
    final token = await getToken();

    final response = await http.post(
      Uri.parse(ApiConstants.createOrder),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "vendor": vendorId,
        "items": items,
        "totalAmount": totalAmount,
        "pickupTime": pickupTime,
      }),
    );

    debugPrint("CREATE ORDER => ${response.body}");

    return jsonDecode(response.body);
  } catch (e) {
    debugPrint("CREATE ORDER ERROR => $e");
    return {
      "success": false,
      "message": e.toString(),
    };
  }
}

// =========================
// READY ORDER
// =========================

static Future<Map<String, dynamic>>
    readyOrder(
  String orderId,
) async {

  try {

    final token = await getToken();

    final response = await http.put(

      Uri.parse(
        ApiConstants.readyOrder(
          orderId,
        ),
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

    );

    debugPrint(
      "READY ORDER => ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    debugPrint(
      "READY ORDER ERROR => $e",
    );

    return {

      "success": false,
      "message": e.toString(),

    };

  }

}


static Future<Map<String, dynamic>>
    getOrdersByUser(String userId) async {

  try {

    final token = await getToken();

    final response = await http.get(

      Uri.parse(
        "${ApiConstants.getOrdersByUser}$userId",
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",
      },
    );

    return jsonDecode(response.body);

  } catch (e) {

    return {
      "success": false,
      "message": e.toString(),
    };
  }
}

// ================= GET USER ID =================
static Future<String?> getUserId() async {

  try {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString("userId");

  } catch (e) {

    return null;
  }
}
// =========================
// ADD MENU ITEM
// =========================

static Future<Map<String, dynamic>>
    addMenuItem({

  required String foodName,
  required int price,
  required String image,
  required String description,

}) async {

  try {

    final token = await getToken();

    final response = await http.post(

      Uri.parse(
        ApiConstants.addMenu,
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

      body: jsonEncode({

        "foodName": foodName,
        "price": price,
        "image": image,
        "description": description,

      }),

    );

    debugPrint(
      "ADD MENU => ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    debugPrint(
      "ADD MENU ERROR => $e",
    );

    return {

      "success": false,
      "message": e.toString(),

    };

  }

}

// =========================
// UPDATE MENU STOCK
// =========================

static Future<Map<String, dynamic>>
    updateMenuStock({

  required String menuId,
  required String stockStatus,

}) async {

  try {

    final token = await getToken();

    final response = await http.put(

      Uri.parse(
        ApiConstants
            .updateMenuStock(
          menuId,
        ),
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

      body: jsonEncode({

        "stockStatus":
            stockStatus,

      }),

    );

    debugPrint(
      "UPDATE STOCK => ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    debugPrint(
      "UPDATE STOCK ERROR => $e",
    );

    return {

      "success": false,
      "message": e.toString(),

    };

  }

}

  // =========================
  // GET VENDOR PROFILE
  // =========================

  static Future<Map<String, dynamic>>
      getVendorProfile() async {

    final token =
        await getToken();

    final res = await http.get(

      Uri.parse(
        ApiConstants.vendorProfile,
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

    );

    return jsonDecode(res.body);

  }

  // =========================
  // UPDATE CANTEEN STATUS
  // =========================

static Future<Map<String, dynamic>>
    updateCanteenStatus(
  bool isOpen,
) async {

  final token = await getToken();

  final bodyData = {

    "canteenStatus":
        isOpen
            ? "Open"
            : "Closed",

  };

  print("FINAL BODY => $bodyData");

  final res = await http.put(

    Uri.parse(
      ApiConstants.canteenStatus,
    ),

    headers: {

      "Content-Type":
          "application/json",

      "Authorization":
          "Bearer $token",

    },

    body: jsonEncode(bodyData),

  );

  print("STATUS CODE => ${res.statusCode}");
  print("STATUS BODY => ${res.body}");

  return jsonDecode(res.body);

}

  // =========================
  // GET TOKEN
  // =========================

  static Future<String?> getToken() async {

    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
      "token",
    );

  }

  // =========================
  // GET ROLE
  // =========================

  static Future<String?> getRole() async {

    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
      "role",
    );

  }

  // =========================
  // FORGOT PASSWORD
  // =========================

  static Future<Map<String, dynamic>>
      forgotPassword(
    String email,
  ) async {

    final res = await http.post(

      Uri.parse(
        ApiConstants.forgotPassword,
      ),

      headers: {

        "Content-Type":
            "application/json",

      },

      body: jsonEncode({

        "email": email,

      }),

    );

    return jsonDecode(res.body);

  }

  // =========================
  // RESET PASSWORD
  // =========================

  static Future<Map<String, dynamic>>
      resetPassword(
    String token,
    String password,
  ) async {

    final res = await http.post(

      Uri.parse(
        "${ApiConstants.resetPassword}/$token",
      ),

      headers: {

        "Content-Type":
            "application/json",

      },

      body: jsonEncode({

        "password": password,

      }),

    );

    return jsonDecode(res.body);

  }

  // =========================
  // SEND OTP
  // =========================

  static Future<Map<String, dynamic>>
      sendOtp(
    String email,
  ) async {

    final res = await http.post(

      Uri.parse(
        ApiConstants.sendOtp,
      ),

      headers: {

        "Content-Type":
            "application/json",

      },

      body: jsonEncode({

        "email": email,

      }),

    );

    return jsonDecode(res.body);

  }

  // =========================
  // VERIFY OTP
  // =========================

  static Future<Map<String, dynamic>>
      verifyOtp(
    Map data,
  ) async {

    final res = await http.post(

      Uri.parse(
        ApiConstants.verifyOtp,
      ),

      headers: {

        "Content-Type":
            "application/json",

      },

      body: jsonEncode(data),

    );

    return jsonDecode(res.body);

  }

}