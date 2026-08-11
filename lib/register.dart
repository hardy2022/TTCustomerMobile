import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../BLOC/APIBLoC.dart';
import 'Utility/constants.dart';
import 'login.dart';
import 'privacy_policy_screen.dart';

class TrendTodaySignup extends StatefulWidget {
  @override
  _TrendTodaySignupState createState() => _TrendTodaySignupState();
}

class _TrendTodaySignupState extends State<TrendTodaySignup>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  TextEditingController firstNameEditingController = TextEditingController();
  TextEditingController lastNameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController mobileEditingController = TextEditingController();
  TextEditingController otpEditingController = TextEditingController();

  APIBloC? _bloc;
  bool otpVisible = false;
  bool _isRegistering = false;
  bool _isVerifyingOtp = false;


  static const List<String> validCountryCodes = [
    '+1',    // USA, Canada, and other NANP countries
    '+20',   // Egypt
    '+211',  // South Sudan
    '+212',  // Morocco
    '+213',  // Algeria
    '+216',  // Tunisia
    '+218',  // Libya
    '+220',  // Gambia
    '+221',  // Senegal
    '+222',  // Mauritania
    '+223',  // Mali
    '+224',  // Guinea
    '+225',  // Côte d'Ivoire
    '+226',  // Burkina Faso
    '+227',  // Niger
    '+228',  // Togo
    '+229',  // Benin
    '+230',  // Mauritius
    '+231',  // Liberia
    '+232',  // Sierra Leone
    '+233',  // Ghana
    '+234',  // Nigeria
    '+235',  // Chad
    '+236',  // Central African Republic
    '+237',  // Cameroon
    '+238',  // Cape Verde
    '+239',  // São Tomé and Príncipe
    '+240',  // Equatorial Guinea
    '+241',  // Gabon
    '+242',  // Republic of the Congo
    '+243',  // Democratic Republic of the Congo
    '+244',  // Angola
    '+245',  // Guinea-Bissau
    '+246',  // British Indian Ocean Territory
    '+248',  // Seychelles
    '+249',  // Sudan
    '+250',  // Rwanda
    '+251',  // Ethiopia
    '+252',  // Somalia
    '+253',  // Djibouti
    '+254',  // Kenya
    '+255',  // Tanzania
    '+256',  // Uganda
    '+257',  // Burundi
    '+258',  // Mozambique
    '+260',  // Zambia
    '+261',  // Madagascar
    '+262',  // Réunion and Mayotte
    '+263',  // Zimbabwe
    '+264',  // Namibia
    '+265',  // Malawi
    '+266',  // Lesotho
    '+267',  // Botswana
    '+268',  // Eswatini (Swaziland)
    '+269',  // Comoros
    '+27',   // South Africa
    '+30',   // Greece
    '+31',   // Netherlands
    '+32',   // Belgium
    '+33',   // France
    '+34',   // Spain
    '+36',   // Hungary
    '+39',   // Italy
    '+40',   // Romania
    '+41',   // Switzerland
    '+43',   // Austria
    '+44',   // United Kingdom
    '+45',   // Denmark
    '+46',   // Sweden
    '+47',   // Norway
    '+48',   // Poland
    '+49',   // Germany
    '+52',   // Mexico
    '+55',   // Brazil
    '+61',   // Australia
    '+64',   // New Zealand
    '+81',   // Japan
    '+82',   // South Korea
    '+86',   // China
    '+91',   // India
    '+92',   // Pakistan
    '+94',   // Sri Lanka
    '+98',   // Iran
    '+212',  // Morocco
    '+213',  // Algeria
    '+234',  // Nigeria
  ];



  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  Future<void> register(
      BuildContext context,
      String entity_id,
      String first_name,
      String last_name,
      String username,
      String pssword,
      String mobile,
      ) async {
    setState(() {
      _isRegistering = true;
    });

    _bloc = APIBloC();
    try {
      final value = await _bloc?.register(
          entity_id, first_name, last_name, username, pssword, mobile);
      if (value?.created != null) {
        setState(() {
          otpVisible = true;
          _isRegistering = false;
        });
      } else {
        setState(() {
          _isRegistering = false;
        });
        showAlertDialog(value?.description ?? "Registration failed");
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      showAlertDialog("Error: $e");
    }
  }

  Future<void> verifyOTP(
      BuildContext context,
      String otp,
      String username,
      ) async {
    setState(() {
      _isVerifyingOtp = true;
    });

    _bloc = APIBloC();
    try {
      final value = await _bloc?.verifyOTP(otp, username);
      setState(() {
        _isVerifyingOtp = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => TrendTodayLogin(from: "main")));
    } catch (e) {
      setState(() {
        _isVerifyingOtp = false;
      });
      showAlertDialog("Error verifying OTP: $e");
    }
  }

  void showAlertDialog(String des) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(des),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14))),
            ],
          );
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                  
                  // Compact Register Card
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
                          SizedBox(height: 20),
                          
                          if (!otpVisible) ...[
                            _buildTextFormField('First Name', Icons.person_outline, firstNameEditingController),
                            SizedBox(height: 12),
                            _buildTextFormField('Last Name', Icons.person_outline, lastNameEditingController),
                            SizedBox(height: 12),
                            _buildTextFormField('Email Address', Icons.alternate_email_outlined, emailEditingController),
                            SizedBox(height: 12),
                            _buildTextFormField('Password', Icons.lock_outline, passwordEditingController, isPassword: true),
                            SizedBox(height: 12),
                            _buildTextFormField('Mobile Phone', Icons.phone_outlined, mobileEditingController),
                            SizedBox(height: 20),
                            _buildRegisterButton(),
                            SizedBox(height: 16),
                            _buildPrivacyNote(),
                          ] else ...[
                            _buildTextFormField('Security OTP', Icons.security_outlined, otpEditingController),
                            SizedBox(height: 20),
                            _buildOTPButton(),
                          ],
                          
                          SizedBox(height: 20),
                          _buildLoginLink(),
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

          // Distinct Back Button
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 16,
            left: 20,
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
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded, 
                    color: Color(0xFF111827), 
                    size: 20
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
          otpVisible ? 'Verify your account' : 'Create account',
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
          otpVisible ? 'Enter the code sent to your email' : 'Sign up to get started',
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
      TextEditingController controller,
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
        validator: MultiValidator([
          RequiredValidator(errorText: "Required"),
        ]),
      ),
    );
  }

  Widget _buildRegisterButton() {
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
          onTap: _isRegistering
              ? null
              : () {
            if (_formKey.currentState!.validate()) {
              if (hasValidCountryCode(mobileEditingController.text)) {
                register(
                    context,
                    "Customer",
                    firstNameEditingController.text,
                    lastNameEditingController.text,
                    emailEditingController.text,
                    passwordEditingController.text,
                    mobileEditingController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid country code.')));
              }
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: _isRegistering
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white, 
                      strokeWidth: 2
                    ),
                  )
                : Text(
                    'Continue',
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

  Widget _buildOTPButton() {
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
          onTap: _isVerifyingOtp
              ? null
              : () {
            if (_formKey.currentState!.validate()) {
              verifyOTP(context, otpEditingController.text,
                  emailEditingController.text);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: _isVerifyingOtp
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white, 
                      strokeWidth: 2
                    ),
                  )
                : Text(
                    'Verify',
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

  Widget _buildPrivacyNote() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
              color: Color(0xFF6B7280),
            fontSize: 13,
              height: 1.5,
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
          ),
          children: [
            TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Privacy Policy',
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
                    MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
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
              text: 'Already have an account? ',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: 'Sign in',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationThickness: 1.5,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "main")),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  bool hasValidCountryCode(String input) {
    return validCountryCodes.any((code) => input.startsWith(code));
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
