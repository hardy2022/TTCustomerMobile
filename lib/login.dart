import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utility/constants.dart';
import '../register.dart';
import 'BLOC/APIBloC.dart';
import 'account_verification.dart';
import 'forgot_password.dart';
import 'home_screen.dart';
import 'main.dart';

class TrendTodayLogin extends StatefulWidget {
  final String from;

  const TrendTodayLogin({Key? key, required this.from}) : super(key: key);

  @override
  State<TrendTodayLogin> createState() => _TrendTodayLoginState();
}

class _TrendTodayLoginState extends State<TrendTodayLogin> {
  late TextEditingController emailEditingController;
  late TextEditingController passwordEditingController;
  APIBloC? _bloc;
  late String copyfrom;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    copyfrom = widget.from;

    emailEditingController = TextEditingController();
    passwordEditingController = TextEditingController();
  }

  Future<void> login(
      BuildContext context, String username, String pssword) async {
    setState(() {
      _isLoading = true;
    });

    _bloc = APIBloC();

    try {
      final value = await _bloc?.login(username, pssword);
      print("Response: ${value.toString()}");

      if (value?.access_token != null && value!.access_token!.isNotEmpty) {
        ConstantVariable.authToken = value.access_token;
        ConstantVariable.refreshToken = value.refresh_token;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("auth_token", ConstantVariable.authToken!);
        prefs.setString("refresh_token", ConstantVariable.refreshToken!);

        setState(() {
          _isLoading = false;
        });

        if (copyfrom != "main") {
          Navigator.pop(context, "result");
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => (BottomTabBar())));
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (value?.message != null) {
          if (value?.message.toString() ==
              "Account is not verified by the user.") {
            showAlertDialog1(value!.message!);
          } else {
            showAlertDialog111(value!.message!);
          }
        } else {
          showAlertDialog();
        }
      }
    } catch (e) {
      print("Error occurred during login: $e");
      setState(() {
        _isLoading = false;
      });
      showAlertDialog();
    }
  }

  void showAlertDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Credentials'),
            content: const Text('Invalid username or password.'),
            actions: [
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                    _navigateAndGetResult(context);
                  },
                  child: const Text('Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ))),
            ],
          );
        });
  }

  void showAlertDialog1(String des) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(des),
            actions: [
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () {},
                  child: GestureDetector(
                    onTap: () {
                      print("Text clicked");
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => (VerifyAccount())));
                    },
                    child: const Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  )),
            ],
          );
        });
  }

  void showAlertDialog111(String des) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text("Invalid Credentials"),
            actions: [
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () {},
                  child: GestureDetector(
                    onTap: () {
                      print("Text clicked");
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  )),
            ],
          );
        });
  }

  Future<void> _navigateAndGetResult(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "main")),
    );

    if (result == "result") {
      print("Returned result: $result");
    }
  }

  @override
  void dispose() {
    emailEditingController.dispose();
    passwordEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.32;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA), // Soft Scandinavian gray
      body: Stack(
        children: [
          // Orange Gradient Background with Pattern (from home page)
          Container(
            height: headerHeight,
            width: double.infinity,
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
            child: Stack(
              children: [
                // Stylish geometric pattern overlay
                CustomPaint(
                  size: Size.infinite,
                  // painter: _HomePatternPainter(),
                ),
                // Subtle gradient overlay for depth
                Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
                ),
              ],
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: headerHeight * 0.2),
                  
                  // Compact Login Card
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo inside white container
                          Center(
                            child: Image.asset(
                              'assets/images/nl.png',
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildWelcomeHeading(),
                          SizedBox(height: 24),
                          _buildTextFormField(
                            'Email Address', 
                            Icons.alternate_email_outlined, 
                            emailEditingController, 
                            _formKey
                          ),
                          SizedBox(height: 12),
                          _buildTextFormField(
                            'Password', 
                            Icons.lock_outline, 
                            passwordEditingController, 
                            _formKey,
                            isPassword: true
                          ),
                          SizedBox(height: 6),
                          _buildForgotPassword(),
                          SizedBox(height: 20),
                          _buildLoginButton(
                            context, 
                            emailEditingController, 
                            passwordEditingController, 
                            _formKey
                          ),
                          SizedBox(height: 20),
                          _buildRegisterSection(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildCopyrightFooter(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Distinct Close Button
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 16,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TrendyServicesOnboarding()),
                      (route) => false,
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Icon(
                    Icons.close_rounded, 
                    color: Color(0xFF111827), 
                    size: 22
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4),
            Text(
          'Sign in to continue',
              style: TextStyle(
            fontSize: 14,
                fontFamily: "Poppins",
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            height: 1.3,
            ),
        ),
      ],
    );
  }

  Widget _buildTextFormField(String label, IconData icon,
      TextEditingController controller, GlobalKey<FormState> _formKey,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFFE5E7EB), 
          width: 1,
        ),
      ),
      child: TextFormField(
        obscureText: isPassword,
        controller: controller,
        style: TextStyle(
            color: Color(0xFF111827), 
          fontSize: 14, 
            fontFamily: "Poppins", 
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Color(0xFF9CA3AF), 
              fontSize: 13, 
              fontFamily: "Poppins", 
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            icon, 
            color: Color(0xFF6B7280), 
            size: 18
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        ),
        validator: isPassword ? _passwordValidator : (value) {
          if (value == null || value.isEmpty) return 'Required';
          return null;
        },
      ),
    );
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => (ForgotPassword())));
        },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
              'Forgot password?',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
      BuildContext context,
      TextEditingController emailEditingController,
      TextEditingController passwordEditingController,
      GlobalKey<FormState> _formKey) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFF1F2937), // Deep Scandinavian gray-black
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1F2937).withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    login(context, emailEditingController.text,
                        passwordEditingController.text);
                  }
                },
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Sign in',
                        style: TextStyle(
                          color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                      letterSpacing: 0.3,
                      ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterSection() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Color(0xFF6B7280), 
            fontSize: 14, 
            fontFamily: "Poppins",
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: 'Sign up',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationThickness: 1.5,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => (TrendTodaySignup())));
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyrightFooter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Copyright 2024. TrendToday.ca. All rights reserved',
        style: TextStyle(
          fontSize: 11,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.2,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Orange pattern painter (same as home page)
class _HomePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw diagonal lines pattern
    final spacing = 40.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Draw circles pattern
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final circleSpacing = 80.0;
    for (double x = 0; x < size.width + circleSpacing; x += circleSpacing) {
      for (double y = 0; y < size.height + circleSpacing; y += circleSpacing) {
        canvas.drawCircle(
          Offset(x, y),
          20,
          circlePaint,
        );
      }
    }

    // Draw hexagon pattern
    final hexPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final hexSpacing = 100.0;
    for (double x = 0; x < size.width + hexSpacing; x += hexSpacing) {
      for (double y = 0; y < size.height + hexSpacing; y += hexSpacing) {
        _drawHexagon(canvas, Offset(x, y), 30, hexPaint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
