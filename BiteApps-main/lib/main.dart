import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'services/local_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_screen.dart';
import 'screens/auth/otp_screen.dart';

/// =========================
/// BACKGROUND HANDLER
/// =========================
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔥 BG NOTIFICATION => ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await LocalNotificationService.init(); // 🔥 IMPORTANT
      initFCM();
    });
  }

  Future<void> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // =========================
    // PERMISSION
    // =========================
    await messaging.requestPermission();

    // =========================
    // FOREGROUND MESSAGE
    // =========================
    FirebaseMessaging.onMessage.listen((message) {
      print("🔥 FOREGROUND NOTIFICATION");

      final title = message.notification?.title ?? "";
      final body = message.notification?.body ?? "";

      print("Title => $title");
      print("Body => $body");

      // 🔥 SHOW POPUP NOTIFICATION
      if (title.isNotEmpty || body.isNotEmpty) {
        LocalNotificationService.showNotification(title, body);
      }
    });

    // =========================
    // NOTIFICATION CLICK
    // =========================
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("📲 NOTIFICATION CLICKED");
    });

    // =========================
    // TOKEN (DEBUG ONLY)
    // =========================
    String? token = await messaging.getToken();
    print("🔥 FCM TOKEN => $token");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BitePay App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotScreen(),
        '/otp': (context) => const OtpScreen(),
      },
    );
  }
}