import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';
import '../../core/constants/api_constants.dart';

import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();

}

class _ProfileScreenState
    extends State<ProfileScreen> {

  bool isLoading = true;

  String name = "";
  String email = "";
  String phone = "";

  @override
  void initState() {

    super.initState();

    fetchProfile();

  }

  // ================= GET USER PROFILE =================

  Future<void> fetchProfile() async {

    try {

      final token =
          await AuthService.getToken();

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

      final data =
          jsonDecode(response.body);

      debugPrint(
        "PROFILE => $data",
      );

      if (data["success"] == true) {

        final user =
            data["user"];

        setState(() {

          name =
              user["name"] ?? "";

          email =
              user["email"] ?? "";

          phone =
              user["phone"] ?? "";

          isLoading = false;

        });

      } else {

        setState(() {
          isLoading = false;
        });

      }

    } catch (e) {

      debugPrint(
        "PROFILE ERROR => $e",
      );

      setState(() {
        isLoading = false;
      });

    }

  }

  // ================= EDIT PROFILE =================

  void _showEditProfileSheet() {

    TextEditingController
        nameController =
        TextEditingController(
      text: name,
    );

    TextEditingController
        phoneController =
        TextEditingController(
      text: phone,
    );

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      shape:
          const RoundedRectangleBorder(

        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),

      ),

      builder: (context) => Padding(

        padding: EdgeInsets.only(

          bottom:
              MediaQuery.of(context)
                  .viewInsets
                  .bottom,

          top: 25,

          left: 20,

          right: 20,

        ),

        child: Column(

          mainAxisSize:
              MainAxisSize.min,

          children: [

            const Text(

              "Update Profile",

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(
              height: 20,
            ),

            TextField(

              controller:
                  nameController,

              decoration:
                  InputDecoration(

                labelText:
                    "Full Name",

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),

                ),

              ),

            ),

            const SizedBox(
              height: 15,
            ),

            TextField(

              controller:
                  phoneController,

              decoration:
                  InputDecoration(

                labelText:
                    "Phone Number",

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),

                ),

              ),

            ),

            const SizedBox(
              height: 25,
            ),

            SizedBox(

              width:
                  double.infinity,

              child: ElevatedButton(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(
                    0xFF9370DB,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

                ),

                onPressed: () {

                  setState(() {

                    name =
                        nameController.text;

                    phone =
                        phoneController.text;

                  });

                  Navigator.pop(
                    context,
                  );

                },

                child: const Text(

                  "Save Changes",

                  style: TextStyle(
                    color: Colors.white,
                  ),

                ),

              ),

            ),

            const SizedBox(
              height: 20,
            ),

          ],

        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(

        body: Center(
          child:
              CircularProgressIndicator(),
        ),

      );

    }

    return Scaffold(

      backgroundColor:
          Colors.white,

      appBar: AppBar(

        title:
            const Text("My Profile"),

        backgroundColor:
            Colors.white,

        foregroundColor:
            Colors.black,

        elevation: 0,

      ),

      body: SingleChildScrollView(

        child: Column(

          children: [

            // ================= HEADER =================

            Container(

              padding:
                  const EdgeInsets.symmetric(
                vertical: 30,
              ),

              width: double.infinity,

              decoration: BoxDecoration(

                color:
                    const Color(
                  0xFF9370DB,
                ).withOpacity(0.05),

                borderRadius:
                    const BorderRadius.vertical(

                  bottom:
                      Radius.circular(40),

                ),

              ),

              child: Column(

                children: [

                  const CircleAvatar(

                    radius: 50,

                    backgroundColor:
                        Color(0xFF9370DB),

                    child: Icon(

                      Icons.person,

                      size: 60,

                      color: Colors.white,

                    ),

                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Text(

                    name,

                    style:
                        const TextStyle(

                      fontSize: 22,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(

                    email,

                    style:
                        const TextStyle(
                      color: Colors.grey,
                    ),

                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(

                    phone,

                    style:
                        const TextStyle(
                      color: Colors.grey,
                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(
              height: 20,
            ),

            // ================= OPTIONS =================

            Padding(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Column(

                children: [

                  _buildProfileItem(

                    Icons.edit_outlined,

                    "Edit Profile",

                    "Change name & phone",

                    _showEditProfileSheet,

                  ),

                  _buildProfileItem(

                    Icons.history,

                    "Order History",

                    "View past orders",

                    () {},

                  ),

                  _buildProfileItem(

                    Icons.security_outlined,

                    "Security",

                    "Change password",

                    () {},

                  ),

                  _buildProfileItem(

                    Icons.help_outline,

                    "Help & Support",

                    "FAQs & Contact",

                    () {},

                  ),

                  const Divider(
                    height: 40,
                  ),

                  ListTile(

                    onTap: () {
                      _showLogoutDialog(
                        context,
                      );
                    },

                    leading: Container(

                      padding:
                          const EdgeInsets.all(
                        8,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.red
                                .withOpacity(
                          0.1,
                        ),

                        shape:
                            BoxShape.circle,

                      ),

                      child: const Icon(

                        Icons.logout_rounded,

                        color: Colors.red,

                      ),

                    ),

                    title: const Text(

                      "Logout",

                      style: TextStyle(

                        color: Colors.red,

                        fontWeight:
                            FontWeight.bold,

                      ),

                    ),

                    trailing: const Icon(

                      Icons.arrow_forward_ios,

                      size: 16,

                      color: Colors.red,

                    ),

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

  // ================= PROFILE ITEM =================

  Widget _buildProfileItem(

    IconData icon,

    String title,

    String sub,

    VoidCallback onTap,

  ) {

    return ListTile(

      onTap: onTap,

      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),

      leading: Container(

        padding:
            const EdgeInsets.all(8),

        decoration: BoxDecoration(

          color:
              const Color(
            0xFF9370DB,
          ).withOpacity(0.1),

          shape: BoxShape.circle,

        ),

        child: Icon(

          icon,

          color:
              const Color(
            0xFF9370DB,
          ),

        ),

      ),

      title: Text(

        title,

        style: const TextStyle(
          fontWeight:
              FontWeight.bold,
        ),

      ),

      subtitle: Text(

        sub,

        style: const TextStyle(

          fontSize: 12,

          color: Colors.grey,

        ),

      ),

      trailing: const Icon(

        Icons.arrow_forward_ios,

        size: 16,

        color: Colors.grey,

      ),

    );

  }

  // ================= LOGOUT =================

  void _showLogoutDialog(
    BuildContext context,
  ) {

    showDialog(

      context: context,

      builder: (context) => AlertDialog(

        title: const Text(
          "Logout",
        ),

        content: const Text(
          "Are you sure you want to logout?",
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(
                context,
              );

            },

            child: const Text(
              "Cancel",
            ),

          ),

          TextButton(

            onPressed: () async {

              // dialog close
              Navigator.pop(context);

              final response =
                  await AuthService.logout();

              print(
                "LOGOUT RESPONSE => $response",
              );

              if (response["success"] == true) {

                if (!mounted) return;

                // 🔥 REPLACE ALL SCREENS
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushAndRemoveUntil(

                  MaterialPageRoute(
                    builder: (_) =>
                        const LoginScreen(),
                  ),

                  (route) => false,

                );

              }

            },

            child: const Text(

              "Logout",

              style: TextStyle(
                color: Colors.red,
              ),

            ),

          ),

        ],

      ),

    );

  }

}