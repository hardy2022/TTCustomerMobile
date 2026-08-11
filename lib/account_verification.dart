import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../BLOC/APIBLoC.dart';
import 'Utility/constants.dart';
import 'login.dart';


class VerifyAccount extends StatefulWidget {
  @override
  _VerifyAccountState createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount>
    with SingleTickerProviderStateMixin {
  //final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  TextEditingController newPasswordEditingController = new TextEditingController();
  TextEditingController confirmPasswordEditingController = new TextEditingController();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController otpEditingController = new TextEditingController();

  APIBloC? _bloc;
  bool otpVisible = false;
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


  void showAlertDialog1(String des) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: Text(''+des),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () async {

                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                (TrendTodayLogin(from: "main"))));
                  },
                  child:GestureDetector(
                    onTap: () {
                      // Your on-click functionality here
                      print("Text clicked");
                    /*  Navigator.push(
                          context, MaterialPageRoute(builder: (context) => (TrendTodayLogin(from: "main"))));*/
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


  Future<void> verifyOTP(
      BuildContext context,
      String otp,
      String username) async {

    print('email !! $otp');

    _bloc = APIBloC();
    try {
      final value = await _bloc?.verifyOTP(otp, username);
      setState(() {

        if(!value!){

          showAlertDialog("Validation Error.");
        }else{

          showAlertDialog1("Account verification has been successfully completed.");

        }

      /*  Navigator.push(
            context, MaterialPageRoute(builder: (context) => (TrendTodayLogin(from: "main"))));*/


      });

    } catch (e) {
      print("Error occurred during registration: $e");
    }
  }


  Future<void> sendOtp(
      BuildContext context,
      String username) async {

    print('email !! $username');

    _bloc = APIBloC();
    try {
      final value = await _bloc?.resendOtp(username);
      setState(() {

        otpVisible = true;


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

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));


    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(),
                  SizedBox(height: 10),
                  _buildHeaderText(),
                  SizedBox(height: 10),
                  _buildForm(),
                  SizedBox(height: 14),
                  /*_buildPrivacyNote(),*/
                ],
              ),
            ),
          ),
          Positioned(
            top: 20.0, // Position close button from the top
            right: 16.0, // Position close button from the right
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.black,size: 34,),
              onPressed: () {
                Navigator.of(context).pop(); // Close the screen
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return  Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),
      height: 50,
      width: 100,
      child:Image.asset(
        'assets/images/nl.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildHeaderText() {
    return FadeTransition(
        opacity: _fadeAnimation,
        child:
        Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Verification',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  color: black1,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'You will receive an OTP through SMS.',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400,
                  color:black_50,
                ),
              )
            ],
          ),
        )

    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 0),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Form(
        //key: _formKey,
          child:
          !otpVisible ?
              Column(
            children: [
              _buildTextFormField('Email', Icons.email_outlined,emailEditingController),
              SizedBox(height: 20),
              _buildVerificationButton(),

            ],
          )
              :Column(
            children: [
              _buildTextFormField('OTP', Icons.lock_outline,otpEditingController,isPassword: true),
              SizedBox(height: 20),
              _buildVerificationButton1(),
            ],
          )


      ),
    );
  }

  Widget _buildTextFormField(String label, IconData icon, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      height: 50,
      child: TextFormField(
          obscureText: isPassword,
          controller: controller,
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Color(0xFF999999),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.black,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Color(0xFFF8F8F8),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12), // Adjusted padding
          ),
          maxLines: 1, // Ensures single-line input
          keyboardType: TextInputType.text,
          validator: MultiValidator([
            RequiredValidator(errorText: "* Required"),
          ])// Prevents newline key
      ),
    );
  }



  Widget _buildVerificationButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        child: Text(
          'Get OTP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {

          sendOtp(context,emailEditingController.text);

        },
      ),
    );
  }


  Widget _buildVerificationButton1() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        child: Text(
          'Verify OTP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {

          verifyOTP(context,otpEditingController.text,emailEditingController.text);
        },
      ),
    );
  }


}
