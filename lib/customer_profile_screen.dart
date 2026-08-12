import '../POJO/profile_input_data.dart';
import '../Utility/SkeletonLoader.dart';
import '../Utility/date_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'BLOC/APIBloC.dart';
import 'POJO/customer_profile_response.dart';
import 'Utility/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Utility/permission_helper.dart';
import 'Utility/service_error_widget.dart';
import 'login.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'home_screen.dart';

// Tailwind-inspired orange color palette
class TailwindOrange {
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color orange800 = Color(0xFF9A3412);
  static const Color orange900 = Color(0xFF7C2D12);
}

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({Key? key}) : super(key: key);

  @override
  _CustomerProfilePageState createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  //late CustomerProfile profile;
  APIBloC? _bloc;
  String? name;
  String? image;
  String? address;
  String? email;
  String address1 = "";
  String address2 = "";
  String city = "";

  String? phone;
  String? startDate = "2024-04-08 06:43:34.236204";
  String? loyalityPoints;
  bool _isLoading = false;
  bool _hasServiceError = false;
  late CustomerProfileResponse customerProfileResponse;
  late SharedPreferences prefs;
  /*@override
  Future<void> initState() async {
    super.initState();
    _bloc = APIBloC();
    prefs = await SharedPreferences.getInstance();


    PermissionHelper.requestGalleryPermission();

    if (ConstantVariable.authToken!.length > 0) {
      _isLoading = true;
      getUserProfile(context);
    }
    // profile = widget.profile; // Initialize profile with the passed profile
  }*/

  @override
  void initState() {
    super.initState();
    _bloc = APIBloC();

    _initialize(); // Call async logic separately

    PermissionHelper.requestGalleryPermission(context);

    if (ConstantVariable.authToken != null &&
        ConstantVariable.authToken!.isNotEmpty) {
      _isLoading = true;
      getUserProfile(context);
    }
  }

  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> getUserProfile(BuildContext context) async {
    // Initialize the bloc

    try {
      // Perform the async registration work
      final value = await _bloc?.getCustomerProfileData();

      if (value != null && value.message == null) {
        print("here 1");

        setState(() {
          print("here 12");

          //print("Size of _allItems: " + _allItems.length.toString());
          _isLoading = false;
          _hasServiceError = false;

          customerProfileResponse = value!;
          ConstantVariable.userProfileImage = value?.user!.profile_image!;
          ConstantVariable.userName =
              (value?.user!.first_name)! + " " + (value?.user!.last_name)!;
          name = (value?.user!.first_name)! + " " + (value?.user!.last_name)! ??
              ''; // Sets to an empty string if username is null
          image = value?.user!.profile_image ??
              ''; // Sets to an empty string if username is null
          startDate = value?.user!.created ??
              ''; // Sets to an empty string if username is null
          address = value?.user!.location ??
              ''; // Sets to an empty string if username is null
          phone = value?.user!.mobile_no ??
              ''; // Sets to an empty string if username is null
          email = value?.user!.username ??
              ''; // Sets to an empty string if username is null
          address1 = value?.address1 ??
              ''; // Sets to an empty string if username is null
          address2 = value?.address2 ??
              ''; // Sets to an empty string if username is null
          city = value?.user!.location ??
              ''; // Sets to an empty string if username is null

          print("name " + name!);
          print("image " + image!);
          print("startDate " + startDate!);
          print("address " + address!);
          print("phone " + phone!);
          print("email " + email!);
        });
      } else if (value == null) {
        // Service/Network error
        setState(() {
          _isLoading = false;
          _hasServiceError = true;
        });
      } else {
        print("here 2");
        setState(() {
          print("here 3");

          _isLoading = false;

          // showAlertDialog();
          getToken(context);
        });
      }
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle service/network errors
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasServiceError = true;
      });
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    // Initialize the bloc
    //_bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.deleteAccount();
      print("here 0 " + value!.message!);
      if (value!.message != null) {
        if (value!.message == "Forbidden") {
          print("here 2");
          setState(() {
            print("here 3");

            _isLoading = false;

            showAlertDialog1(value!.description);
          });
        } else {
          print("here 1 " + value!.message!);

          setState(() async {
            print("here 12");

            showAlertDialog2();
            _isLoading = false;
          });
        }
      } else {}
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  Future<void> getToken(BuildContext context) async {
    // Initialize the bloc
    try {
      // Perform the async registration work
      final value = await _bloc?.getNewToken(
          ConstantVariable.authToken!, ConstantVariable.refreshToken!);

      if (value!.message != null) {
        print("here 1");

        if (value!.message == "Unauthorized") {
          showAlertDialog();
        } else {}
      } else {
        print("here 2");
        setState(() {
          print("here in nrw token " + value.access_token!);
          print("here in nrw token " + value.refresh_token!);

          _isLoading = false;
          ConstantVariable.authToken = value.access_token;
          ConstantVariable.refreshToken = value.refresh_token;

          prefs.setString("auth_token", ConstantVariable.authToken!);
          prefs.setString("refresh_token", ConstantVariable.refreshToken!);

          print("new access Token " + ConstantVariable.authToken!);
          print("new refresh Token " + ConstantVariable.refreshToken!);

          getUserProfile(context);
        });
      }
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

    void showAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_clock_rounded, color: Color(0xFFA773F7), size: 48),
                SizedBox(height: 16),
                Text(
                  'Session Expired',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Your session has expired or is invalid. Please log in again to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA773F7),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "session_expired")),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAlertDialog1(String? msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content: Text('' + msg!),
            actions: [
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                    //_navigateAndGetResult(context);
                  },
                  child: const Text('Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ))),
            ],
          );
        });
  }

  void showAlertDialog2() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content: const Text('Account deleted successfully.'),
            actions: [
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();

                    //_navigateAndGetResult(context);

                    SharedPreferences prefs1 =
                        await SharedPreferences.getInstance();
                    await prefs1.clear();
                    ConstantVariable.userProfileImage = "";
                    ConstantVariable.userName = "";
                    ConstantVariable.authToken = "";
                    Navigator.pop(context);
                    _navigateAndGetResult(context);
                  },
                  child: const Text('Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ))),
            ],
          );
        });
  }

  void showAlertDialog3() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content:
                const Text('Are you sure you want to delete your account?'),
            actions: [
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: theme_color1),
                  onPressed: () async {
                    deleteAccount(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ))),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Color(0xFFFAFAFA),
          body: Stack(
            children: [
              // Main content
              _isLoading
              ? _buildSkeletonLoader()
              : _hasServiceError
                  ? SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Section
                            Container(
                              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFA773F7),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'My Profile',
                                              style: TextStyle(
                                                color: Color(0xFF1F2937),
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: "Poppins",
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Padding(
                                          padding: EdgeInsets.only(left: 14),
                                          child: Text(
                                            'Manage your account and preferences',
                                            style: TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: "Poppins",
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40),
                            // Error Widget
                            ServiceErrorWidget(
                              onRetry: () {
                                setState(() {
                                  _hasServiceError = false;
                                  _isLoading = true;
                                });
                                getUserProfile(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: SafeArea(
                  child: (ConstantVariable.authToken!.length > 0)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Modern Header Section
                            Container(
                              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFA773F7),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'My Profile',
                                              style: TextStyle(
                                                color: Color(0xFF1F2937),
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: "Poppins",
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Padding(
                                          padding: EdgeInsets.only(left: 14),
                                          child: Text(
                                            'Manage your account and preferences',
                                            style: TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: "Poppins",
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildProfileHeader(),
                                  SizedBox(height: 20),
                            _buildSection('Contact Information', [
                                    _buildInfoTile(Icons.email_rounded, email ?? " "),
                                    _buildInfoTile(Icons.phone_rounded, phone ?? " "),
                            ]),
                                  SizedBox(height: 12),
                            _buildSection('Address', [
                                    _buildInfoTile(Icons.home_rounded,
                                  "${address1 ?? ""} ${address2 ?? ""} ${city ?? ""}"),
                            ]),
                                  SizedBox(height: 24),
                            Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                          child: _buildActionButton(
                                            'Logout',
                                            Icons.logout_rounded,
                                            Color(0xFFA773F7), // Purple
                                            Colors.white,
                                            () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          await prefs.clear();
                                          ConstantVariable.userProfileImage =
                                              "";
                                          ConstantVariable.userName = "";
                                          ConstantVariable.authToken = "";
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomTabBar()),
                                            (route) => false,
                                          );
                                        },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                          child: _buildActionButton(
                                            'Delete Account',
                                            Icons.delete_outline_rounded,
                                            Colors.black, // Black
                                            Colors.white,
                                            () {
                                          showAlertDialog3();
                                        },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                                  SizedBox(height: 24),
                          ],
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: Container(
  margin: EdgeInsets.symmetric(horizontal: 24),
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.lock_person_rounded, color: Color(0xFFA773F7), size: 56),
      SizedBox(height: 16),
      Text(
        'Please Login',
        style: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: "Poppins",
        ),
      ),
      SizedBox(height: 12),
      Text(
        'To view the details please login into your account.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
          fontFamily: "Poppins",
        ),
      ),
      SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFA773F7),
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "login")),
              (route) => false,
            );
          },
          child: const Text('Login',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: "Poppins",
              )),
        ),
      ),
    ],
  ),
),
                          ),
                        ),
                      ),
                    ),
            ],
                ),
        ));
  }

  Future<void> _navigateAndGetResult(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "main")),
      (route) => false,
    );

    // No need to handle result since we'll navigate directly from login screen
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile image with gradient border
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer gradient ring
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFA773F7),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF97316).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              // White ring
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              // Profile image
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: ConstantVariable.userProfileImage != null &&
                      ConstantVariable.userProfileImage!.length > 0
                      ? NetworkImage(ConstantVariable.userProfileImage!)
                      : AssetImage('assets/images/nl.png') as ImageProvider,
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          // Name and Customer since
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name with enhanced typography
                Text(
                  '${name}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Poppins",
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.8,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                // Customer since badge with compact design
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFF97316).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Customer since',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                          color: Colors.white.withOpacity(0.95),
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        DateConverter.convertDateFormat3(startDate!),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins",
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Edit button with compact design
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                          customerProfileResponse: customerProfileResponse),
                    ),
                  );
                  if (result != null) {
                    getUserProfile(context);
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFFA773F7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
              title,
              style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Poppins",
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.4,
            ),
          ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          ...children.map((child) => Column(
                children: [
                  child,
                  if (children.indexOf(child) < children.length - 1)
                    Divider(height: 1, thickness: 1, color: Colors.grey[200], indent: 74),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFF97316).withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              text.isEmpty ? "Not provided" : text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
                color: Color(0xFF4B5563),
                letterSpacing: -0.2,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: textColor,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Poppins",
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildServiceHistoryTile(String service) {
    final parts = service.split(' - ');
    final serviceDescription = parts[0];
    final serviceDate = parts[1];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.home_repair_service, color: TailwindOrange.orange600),
          SizedBox(width: 16),
          Expanded(
            child: Text(serviceDescription,
                style: TextStyle(color: TailwindOrange.orange900)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TailwindOrange.orange600,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              serviceDate,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Stack(
      children: [
        // Orange gradient background with pattern
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFAFAFA),
          ),
          child: CustomPaint(
            size: Size.infinite,
            // painter: _HomePatternPainter(),
          ),
        ),
        // Circular loader centered on screen
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated circular progress indicator
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    // Inner gradient circle
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Loading text
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final CustomerProfileResponse customerProfileResponse;

  const EditProfilePage({Key? key, required this.customerProfileResponse})
      : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;

  APIBloC? _bloc;
  String? name;
  String? image;
  String? address;
  String? address1;
  String? address2;

  String? email;
  String? phone;
  String? startDate = "2024-04-08 06:43:34.236204";
  String? loyalityPoints;
  bool _isLoading = false;
  late CustomerProfileResponse customerProfileResponse;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
        text: widget.customerProfileResponse.user!.first_name);
    _lastNameController = TextEditingController(
        text: widget.customerProfileResponse.user!.last_name);
    _emailController = TextEditingController(
        text: widget.customerProfileResponse.user!.username!);
    _phoneController = TextEditingController(
        text: widget.customerProfileResponse.user!.mobile_no);
    _streetController =
        TextEditingController(text: widget.customerProfileResponse.address1);
    _cityController =
        TextEditingController(text: widget.customerProfileResponse.address2);
    _stateController = TextEditingController(
        text: widget.customerProfileResponse.user!.location);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
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
                SafeArea(
                  child: Column(
                    children: [
                      // Modern Header Section
                      Container(
                        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white,
                                              Colors.white.withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'My Profile',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: "Poppins",
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Padding(
                                    padding: EdgeInsets.only(left: 14),
                                    child: Text(
                                      'Manage your account and preferences',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Poppins",
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(left: 20, right: 20, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Personal Information Card
                              Container(
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: Offset(0, 4),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section header
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
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
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Personal Information',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "Poppins",
                                            color: Colors.white,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    _buildTextField(_firstNameController, 'First Name', Icons.person_outline_rounded),
                                    SizedBox(height: 16),
                                    _buildTextField(_lastNameController, 'Last Name', Icons.person_outline_rounded),
                                    SizedBox(height: 16),
                                    _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                                    SizedBox(height: 16),
                                    _buildTextField(_phoneController, 'Phone', Icons.phone_outlined, keyboardType: TextInputType.phone),
                                  ],
                                ),
                              ),
                              // Address Card
                              Container(
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: Offset(0, 4),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section header
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
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
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Address',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "Poppins",
                                            color: Colors.white,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    _buildTextField(_streetController, 'Address Line 1', Icons.home_outlined),
                                    SizedBox(height: 16),
                                    _buildTextField(_cityController, 'Address Line 2', Icons.location_city_outlined),
                                    SizedBox(height: 16),
                                    _buildTextField(_stateController, 'City / Location', Icons.place_outlined),
                                  ],
                                ),
                              ),
                              // Save Button
                              Container(
                                margin: EdgeInsets.only(bottom: 24),
                                height: 56,
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
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFF97316).withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: Offset(0, 8),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Color(0xFFF97316).withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isLoading ? null : _saveChanges,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_outline_rounded,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Save Changes',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: "Poppins",
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: "Poppins",
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
            color: Colors.white70,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
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
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFF97316).withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: false,
        ),
      ),
    );
  }

  void _saveChanges() {
    setState(() {
      _isLoading = true;
    });

    // Here you would typically update the profile in your database
    // For this example, we'll just print the updated values
    print('Updated Profile:');
    print('Name: ${_firstNameController.text} ${_lastNameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
    print(
        'Address: ${_streetController.text}, ${_cityController.text}, ${_stateController.text}');

    // Navigate back to the profile page

    ProfileInputData profileInputData = ProfileInputData();

    profileInputData.location = _stateController.text;
    profileInputData.address1 = _streetController.text;
    profileInputData.address2 = _cityController.text;
    profileInputData.email_id = _emailController.text;
    profileInputData.first_name = _firstNameController.text;
    profileInputData.last_name = _lastNameController.text;
    profileInputData.mobile_no = _phoneController.text;
    profileInputData.profile_image =
        widget.customerProfileResponse.user!.profile_image!;

    updateUserProfile(context, profileInputData);
  }

  Future<void> updateUserProfile(
      BuildContext context, ProfileInputData profileInputData) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.updateCustomerProfileData(profileInputData);

      if (value!.message == null) {
        print("here 1");

        setState(() {
          print("here 12 " + value.toString());

          //print("Size of _allItems: " + _allItems.length.toString());
          _isLoading = false;

          customerProfileResponse = value!;
          ConstantVariable.userProfileImage = value?.user!.profile_image!;
          ConstantVariable.userName =
              (value?.user!.first_name)! + " " + (value?.user!.last_name)!;
          name = (value?.user!.first_name)! + " " + (value?.user!.last_name)! ??
              ''; // Sets to an empty string if username is null
          image = value?.user!.profile_image ??
              ''; // Sets to an empty string if username is null
          startDate = value?.user!.created ??
              ''; // Sets to an empty string if username is null
          address = value?.user!.location ??
              ''; // Sets to an empty string if username is null
          phone = value?.user!.mobile_no ??
              ''; // Sets to an empty string if username is null
          email = value?.user!.username ??
              ''; // Sets to an empty string if username is null

          print("name " + name!);
          print("image " + image!);
          print("startDate " + startDate!);
          print("address " + address!);
          print("phone " + phone!);
          print("email " + email!);

          Navigator.pop(context, "updated");
        });
      } else {
        print("here 2");
        setState(() {
          print("here 3");

          _isLoading = false;

          showAlertDialog();
        });
      }
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

    void showAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_clock_rounded, color: Color(0xFFA773F7), size: 48),
                SizedBox(height: 16),
                Text(
                  'Session Expired',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Your session has expired or is invalid. Please log in again to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA773F7),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "session_expired")),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });
}

class CustomerProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final Address address;
  final List<String> serviceHistory;
  final DateTime registrationDate;
  final double loyalty_points;

  CustomerProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.serviceHistory = const [],
    required this.registrationDate,
    this.loyalty_points = 0,
  });
}

// Sample data
final CustomerProfile sampleProfile = CustomerProfile(
  id: '12345',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john.doe@example.com',
  phoneNumber: '(555) 123-4567',
  address: Address(
    street: '123 Main St',
    city: 'Anytown',
    state: 'ST',
    zipCode: '12345',
  ),
  serviceHistory: [
    'Plumbing repair - 05/15/2023',
    'HVAC maintenance - 03/10/2023'
  ],
  registrationDate: DateTime(2022, 1, 1),
  loyalty_points: 150,
);

// Add the Shimmer widget class
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const Shimmer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  _ShimmerState createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
        colors: [
          widget.baseColor,
          widget.highlightColor,
          widget.baseColor,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: const Alignment(-1.0, -0.3),
        end: const Alignment(1.0, 0.3),
        transform: _SlidingGradientTransform(
          slidePercent: _animation.value,
        ),
      );

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    Key? key,
    required this.child,
    required this.isLoading,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

// Pattern painter for background
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
