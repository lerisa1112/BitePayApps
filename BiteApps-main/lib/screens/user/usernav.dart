import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './explore_screen.dart';
import './order_screen.dart';
import './wallet_screen.dart';
import './profile_screen.dart';
import './notification_screen.dart';
import './chat_screen.dart';

import '../../services/notification_service.dart';

class UserNav extends StatefulWidget {
  const UserNav({super.key});

  @override
  State<UserNav> createState() => _UserNavState();
}

class _UserNavState extends State<UserNav> {

  int _currentIndex = 0;

  int _notificationCount = 0;

  // 🔥 USER ID
  String userId = "";

  @override
  void initState() {
    super.initState();

    print("================================");
    print("🚀 USER NAV INIT");
    print("================================");

    loadNotifications();

    loadUserId();
  }

  // 🔥 LOAD USER ID
  Future<void> loadUserId() async {

    try {

      print("================================");
      print("📦 LOADING USER ID FROM STORAGE");
      print("================================");

      final prefs =
          await SharedPreferences.getInstance();

      userId =
          prefs.getString("userId") ?? "";

      print("================================");
      print("✅ USER ID LOADED");
      print("👤 USER ID => $userId");
      print("================================");

      if (!mounted) return;

      setState(() {});

    } catch (e) {

      print("================================");
      print("❌ ERROR LOADING USER ID");
      print("❌ ERROR => $e");
      print("================================");
    }
  }

  // 🔔 LOAD NOTIFICATIONS
  Future<void> loadNotifications() async {

    try {

      print("================================");
      print("🔔 LOADING NOTIFICATIONS");
      print("================================");

      final count =
          await NotificationService.getUnreadCount();

      print("🔔 NOTIFICATION COUNT => $count");

      if (!mounted) return;

      setState(() {
        _notificationCount = count;
      });

    } catch (e) {

      print("================================");
      print("❌ NOTIFICATION ERROR");
      print("❌ ERROR => $e");
      print("================================");
    }
  }

  // 🔔 NOTIFICATION ICON
  Widget _buildNotificationIcon() {

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: Stack(
        clipBehavior: Clip.none,

        children: [

          InkWell(

            borderRadius:
                BorderRadius.circular(30),

            onTap: () async {

              print("================================");
              print("🔔 NOTIFICATION BUTTON CLICKED");
              print("================================");

              await Navigator.push(

                context,

                MaterialPageRoute(
                  builder: (context) =>
                      const NotificationScreen(),
                ),
              );

              loadNotifications();
            },

            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,

              child: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.black87,
                size: 26,
              ),
            ),
          ),

          // 🔥 COUNT BADGE
          if (_notificationCount > 0)
            Positioned(
              right: 2,
              top: 2,

              child: Container(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),

                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),

                decoration: BoxDecoration(

                  color: Colors.amber,

                  borderRadius:
                      BorderRadius.circular(20),

                  boxShadow: const [

                    BoxShadow(
                      color: Colors.orangeAccent,
                      blurRadius: 5,
                    ),
                  ],
                ),

                child: Text(

                  _notificationCount > 9
                      ? "9+"
                      : "$_notificationCount",

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    print("================================");
    print("🏗️ USER NAV BUILD");
    print("👤 CURRENT USER ID => $userId");
    print("📱 CURRENT TAB => $_currentIndex");
    print("================================");

    // ⛔ WAIT UNTIL USER ID LOAD
    if (userId.isEmpty) {

      print("⏳ WAITING FOR USER ID...");

      return const Scaffold(

        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 📱 PAGES
    final pages = [

      const ExploreScreen(),

      const WalletScreen(),

      // ✅ CHAT SCREEN WITH USER ID
      ChatScreen(
        userId: userId,
      ),

      const OrdersScreen(),

      const ProfileScreen(),
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

        centerTitle: false,

        backgroundColor: Colors.white,

        elevation: 0.5,

        actions: [

          _buildNotificationIcon(),

          // 🛒 CART
          IconButton(

            onPressed: () {

              print("================================");
              print("🛒 CART BUTTON CLICKED");
              print("================================");

              ScaffoldMessenger.of(context)
                  .showSnackBar(

                const SnackBar(
                  content: Text("Opening Cart..."),
                ),
              );
            },

            icon: const Icon(
              Icons.shopping_bag_outlined,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // 🔥 BODY
      body: pages[_currentIndex],

      // 🔻 BOTTOM NAV
      bottomNavigationBar:
          BottomNavigationBar(

        currentIndex: _currentIndex,

        onTap: (index) {

          print("================================");
          print("📱 TAB CHANGED");
          print("➡️ NEW TAB => $index");
          print("================================");

          setState(() {
            _currentIndex = index;
          });
        },

        selectedItemColor:
            const Color(0xFF9370DB),

        unselectedItemColor: Colors.grey,

        type:
            BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Explore",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: "Wallet",
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.chat_bubble_outline_rounded),

            activeIcon:
                Icon(Icons.chat_bubble_rounded),

            label: "Chat",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Orders",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}