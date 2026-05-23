import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final password = TextEditingController();
  bool loading = false;

  reset() async {
    setState(() => loading = true);

    final res = await AuthService.resetPassword(
      widget.token,
      password.text,
    );

    setState(() => loading = false);

    if (res["success"] == true) {
      Navigator.pushNamedAndRemoveUntil(
          context, "/login", (route) => false);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            CustomTextField(
              controller: password,
              label: "New Password",
              obscureText: true,
            ),

            SizedBox(height: 20),

            loading
                ? CircularProgressIndicator()
                : CustomButton(
                    text: "Reset Password",
                    onTap: reset,
                  ),
          ],
        ),
      ),
    );
  }
}