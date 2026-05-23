import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otp = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  void handleVerifyOtp(String userEmail) async {
    setState(() => loading = true);

    final res = await AuthService.verifyOtp({
      "email": userEmail,
      "otp": otp.text.trim(),
      "password": password.text,
    });

    setState(() => loading = false);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Changed Successfully!")));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["message"] ?? "Invalid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Forgot Screen માંથી મોકલેલો ઈમેલ અહિયાં મળશે
    final userEmail = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.security, size: 80, color: Color(0xFF9370DB)),
            const SizedBox(height: 20),
            Text("Verify OTP for $userEmail", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            CustomTextField(controller: otp, label: "6-Digit OTP", icon: Icons.numbers),
            const SizedBox(height: 15),
            CustomTextField(controller: password, label: "New Password", obscureText: true, icon: Icons.lock_reset),
            const SizedBox(height: 30),
            CustomButton(text: "VERIFY & RESET", isLoading: loading, onTap: () => handleVerifyOtp(userEmail)),
          ],
        ),
      ),
    );
  }
}