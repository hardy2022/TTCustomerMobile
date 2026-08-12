import 'login.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import '../login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Utility/constants.dart';
import '../cart_services_item.dart';
import '../service_item.dart';
import '../tab.dart';
import '../work_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'BLOC/APIBloC.dart';
import 'POJO/orders_response_data.dart';
import '../Utility/service_error_widget.dart';

/*void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
// Set to transparent or same as AppBar/Scaffold color
    statusBarIconBrightness: Brightness.dark, // Brightness of icons
  ));
  runApp(CartServices());
}*/

class CartServices extends StatefulWidget {
  @override
  _CartServicesPageState createState() => _CartServicesPageState();
}

class _CartServicesPageState extends State<CartServices> {
  final Color _segmentedControlColor = segmented_bg;
  ScrollController _scrollController = ScrollController();
  APIBloC? _bloc;
  List<OrdersResponseData>? _ordersList = [];
  bool _isLoading = false;
  bool _isVisible = false;
  bool _hasServiceError = false;
  double totalAmount = 0.0;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initialize();
    if (ConstantVariable.authToken!.length > 0) {
      _isLoading = true;

      getOrder(context);
    }
  }
  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();
  }


  Future<void> getOrder(BuildContext context) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.getOrder();

      if (value != null && value.isNotEmpty) {
        print("Services Response: " + (value?.toString() ?? "null"));
        _isLoading = false;

        // Now update the UI state synchronously
        setState(() {
          _isLoading = false;
          _hasServiceError = false;
          _ordersList = [];
          _ordersList = value;

          if (_ordersList!.isNotEmpty) {
            _isVisible = true;
          } else {
            _isVisible = false;
          }
          totalAmount = 0.0;
          for (int i = 0; i < _ordersList!.length; i++) {
            totalAmount = totalAmount + (_ordersList![i].order_amount ?? 0);
          }
          print("_ordersList: " + (_ordersList?.toString() ?? "null"));
          print("_ordersList: " + _ordersList!.length.toString());
          print("totalAmount: " + totalAmount!.toString());
          print("_ordersList: " + jsonEncode(_ordersList));
        });
      } else if (value == null || value.isEmpty) {
        // Service/Network error - show error widget
        setState(() {
          _isLoading = false;
          _hasServiceError = true;
          _ordersList = [];
          _isVisible = false;
          totalAmount = 0.0;
        });
      } else {
        //showAlertDialog();


        getToken(context);



      }
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle service/network errors
      setState(() {
        _isLoading = false;
        _hasServiceError = true;
        _ordersList = [];
        _isVisible = false;
        totalAmount = 0.0;
      });
    }
  }


  Future<void> getToken(BuildContext context) async {
    // Initialize the bloc
    try {
      // Perform the async registration work

      print("ConstantVariable.authToken "+ConstantVariable.authToken!);
      print("ConstantVariable.refreshToken "+ConstantVariable.refreshToken!);

      final value = await _bloc?.getNewToken(ConstantVariable.authToken!,ConstantVariable.refreshToken!);

      if (value!.message == null) {



        setState(() {
          print("here in nrw token "+value.access_token!);
          print("here in nrw token "+value.refresh_token!);

          _isLoading = false;
          ConstantVariable.authToken = value.access_token;
          ConstantVariable.refreshToken = value.refresh_token;

          prefs.setString("auth_token", ConstantVariable.authToken!);
          prefs.setString("refresh_token", ConstantVariable.refreshToken!);

          print("new access Token "+ConstantVariable.authToken!);
          print("new refresh Token "+ConstantVariable.refreshToken!);


          getOrder(context);
        });


        print("here 22222222");


      } else {
        print("here 2");
        setState(() {
          print("here 3");

          _isLoading = false;

          if(value.message == "Unauthorized"){

            print("Unauthorized1111111 ");
            showAlertDialog();
            //getToken(context);

          }else{ }


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

  @override
  Widget build(BuildContext context) {
    /* SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));*/

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        // Make sure the background color contrasts with the status bar icons
        body: _isLoading
            ? Stack(
                children: [
                  // Orange gradient background with pattern
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
                    child: CustomPaint(
                      size: Size.infinite,
                      // painter: _BookingsPatternPainter(),
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
              )
            : Container(
                child: (ConstantVariable.authToken!.length > 0)
                    ? Container(
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
                              // painter: _BookingsPatternPainter(),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildHeader(),
                                    _hasServiceError
                                        ? ServiceErrorWidget(
                                            onRetry: () {
                                              setState(() {
                                                _hasServiceError = false;
                                                _isLoading = true;
                                              });
                                              getOrder(context);
                                            },
                                          )
                                        : _buildSelectService(),
                                    _ordersList!.isNotEmpty
                                              ? Container()
                                        : Container()
                                  ],
                                ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
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
                        child: Center(
                        child: Container(
  margin: EdgeInsets.symmetric(horizontal: 24),
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Color(0xFF1E1E1E),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
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
          color: Colors.white,
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
                      ))),
      ),
    );
  }

  Future<void> _navigateAndGetResult(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "cart")),
    );

    if (result == "result") {
      print("Returned result: $result");
      getOrder(context);
    }
    // Use the returned result here
    // Perform any actions with the result
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),
      padding: EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Color(0xFF746EE0),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white),
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 24),
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
                'My Bookings',
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
              'Manage and track your service requests',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
                letterSpacing: 0.1,
              ),
            ),
          ),
          if (_ordersList!.isNotEmpty) ...[
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'CAD',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            totalAmount.toStringAsFixed(2),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 14),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectService() {
    return _ordersList != null && _ordersList!.length > 0
        ? Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: _ordersList!.length!,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          print('Item tapped: $index');
                          print('Item tapped');
                          setState(() async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkerProfilePage(
                                  _ordersList![index].id.toString()!,
                                  _ordersList![index].date,
                                  _ordersList![index].time,
                                  _ordersList![index].order_amount.toString(),
                                  (_ordersList![index].business_name?.trim().isNotEmpty == true)
                                      ? _ordersList![index].business_name!.trim()
                                      : (_ordersList![index].professional_name?.trim().isNotEmpty == true)
                                          ? _ordersList![index].professional_name!.trim()
                                          : (_ordersList![index].vendor?.trim().isNotEmpty == true)
                                              ? _ordersList![index].vendor!.trim()
                                              : '',
                                ),
                              ),
                            );
                            // Handle the result
                            if (result != null) {
                              print('Result from WorkerProfilePage: $result');
                              getOrder(context);
                            }
                          });
                        },
                        child: CartServicesItem(
                          image: _ordersList![index].image,
                          name: (_ordersList![index].business_name?.trim().isNotEmpty == true)
                              ? _ordersList![index].business_name!.trim()
                              : (_ordersList![index].professional_name?.trim().isNotEmpty == true)
                                  ? _ordersList![index].professional_name!.trim()
                                  : (_ordersList![index].vendor?.trim().isNotEmpty == true)
                                      ? _ordersList![index].vendor!.trim()
                                      : '',
                          amount: _ordersList![index].order_amount.toString(),
                          duration: _ordersList![index].duration,
                          date: _ordersList![index].date,
                          time: _ordersList![index].time,
                          services: _ordersList![index].services,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ))
        : Container(
            padding: const EdgeInsets.only(
                top: 80.0, left: 20.0, right: 20, bottom: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                  size: 64,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'No Bookings Yet',
                    style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Poppins",
                    color: Colors.white,
                    letterSpacing: -0.8,
                    ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Once you book a service, it will appear here for easy tracking and management.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
  }

  Widget _buildBookingButton() {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: () {
            //makePayment();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            'Pay Now \$${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              color: bg,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class CartItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.white.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              SizedBox(width: 16),
              // Info section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title line
                    Container(
                      width: 140,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Tag lines
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(width: 6),
                    Container(
                          width: 50,
                          height: 20,
                      decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                      ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Price line
                    Container(
                      width: 80,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              // Date and Time section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                    width: 70,
                    height: 28,
                        decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                        ),
                  ),
                  SizedBox(height: 8),
                      Container(
                    width: 80,
                    height: 28,
                        decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartHeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.white.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 24.0, bottom: 20.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            children: [
              Container(
                  width: 4,
                  height: 24,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
              Container(
                width: 180,
                  height: 28,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              margin: EdgeInsets.only(left: 16),
              width: 250,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            SizedBox(height: 20),
                  Container(
              margin: EdgeInsets.only(left: 16),
              height: 70,
                    decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

class _BookingsPatternPainter extends CustomPainter {
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
