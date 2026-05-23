import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

import '../user/usernav.dart';
import '../vendor/vendor_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // CONTROLLERS
  final email = TextEditingController();
  final password = TextEditingController();
  
  // FORM KEY
  final formKey = GlobalKey<FormState>();

  // LOADING STATE
  bool loading = false;

  @override
  void dispose() {
    // Free up resources when the screen is removed from the widget tree
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // =========================
  // LOGIN FUNCTION
  // =========================
  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final res = await AuthService.login({
        "email": email.text.trim(),
        "password": password.text,
      });

      setState(() => loading = false);

      if (res == null || res["user"] == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Failed"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final user = res["user"];
      final userId = user["_id"].toString();
      final role = (user["role"] ?? "").toString().toLowerCase();

      // SAVE USER DATA
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", userId);

      if (res["token"] != null) {
        await prefs.setString("token", res["token"]);
        print("✅ TOKEN SAVED => ${res["token"]}");
      } else {
        print("❌ TOKEN NOT FOUND IN RESPONSE");
      }

      // GET FCM TOKEN
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print("🔥 FCM TOKEN => $fcmToken");

      // SEND TOKEN TO BACKEND
      if (fcmToken != null) {
        await FCMService.sendTokenToBackend(fcmToken, userId);
      }

      if (!mounted) return;

      // SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful"),
          backgroundColor: Colors.green,
        ),
      );

      // ROLE BASED NAVIGATION
      if (role == "vendor") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const VendorNav()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserNav()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => loading = false);
      print("❌ LOGIN ERROR => $e");

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
  // UI BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF9370DB);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Premium layout touch
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
                    // TOP PROFILE/LOCK ICON
                    const Icon(
                      Icons.lock_person_rounded,
                      size: 80,
                      color: themeColor,
                    ),
                    const SizedBox(height: 12),
                    
                    // HEADER TITLES
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Sign in to continue your journey",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // EMAIL TEXTFIELD
                    CustomTextField(
                      controller: email,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      validator: (v) {
                        if (v == null || !v.contains("@")) {
                          return "Enter valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // PASSWORD TEXTFIELD
                    CustomTextField(
                      controller: password,
                      label: "Password",
                      obscureText: true,
                      icon: Icons.lock_outline,
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return "Min 6 chars required";
                        }
                        return null;
                      },
                    ),
                    
                    // FORGOT PASSWORD
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton(
                          onPressed: () {
                            print("🔗 FORGOT PASSWORD CLICKED");
                            // Add your forgot password navigation route here
                            // Navigator.pushNamed(context, "/forgot-password");
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // LOGIN BUTTON
                    CustomButton(
                      text: "LOGIN",
                      isLoading: loading,
                      onTap: handleLogin,
                    ),
                    const SizedBox(height: 25),

                    // DONT HAVE AN ACCOUNT REGISTRATION BLOCK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/register");
                          },
                          child: const Text(
                            "Register Now",
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