import 'dart:convert';

import 'package:TrendTodayCustomer/Utility/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../chat_screen.dart';
import '../home_screen.dart';
import '../main.dart';
import '../work_progress.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeFCM() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _getFCMToken();
    _handleForegroundMessages();
    _handleBackgroundMessages();
  }

  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else {
      print('❌ User declined or has not accepted permission');
    }
  }

  /*static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('nl');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        print("🔔 Notification payload: $payload");
        */ /*print("🔔 Notification tapped, payload: $payload");
        if (payload != null) {
          _navigateFromPayload(payload);
        }*/ /*


        // Handle navigation or logic here if needed
      },
    );

  }*/

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('notification_icon');

    // Add iOS settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings, // Add this line
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        print("🔔 Notification payload: $payload");

        // Handle notification tap
        if (payload != null && payload.isNotEmpty) {
          try {
            final data = jsonDecode(payload);
            final message = RemoteMessage(data: data);
            handleMessageClick(message);
          } catch (e) {
            print("Error parsing notification payload: $e");
          }
        }
      },
    );
  }

  static Future<void> _getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      ConstantVariable.FCMToken = token;
      print("📲 FCM Token: $token");
    } catch (e) {
      print("❌ Error getting FCM token: $e");
    }
    // You can send the token to your server here if needed
  }

  static void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📥 Message received in foreground!");

      //  Print the entire message object
      print("Full Message: ${message.toMap()}");

      if (message.notification != null) {
        print("🔔 Notification Title: ${message.notification?.title}");
        print("🔔 Notification Body: ${message.notification?.body}");

        _showLocalNotification(
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          payload: message.data, // 👈 attach full data
        );
      }
      // Print data payload
      if (message.data.isNotEmpty) {
        print("📦 Data Payload: ${message.data}");
        message.data.forEach((key, value) {
          print("   $key: $value");
        });
      }
    });
  }

  /*static void _handleBackgroundMessages() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 App opened from notification: ${message.notification?.title}');
      // You can navigate or perform logic here based on payload
    });
  }*/

  /*static void _handleBackgroundMessages() {
    // When app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 App opened from notification: ${message.notification?.title}');
      _navigateFromPayload(message.data.toString());
    });

    // When app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('🔥 App launched from terminated state');
        _navigateFromPayload(message.data.toString());
      }
    });
  }*/

  static void _handleBackgroundMessages() {
    // Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🚀 Opened from background");
      handleMessageClick(message);
    });
/*
    // Terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("🔥 Opened from terminated");
        handleMessageClick(message);
      }
    });*/
  }

  static void handleMessageClick(RemoteMessage message) {
    if (message.data.isEmpty) return;

    final data = message.data;
    print("Notification Data: ${jsonEncode(data)}");

    final appointmentId = data['appointment_id'] ?? '';
    final customerName = data['sender_name'] ?? '';
    final type = data['type'] ?? '';
    final profileImage = data['sender_profile_url'] ?? '';
    final orderId = data['appointment_id'] ?? '';

    // Always reset to BottomTabBar (only ONCE in the app lifecycle, using the globalKey)
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => BottomTabBar(key: BottomTabBar.globalKey),
      ),
      (route) => false,
    );

    // Add a post-frame callback to ensure BottomTabBar is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (type == "chat_message") {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              orderId,
              customerName,
              profileImage,
            ),
          ),
        );
      } else {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => WorkerProfilePage(
              appointmentId,
              "",
              "",
              "",
              "",
            ),
          ),
        );
      }
    });
  }

  /*static void handleMessageClick(RemoteMessage message) {
    if (message.data.isEmpty) return;
    final data = message.data;
    print("Notification Data"+jsonEncode(data));

    final appointmentId = data['appointment_id'] ?? '';
    final customerName  = data['customer_name'] ?? '';
    final type          = data['type'] ?? '';
    final profileImage  = data['profile_url'] ?? '';


    if (message.data.isNotEmpty) {
      final data = message.data;

      final appointmentId = data['appointment_id'] ?? '';
      final customerName  = data['customer_name'] ?? '';
      final type          = data['type'] ?? '';
      final profileImage  = data['profile_url'] ?? '';

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => BottomTabBar(key: BottomTabBar.globalKey), // ✅ first reset to home
        ),
            (route) => false, // clears everything (removes Splash)
      );


      if (type == "New Message") {
        Navigator.push(
          navigatorKey.currentState!.context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              data['orderId'],
              data['name'],
              data['profileUrl'],
            ),
          ),
        );
      }else{

        // Then push details screen
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => WorkerProfilePage(
              appointmentId,
              "",
              "",
              "",
            ),
          ),
        );

      }


    }




    //_navigateFromPayload(jsonEncode(data));
  }*/

  /* static void _navigateFromPayload(String payload) {
    // Convert string back to map
    final Map<String, dynamic> data = {};
    payload.replaceAll(RegExp(r'[{} ]'), '').split(',').forEach((pair) {
      final kv = pair.split(':');
      if (kv.length == 2) {
        data[kv[0]] = kv[1];
      }
    });

    final type = data['type'];
    final context = ConstantVariable.navigatorKey.currentContext; // 👈 Need global nav key

    if (context != null) {
      if (type == "service") {
        final orderId = data['orderId'];
        final date = data['date'];
        final time = data['time'];
        final amount = data['amount'];


        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerProfilePage(orderId,date,time,amount),
          ),
        );
      } else if (type == "chat") {
        final orderId = data['orderId'];
        final name = data['name'];
        final profileUrl = data['profileUrl'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(orderId,name,profileUrl),
          ),
        );
      }
    }
  }*/

  static void _navigateFromPayload(String payload) {
    if (payload.isEmpty) return;
    final Map<String, dynamic> data = jsonDecode(payload);

    final type = data['type'];
    if (navigatorKey.currentState == null) return;
    if (type == "New Message") {
      Navigator.push(
        navigatorKey.currentState!.context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            data['orderId'],
            data['name'],
            data['profileUrl'],
          ),
        ),
      );
    } else {
      Navigator.push(
        navigatorKey.currentState!.context,
        MaterialPageRoute(
          builder: (_) => WorkerProfilePage(
            data['orderId'],
            data['date'],
            data['time'],
            data['amount'],
            '',
          ),
        ),
      );
    }

/*
    static void handleMessageClick(RemoteMessage message) {
      if (message.data.isEmpty) return;

      final data = message.data;
      final type = data['type'] ?? '';

      if (navigatorKey.currentState == null) return;

      if (type == "new_booking") {
        final appointmentId = data['appointment_id'] ?? '';
        final customerName  = data['customer_name'] ?? '';
        final customerEmail = data['customer_email'] ?? '';
        final customerPhone = data['customer_phone'] ?? '';

        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => WorkerProfilePage(
              appointmentId,
              customerName,
              customerEmail,
              customerPhone,
            ),
          ),
        );
      } else {
        final orderId    = data['appointment_id'] ?? '';   // using same field for chat
        final name       = data['customer_name'] ?? '';
        final profileUrl = data['profile_url'] ?? '';      // backend should send this

        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              orderId,
              name,
              profileUrl,
            ),
          ),
        );
      }
    }*/
  }

  /*static Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'fcm_channel', // channel ID
      'FCM Notifications', // channel name
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }*/

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    // Add iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails, // Add this line
    );

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: jsonEncode(payload),
    );
  }

  /*static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: jsonEncode(payload), // 👈 safer
    );
  }*/
}
