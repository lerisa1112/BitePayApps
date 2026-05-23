import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class NotificationService {

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? "";
  }

  static Future<List<dynamic>> fetchNotifications() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse(ApiConstants.notifications),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["notifications"] ?? [];
    }

    return [];
  }

  // 🔥 ADD THIS (FIX)
  static Future<int> getUnreadCount() async {
    final list = await fetchNotifications();

    return list.where((item) => item["isRead"] == false).length;
  }

  static Future<void> deleteNotification(String id) async {
    final token = await getToken();

    await http.delete(
      Uri.parse(ApiConstants.deleteNotification(id)),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  static Future<void> clearNotifications() async {
    final token = await getToken();

    await http.delete(
      Uri.parse(ApiConstants.clearAllNotifications),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }
}