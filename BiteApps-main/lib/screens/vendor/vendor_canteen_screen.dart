import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

import 'vendor_nav.dart';

class VendorCanteenScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;

  const VendorCanteenScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<VendorCanteenScreen> createState() =>
      _VendorCanteenScreenState();
}

class _VendorCanteenScreenState extends State<VendorCanteenScreen> {
  final shopName = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final openingTime = TextEditingController();
  final closingTime = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool loading = false;

  void registerVendor() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      // =========================
      // 1. REGISTER VENDOR
      // =========================
      final res = await AuthService.register({
        "name": widget.name,
        "email": widget.email,
        "phone": widget.phone,
        "password": widget.password,
        "role": "vendor",

        "canteenName": shopName.text.trim(),
        "shopDescription": description.text.trim(),
        "canteenLocation": location.text.trim(),
        "openingTime": openingTime.text.trim(),
        "closingTime": closingTime.text.trim(),
      });

      setState(() => loading = false);

      print("✅ REGISTER RESPONSE => $res");

      if (res == null || res["user"] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vendor Registration Failed"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userId = res["user"]["_id"].toString();

      // =========================
      // 2. 🔥 GET FCM TOKEN (IMPORTANT FIX)
      // =========================
      final fcmToken =
          await FirebaseMessaging.instance.getToken();

      print("🔥 VENDOR FCM TOKEN => $fcmToken");

      // =========================
      // 3. SEND TOKEN TO BACKEND
      // =========================
      if (fcmToken != null) {
        await FCMService.sendTokenToBackend(
          fcmToken,
          userId,
        );

        print("✅ FCM TOKEN SAVED TO BACKEND");
      }

      // =========================
      // SUCCESS MESSAGE
      // =========================
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vendor Registered Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      // =========================
      // NAVIGATION
      // =========================
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const VendorNav(),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() => loading = false);

      print("❌ ERROR => $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: shopName,
                label: "Canteen Name",
                icon: Icons.store,
                validator: (v) =>
                    v!.isEmpty ? "Enter canteen name" : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: description,
                label: "Description",
                icon: Icons.description,
                validator: (v) =>
                    v!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: location,
                label: "Location",
                icon: Icons.location_on,
                validator: (v) =>
                    v!.isEmpty ? "Enter location" : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: openingTime,
                label: "Opening Time",
                icon: Icons.access_time,
                validator: (v) =>
                    v!.isEmpty ? "Enter opening time" : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: closingTime,
                label: "Closing Time",
                icon: Icons.lock_clock,
                validator: (v) =>
                    v!.isEmpty ? "Enter closing time" : null,
              ),
              const SizedBox(height: 30),

              CustomButton(
                text: "REGISTER VENDOR",
                isLoading: loading,
                onTap: registerVendor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}