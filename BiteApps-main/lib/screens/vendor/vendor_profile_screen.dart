import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class VendorProfileScreen extends StatefulWidget {

  final Function(bool) onStatusChanged;

  const VendorProfileScreen({

    super.key,

    required this.onStatusChanged,

  });

  @override
  State<VendorProfileScreen> createState() =>
      _VendorProfileScreenState();

}

class _VendorProfileScreenState
    extends State<VendorProfileScreen> {

  bool isOrderSoundEnabled = true;

  bool isCanteenOpen = false;

  String canteenName = "";

  String managerName = "";

  bool isLoading = true;

  // =========================
  // INIT
  // =========================

  @override
  void initState() {

    super.initState();

    loadVendorProfile();

  }

  // =========================
  // LOAD PROFILE
  // =========================

  Future<void> loadVendorProfile() async {

    try {

      final response =
          await AuthService.getVendorProfile();

      print("API RESPONSE: $response");

      if (response["success"] == true) {

        final vendor = response["vendor"];

        setState(() {

          canteenName =
              vendor["canteenName"] ?? "";

          managerName =
              vendor["name"] ?? "";

          // IMPORTANT 🔥
          isCanteenOpen =
              vendor["isOpen"] ?? false;

          isLoading = false;

        });

      } else {

        setState(() {

          isLoading = false;

        });

      }

    } catch (e) {

      setState(() {

        isLoading = false;

      });

      debugPrint("PROFILE ERROR: $e");

    }

  }

  // =========================
  // EDIT PROFILE
  // =========================

  void _showEditProfileDialog() {

    final nameController =
        TextEditingController(
      text: canteenName,
    );

    final managerController =
        TextEditingController(
      text: managerName,
    );

    final dialogFormKey =
        GlobalKey<FormState>();

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(20),

          ),

          title: const Text(

            "Edit Canteen Info",

            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),

          ),

          content: Form(

            key: dialogFormKey,

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                TextFormField(

                  controller:
                      nameController,

                  decoration:
                      const InputDecoration(

                    labelText:
                        "Canteen Name",

                    prefixIcon:
                        Icon(
                      Icons.storefront,
                    ),

                  ),

                  validator: (v) {

                    if (v == null ||
                        v.trim().isEmpty) {

                      return "Enter canteen name";

                    }

                    return null;

                  },

                ),

                const SizedBox(height: 15),

                TextFormField(

                  controller:
                      managerController,

                  decoration:
                      const InputDecoration(

                    labelText:
                        "Manager Name",

                    prefixIcon:
                        Icon(
                      Icons.person_outline,
                    ),

                  ),

                  validator: (v) {

                    if (v == null ||
                        v.trim().isEmpty) {

                      return "Enter manager name";

                    }

                    return null;

                  },

                ),

              ],

            ),

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child: const Text(

                "Cancel",

                style: TextStyle(
                  color: Colors.grey,
                ),

              ),

            ),

            ElevatedButton(

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    const Color(0xFF9370DB),

              ),

              onPressed: () async {

                if (dialogFormKey
                    .currentState!
                    .validate()) {

                  final response =
                      await AuthService
                          .updateCanteenInfo(

                    canteenName:
                        nameController.text.trim(),

                    managerName:
                        managerController.text.trim(),

                  );

                  if (response["success"] == true) {

                    setState(() {

                      canteenName =
                          nameController.text
                              .trim();

                      managerName =
                          managerController.text
                              .trim();

                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Profile updated successfully!",
                        ),

                        backgroundColor:
                            Colors.green,

                      ),

                    );

                  } else {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      SnackBar(

                        content: Text(

                          response["message"] ??
                              "Update failed",

                        ),

                        backgroundColor:
                            Colors.red,

                      ),

                    );

                  }

                }

              },

              child: const Text(

                "Save",

                style: TextStyle(
                  color: Colors.white,
                ),

              ),

            ),

          ],

        );

      },

    );

  }

  // =========================
  // SUPPORT
  // =========================

  void _handleVendorSupport() {

    showModalBottomSheet(

      context: context,

      shape:
          const RoundedRectangleBorder(

        borderRadius:
            BorderRadius.vertical(

          top: Radius.circular(20),

        ),

      ),

      builder: (context) {

        return Padding(

          padding:
              const EdgeInsets.all(20),

          child: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Text(

                "Contact BitePay Admin Support",

                style: TextStyle(

                  fontSize: 18,

                  fontWeight:
                      FontWeight.bold,

                ),

              ),

              const SizedBox(height: 20),

              ListTile(

                leading: const Icon(

                  Icons.phone,

                  color: Colors.green,

                ),

                title: const Text(
                  "Call Admin Support",
                ),

                subtitle: const Text(
                  "+91 98765 43210",
                ),

              ),

              ListTile(

                leading: const Icon(

                  Icons.chat_bubble_outline,

                  color: Colors.blue,

                ),

                title: const Text(
                  "Chat on WhatsApp",
                ),

              ),

            ],

          ),

        );

      },

    );

  }

  Future<void> doLogout(BuildContext context) async {

    final res = await AuthService.logout();

    if (res["success"] == true) {

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(

        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),

        (route) => false,

      );

    }

  }

  // =========================
  // LOGOUT
  // =========================

  void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),

            onPressed: () async {
              final navigator = Navigator.of(context);

              Navigator.pop(context); // close dialog

              final res = await AuthService.logout();

              if (!mounted) return;

              if (res["success"] == true) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },

            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(16),

              child: Column(

                children: [

                  const SizedBox(height: 10),

                  CircleAvatar(

                    radius: 55,

                    backgroundColor:
                        isCanteenOpen
                            ? const Color(
                                0xFF9370DB,
                              )
                            : Colors.grey,

                    child: Icon(

                      isCanteenOpen
                          ? Icons.storefront
                          : Icons.store,

                      size: 60,

                      color: Colors.white,

                    ),

                  ),

                  const SizedBox(height: 15),

                  Text(

                    canteenName,

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          isCanteenOpen
                              ? Colors.black
                              : Colors.grey,

                    ),

                  ),

                  Text(

                    "Manager: $managerName",

                    style: const TextStyle(
                      color: Colors.grey,
                    ),

                  ),

                  const SizedBox(height: 8),

                  Container(

                    padding:
                        const EdgeInsets.symmetric(

                      horizontal: 12,
                      vertical: 4,

                    ),

                    decoration: BoxDecoration(

                      color:
                          isCanteenOpen
                              ? Colors.green
                                  .withOpacity(0.2)
                              : Colors.red
                                  .withOpacity(0.2),

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),

                    ),

                    child: Text(

                      isCanteenOpen
                          ? "OPEN"
                          : "CLOSED",

                      style: TextStyle(

                        color:
                            isCanteenOpen
                                ? Colors.green
                                : Colors.red,

                        fontWeight:
                            FontWeight.bold,

                      ),

                    ),

                  ),

                  const Divider(height: 40),

                  // =========================
                  // CANTEEN STATUS
                  // =========================

                  SwitchListTile(

                    title: const Text(

                      "Canteen Status",

                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),

                    ),

                    subtitle: Text(

                      isCanteenOpen
                          ? "Accepting Orders"
                          : "Closed",

                    ),

                    value: isCanteenOpen,

                    activeColor:
                        Colors.green,

                    onChanged: (val) async {

                      setState(() {

                        isCanteenOpen = val;

                      });

                      widget.onStatusChanged(val);

                      try {

                        final response =
                            await AuthService
                                .updateCanteenStatus(
                          val,
                        );

                        if (response["success"] ==
                            true) {

                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(

                            SnackBar(

                              content: Text(

                                val
                                    ? "Canteen Opened"
                                    : "Canteen Closed",

                              ),

                              backgroundColor:
                                  Colors.green,

                            ),

                          );

                        }

                      } catch (e) {

                        debugPrint(
                          "STATUS ERROR: $e",
                        );

                      }

                    },

                  ),

                  SwitchListTile(

                    title: const Text(

                      "New Order Alerts",

                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),

                    ),

                    subtitle: Text(

                      isOrderSoundEnabled
                          ? "Sound On 🔔"
                          : "Muted 🔕",

                    ),

                    value:
                        isOrderSoundEnabled,

                    activeColor:
                        const Color(
                      0xFF9370DB,
                    ),

                    secondary: const Icon(

                      Icons
                          .notifications_active_outlined,

                      color: Color(
                        0xFF9370DB,
                      ),

                    ),

                    onChanged: (val) {

                      setState(() {

                        isOrderSoundEnabled =
                            val;

                      });

                    },

                  ),

                  const Divider(),

                  _buildItem(

                    Icons.edit,

                    "Edit Canteen Info",

                    "Change canteen details",

                    _showEditProfileDialog,

                  ),

                  _buildItem(

                    Icons.help_center_outlined,

                    "Vendor Support",

                    "Contact support team",

                    _handleVendorSupport,

                  ),

                  const SizedBox(height: 30),

                  ListTile(

                    leading: const Icon(

                      Icons.logout,

                      color: Colors.red,

                    ),

                    title: const Text(

                      "Logout",

                      style: TextStyle(

                        color: Colors.red,

                        fontWeight:
                            FontWeight.bold,

                      ),

                    ),

                    onTap:
                        _showLogoutDialog,

                  ),

                ],

              ),

            ),

    );

  }

  // =========================
  // HELPER
  // =========================

  Widget _buildItem(

    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,

  ) {

    return ListTile(

      leading: Icon(

        icon,

        color: const Color(
          0xFF9370DB,
        ),

      ),

      title: Text(

        title,

        style: const TextStyle(
          fontWeight:
              FontWeight.bold,
        ),

      ),

      subtitle: Text(subtitle),

      trailing: const Icon(

        Icons.arrow_forward_ios,

        size: 14,

      ),

      onTap: onTap,

    );

  }

}