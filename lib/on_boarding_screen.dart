import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent, // Set to transparent or same as AppBar/Scaffold color
    statusBarIconBrightness: Brightness.dark, // Brightness of icons
  ));


  runApp(
      MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TrendyServicesOnboarding(),
    theme: ThemeData(
      primarySwatch: Colors.purple,
      fontFamily: 'Poppins', // Make sure to add this font to your pubspec.yaml
    ),
  ));
}

class TrendyServicesOnboarding extends StatelessWidget {
  const TrendyServicesOnboarding({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF7C6EEF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A trendy way to get\nyour services',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: "poppins",
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Risus amet at sit sed enim leo, vitae faucibus. A orci euismod erat enim scelerisque.',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "poppins",
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Elit non massa sociis quis tellus quis. Adipiscing etiam elementum euismod mattis viverra amet, facilisis elementum amet.',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "poppins",
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Spacer(),
                      Center(
                        child: Image.asset(
                          'assets/images/onboarding_image.png',
                          height: MediaQuery.of(context).size.width*0.3,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(40.0),
              child: _buildContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8A7FF0), Color(0xFF5A4FD0)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Handle continue action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: "poppins",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
