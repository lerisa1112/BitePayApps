import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final email = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  void handleSendOtp() async {
    if (formKey.currentState!.validate()) {
      setState(() => loading = true);
      
      // તમારી API મુજબ sendOtp કોલ કરો
      final res = await AuthService.sendOtp(email.text.trim());

      setState(() => loading = false);

      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP Sent to Email")));
        // OTP સ્ક્રીન પર જાઓ અને ઈમેલ ડેટા પાસ કરો
        Navigator.pushNamed(context, "/otp", arguments: email.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["message"] ?? "Error sending OTP")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 80, color: Color(0xFF9370DB)),
            const SizedBox(height: 20),
            const Text("Forgot Password?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Form(key: formKey, child: CustomTextField(controller: email, label: "Email Address", icon: Icons.email_outlined)),
            const SizedBox(height: 25),
            CustomButton(text: "SEND OTP", isLoading: loading, onTap: handleSendOtp),
          ],
        ),
      ),
    );
  }
}