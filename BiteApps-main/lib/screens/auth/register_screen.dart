import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';

import '../vendor/vendor_canteen_screen.dart';
import '../vendor/vendor_nav.dart';
import '../user/usernav.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // CONTROLLERS
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  // FORM KEY
  final formKey = GlobalKey<FormState>();

  // ROLE
  String? selectedRole;
  final List<String> roles = ['user', 'vendor', 'admin'];

  // LOADING
  bool loading = false;

  @override
  void dispose() {
    // Safely cleaning up controllers to prevent memory leaks
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  // =========================
  // REGISTER FUNCTION
  // =========================
  void handleRegister() async {
    print("🚀 REGISTER BUTTON CLICKED");

    // VALIDATION
    if (!formKey.currentState!.validate()) {
      print("❌ FORM VALIDATION FAILED");
      return;
    }

    // ROLE CHECK
    if (selectedRole == null) {
      print("❌ ROLE NOT SELECTED");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select role"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // =========================
    // 🔥 VENDOR FLOW
    // =========================
    if (selectedRole == "vendor") {
      print("🚀 GOING TO VENDOR DETAILS SCREEN");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VendorCanteenScreen(
            name: name.text.trim(),
            email: email.text.trim(),
            phone: phone.text.trim(),
            password: password.text,
          ),
        ),
      );
      return;
    }

    // =========================
    // USER / ADMIN REGISTER
    // =========================
    setState(() {
      loading = true;
    });

    try {
      // REQUEST BODY
      final body = {
        "name": name.text.trim(),
        "email": email.text.trim(),
        "phone": phone.text.trim(),
        "password": password.text,
        "role": selectedRole,
      };

      print("📦 REGISTER BODY => $body");

      // API CALL
      final res = await AuthService.register(body);
      print("✅ API RESPONSE => $res");

      setState(() {
        loading = false;
      });

      // NULL RESPONSE
      if (res == null) {
        print("❌ RESPONSE IS NULL");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration Failed"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // FAILED RESPONSE
      if (res["success"] != true) {
        print("❌ API FAILED");
        print("❌ MESSAGE => ${res["message"]}");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Registration Failed"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // USER DATA CHECK
      if (res["user"] == null) {
        print("❌ USER DATA NULL");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User data missing"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // USER ID
      final userId = res["user"]["_id"].toString();
      print("👤 USER ID => $userId");

      // SAVE USER ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userId);
      print("💾 USER ID SAVED");

      // =========================
      // FCM TOKEN
      // =========================
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print("🔥 FCM TOKEN GENERATED => $fcmToken");

      // SEND TOKEN
      if (fcmToken != null) {
        try {
          print("📤 SENDING TOKEN TO BACKEND...");
          await FCMService.sendTokenToBackend(fcmToken, userId);
          print("✅ TOKEN SENT TO BACKEND");
        } catch (e) {
          print("❌ FCM ERROR => $e");
        }
      }

      // =========================
      // NAVIGATION
      // =========================
      if (!mounted) return;

      // ADMIN
      if (selectedRole == "admin") {
        print("🚀 GOING TO ADMIN");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const VendorNav()),
          (route) => false,
        );
      }
      // USER
      else {
        print("🚀 GOING TO USER");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserNav()),
          (route) => false,
        );
      }

      // SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["message"] ?? "Registered Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      setState(() {
        loading = false;
      });
      print("🔥 REGISTER ERROR => $e");
      print("🔥 STACK TRACE =>");
      print(stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF9370DB);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Soft background contrast
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Card(
            elevation: 8,
            shadowColor: themeColor.withAlpha(40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Join Us!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create your account to get started",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // NAME
                    CustomTextField(
                      controller: name,
                      label: "Full Name",
                      icon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Name required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // EMAIL
                    CustomTextField(
                      controller: email,
                      label: "Email",
                      icon: Icons.email_outlined,
                      validator: (v) {
                        if (v == null || !v.contains("@")) {
                          return "Invalid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // PHONE
                    CustomTextField(
                      controller: phone,
                      label: "Phone",
                      icon: Icons.phone_android,
                      validator: (v) {
                        if (v == null || v.length < 10) {
                          return "Invalid phone";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // ROLE DROPDOWN
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      hint: const Text("Select Role"),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.badge_outlined, color: themeColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: themeColor, width: 2),
                        ),
                      ),
                      items: roles
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                role.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                        print("🎭 SELECTED ROLE => $value");
                      },
                    ),
                    const SizedBox(height: 18),

                    // PASSWORD
                    CustomTextField(
                      controller: password,
                      label: "Password",
                      obscureText: true,
                      icon: Icons.lock_outline,
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return "Min 6 chars";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // REGISTER BUTTON
                    CustomButton(
                      text: "CREATE ACCOUNT",
                      isLoading: loading,
                      onTap: handleRegister,
                    ),
                    const SizedBox(height: 20),

                    // ALREADY HAVE AN ACCOUNT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/login");
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}