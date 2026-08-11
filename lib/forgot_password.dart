import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../BLOC/APIBLoC.dart';
import 'Utility/constants.dart';
import 'account_verification.dart';
import 'login.dart';


class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with SingleTickerProviderStateMixin {
  //final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  TextEditingController newPasswordEditingController = new TextEditingController();
  TextEditingController confirmPasswordEditingController = new TextEditingController();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController otpEditingController = new TextEditingController();

  APIBloC? _bloc;
  bool passwordVisible = false;
  bool notVerified = false;
  bool sendOTP = false;

  String token = "";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

  }

  void showAlertDialog(String des) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(''+des),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () async {

                    Navigator.pop(context);
                  },
                  child:GestureDetector(
                    onTap: () {
                      // Your on-click functionality here
                      print("Text clicked");
                      Navigator.pop(context);

                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => (VerifyAccount())));
                    },
                    child: Text(
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


  void showAlertDialog1(String des) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(''+des),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () async {

                    Navigator.pop(context);
                  },
                  child:const Text('Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ))),
            ],
          );
        });
  }


  Future<void> verifyOTP(
      BuildContext context,
      String otp,
      String username) async {

    print('email !! $otp');

    _bloc = APIBloC();
    try {
      final value = await _bloc?.verifyOTP(otp, username);
      setState(() {

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "main")));


      });

    } catch (e) {
      print("Error occurred during registration: $e");
    }
  }


  Future<void> resendOtp(
      BuildContext context,
      String otp,
      String username) async {

    print('email !! $otp');

    _bloc = APIBloC();
    try {
      final value = await _bloc?.resendOtp(username);
      setState(() {

        sendOTP = true;
        notVerified = false;

      });

    } catch (e) {
      print("Error occurred during registration: $e");
    }
  }





  Future<void> getResetPasswordToken(
      BuildContext context,
      String email) async {

    _bloc = APIBloC();
    try {
      final value = await _bloc?.getResetPasswordToken(email);
      print("value "+value.toString());
      setState(() {

        if(value!.reset_url != null){

          if((value!.reset_url)!.length > 0){

            passwordVisible = true;
            token = value!.token!;
            print("token "+token);
          }else{

            print("here in alert");
            showAlertDialog1(value!.description!);
          }
        }else{

          print("here in alert11");

          if(value!.description! == "Account is not verified" ){

            notVerified = false;
            passwordVisible = false;
            showAlertDialog(value!.description!);


          }else{

            showAlertDialog1(value!.description!);

          }

        }

        /*Navigator.push(
            context, MaterialPageRoute(builder: (context) => (TrendTodayLogin(from: "main"))));*/


      });

    } catch (e) {
      print("Error occurred during registration: $e");
    }
  }


  Future<void> updatePassword(
      BuildContext context,
      String token,
      String newPassword) async {

    print("token "+token);
    print("newPassword "+newPassword);

    _bloc = APIBloC();
    try {
      final value = await _bloc?.updatePassword(token,newPassword);
      setState(() {

        if(value == true){

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "main")));
        }



      });

    } catch (e) {
      print("Error occurred during registration: $e");
    }
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
                  
                  // Compact Forgot Password Card
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
                          
                          !notVerified 
                            ? !passwordVisible
                              ? Column(
                                  children: [
                                    _buildTextFormField('Email Address', Icons.alternate_email_outlined, emailEditingController),
                                    SizedBox(height: 20),
                                    _buildVerificationButton(),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildTextFormField('New Password', Icons.lock_outline, newPasswordEditingController, isPassword: true),
                                    SizedBox(height: 12),
                                    _buildTextFormField('Confirm Password', Icons.lock_outline, confirmPasswordEditingController, isPassword: true),
                                    SizedBox(height: 20),
                                    _buildOTPButton(),
                                  ],
                                )
                            : Column(
                                children: [
                                  _buildTextFormField('Email Address', Icons.alternate_email_outlined, emailEditingController),
                                  if (notVerified) ...[
                                    SizedBox(height: 12),
                                    _buildTextFormField('OTP Code', Icons.security_outlined, otpEditingController),
                                  ],
                                  SizedBox(height: 20),
                                  _buildVerificationButton1(),
                                ],
                              ),
                          
                          SizedBox(height: 20),
                          _buildBackToLoginLink(),
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
                  onTap: () => Navigator.of(context).pop(),
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
    String title = 'Reset password';
    String sub = 'Enter your email to receive reset instructions';
    
    if (!notVerified) {
      if (passwordVisible) {
        title = 'Create new password';
        sub = 'Enter your new secure password';
      } else {
        title = 'Reset password';
        sub = 'Enter your email to receive reset instructions';
      }
    } else {
      title = 'Verify account';
      sub = 'Enter the verification code';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
              sub,
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

  Widget _buildTextFormField(String label, IconData icon, TextEditingController controller,
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
          onTap: () {
            if(newPasswordEditingController.text == confirmPasswordEditingController.text){
              updatePassword(context, token, newPasswordEditingController.text);
            } else {
              showAlertDialog1("Passwords do not match.");
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              'Reset password',
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

  Widget _buildVerificationButton() {
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
          onTap: () => getResetPasswordToken(context, emailEditingController.text),
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              'Send reset link',
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

  Widget _buildVerificationButton1() {
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
          onTap: () {
            if(sendOTP) {
              verifyOTP(context, emailEditingController.text, otpEditingController.text);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              sendOTP ? 'Send OTP' : 'Verify code',
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

  Widget _buildBackToLoginLink() {
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
              text: 'Remember your password? ',
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
                ..onTap = () => Navigator.of(context).pop(),
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
