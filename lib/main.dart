import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Utility/constants.dart';
import 'Utility/firebase_messaging.dart';
import 'home_screen.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool launchedFromNotification = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    io.HttpClient.enableTimelineLogging = true;
  }
  //await Firebase.initializeApp();

  await Firebase.initializeApp();
  FCMService.initializeFCM(); // Don't await this so it doesn't block runApp

  // Cold-start handling
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      launchedFromNotification = true;
      FCMService.handleMessageClick(message);
    }
  });

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
    // Set to transparent or same as AppBar/Scaffold color
    statusBarIconBrightness: Brightness.dark, // Brightness of icons
  ));

  runApp(MaterialApp(
    //navigatorKey: ConstantVariable.navigatorKey, // 👈 required
    navigatorKey: navigatorKey,

    debugShowCheckedModeBanner: false,
    home: TrendyServicesOnboarding(),
    theme: ThemeData(
      primarySwatch: Colors.purple,
      fontFamily: 'Poppins', // Make sure to add this font to your pubspec.yaml
    ),
  ));
}

String user_email_id = "", user_name = "", auth_token = "", refresh_token = "";

class TrendyServicesOnboarding extends StatefulWidget {
  const TrendyServicesOnboarding({super.key});

  @override
  _TrendyServicesOnboardingState createState() =>
      _TrendyServicesOnboardingState();
}

class _TrendyServicesOnboardingState extends State<TrendyServicesOnboarding> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Future sharedPreferenceData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    var userToken = sharedPreferences.getString("auth_token");
    var refreshToken = sharedPreferences.getString("refresh_token");

    if (userToken != null) {
      auth_token = userToken;
      refresh_token = refreshToken!;

      ConstantVariable.authToken = auth_token;
      ConstantVariable.refreshToken = refresh_token;

      print("authToken ${ConstantVariable.authToken!!}");
      print("refreshToken ${ConstantVariable.refreshToken!!}");

      print(auth_token);
      print(ConstantVariable.authToken);
      print(ConstantVariable.refreshToken);
    } else {}
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    sharedPreferenceData().whenComplete(() async {
      Timer(Duration(seconds: 2), () {
        if (launchedFromNotification) return;

        if (ConstantVariable.authToken != null) {
          if (ConstantVariable.authToken!.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BottomTabBar(key: BottomTabBar.globalKey)),
            );
          }
        } else {
           Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BottomTabBar(key: BottomTabBar.globalKey)),
            );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Premium Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        ),
            ),
          ),
          // Sophisticated Decorative Elements
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/images/nl_white.png',
                        height: 56, // Made smaller and removed the box
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'PREMIUM SERVICE EXPERIENCE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            fontFamily: "Poppins",
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Button
          Positioned(
            bottom: 50,
            left: 32,
            right: 32,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContinueButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => goToOnBoardingScreen(context),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EXPLORE NOW',
                  style: TextStyle(
                    color: Color(0xFFA773F7),
                    fontSize: 15,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    height: 1.2,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFFA773F7).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFA773F7),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void goToOnBoardingScreen(BuildContext context) {
  /*Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => (TrendTodayLogin(from: "main"))));*/

  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => BottomTabBar(key: BottomTabBar.globalKey)),
  );
}
