import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../user/notification_screen.dart';
import 'vendor_orders_screen.dart';
import 'vendor_menu_screen.dart';
import 'vendor_earnings_screen.dart';
import 'vendor_profile_screen.dart';

class VendorNav extends StatefulWidget {
  const VendorNav({super.key});

  @override
  State<VendorNav> createState() => _VendorNavState();
}

class _VendorNavState extends State<VendorNav> {
  int _currentIndex = 0;
  int _newOrderCount = 0;
  bool isCanteenOpen = true;

  @override
  void initState() {
    super.initState();
    loadUnreadCount();
  }

  Future<void> loadUnreadCount() async {
    final count = await NotificationService.getUnreadCount();

    if (!mounted) return;

    setState(() {
      _newOrderCount = count;
    });
  }

  Future<void> openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );

    // 🔥 return પછી ફરી API call
    loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const VendorOrdersScreen(),
      const VendorMenuScreen(),
      const VendorEarningsScreen(),
      VendorProfileScreen(onStatusChanged: (val) {}),
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "BitePay",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,

        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: openNotifications,
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.black87,
                ),
              ),

              if (_newOrderCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$_newOrderCount",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Chip(
              label: Text(
                isCanteenOpen ? "OPEN" : "CLOSED",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              backgroundColor:
                  isCanteenOpen ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),

      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF9370DB),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Menu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Earnings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}