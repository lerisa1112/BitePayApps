import 'dart:convert';
import 'package:http/http.dart' as http;

class FCMService {
  static const String baseUrl = "https://bitepay.onrender.com";

  static Future<void> sendTokenToBackend(
    String fcmToken,
    String userId,
  ) async {
    try {
      print("🚀 FCM SERVICE CALLED");
      print("👤 USER ID => $userId");
      print("🔥 TOKEN => $fcmToken");

      final url = Uri.parse("$baseUrl/api/user/update-token");

      final bodyData = {
        "userId": userId,
        "fcmToken": fcmToken,
      };

      print("📤 REQUEST URL => $url");
      print("📦 BODY => $bodyData");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      print("📥 STATUS CODE => ${response.statusCode}");
      print("🔥 RESPONSE BODY => ${response.body}");

      if (response.statusCode == 200) {
        print("✅ TOKEN SAVED SUCCESSFULLY");
      } else {
        print("❌ FAILED TO SAVE TOKEN");
      }
    } catch (e) {
      print("❌ FCM SERVICE ERROR => $e");
    }
  }
}