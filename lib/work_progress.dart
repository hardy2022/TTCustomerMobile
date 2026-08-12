// work_progress.dart
// ===== FULL UPDATED FILE =====
// Stripe success, cancel, and back button handling integrated.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../Utility/constants.dart';
import 'BLOC/APIBLoC.dart';
import 'POJO/order_stages_data_details_response.dart';
import 'chat_screen.dart';
import '../Utility/SkeletonLoader.dart';
import '../Utility/date_converter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WorkerProfilePage extends StatefulWidget {
  final String? orderId;
  final String? orderDate;
  final String? orderTime;
  final String? orderAmount;
  final String? displayName;

  WorkerProfilePage(
      this.orderId, this.orderDate, this.orderTime, this.orderAmount, this.displayName);

  @override
  State<StatefulWidget> createState() {
    return _WorkerProfilePageState(
        this.orderId!, this.orderDate, this.orderTime, this.orderAmount, this.displayName);
  }
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  // ===== Backend + deep-link config =====
  static final String _backendBaseUrl = EnvironmentConfig.baseUrl;
  static const String _deeplinkScheme = 'trendtoday';
  static const String _deeplinkHost = 'checkout';

  final Dio _dio = Dio(BaseOptions(baseUrl: _backendBaseUrl));
  StreamSubscription? _linkSub;

  // ===== Existing fields =====
  late String? copyOrderId;
  late String? copyOrderDate;
  late String? copyOrderTime;
  late String? copyOrderAmount;

  APIBloC? _bloc;
  List<OrderStagesDataDetailsResponse>? appointmentStages = [];
  ScrollController _scrollController = ScrollController();
  String? name = "";
  String? displayName = "";
  String? vendorName = "";
  String? email = "";
  String? image = "";
  String? time = "";
  String? date = "";
  Timer? _timer;
  bool _isLoading = false;
  bool isVisible = false;
  String? _paymentStatus;
  bool _isPaymentDone = false; // 👈 Track payment status
  bool _isScheduledDate = false; // 👈 Track if current date matches scheduled date

  _WorkerProfilePageState(String? orderId, String? orderDate, String? orderTime,
      String? orderAmount, String? displayName);

  final Color primaryColor = Color(0xFF586BA4);
  final Color secondaryColor = Color(0xFF324376);
  final Color gradientStart = Color(0xFF7971E8);
  final Color gradientEnd = Color(0xFF434185);

  @override
  void initState() {
    super.initState();
    copyOrderId = widget.orderId;
    copyOrderDate = widget.orderDate;
    copyOrderTime = widget.orderTime;
    copyOrderAmount = widget.orderAmount;
    displayName = widget.displayName;

    _isLoading = true;
    getAppointmentStages(context, copyOrderId);

    _initDeepLinks();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _linkSub?.cancel();
    super.dispose();
  }

  // ===== Deep link handling =====
  void _initDeepLinks() {
    // Initialize AppLinks
    final _appLinks = AppLinks(); // Instantiate here or as a class member

    // Handle the initial link (when the app is launched from a link)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleIncomingUri(uri); // Pass the Uri object
      }
    });

    // Handle links when the app is already running
    _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingUri(uri); // Pass the Uri object
    }, onError: (err) {
      // Handle errors if necessary
    });
  }

  void _handleIncomingUri(Uri uri) {
    // This signature should remain the same
    final url = uri.toString();

    if (url.contains("success_payment")) {
      _onCheckoutSuccess();
    } else if (url.contains("cancelled_payment")) {
      _onCheckoutCancel();
    }
  }

  Future<void> _openCheckout(String checkoutUrl) async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains("success_payment")) {
              Navigator.pop(context);
              _onCheckoutSuccess();
              return NavigationDecision.prevent;
            } else if (request.url.contains("cancelled_payment")) {
              Navigator.pop(context);
              _onCheckoutCancel();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(checkoutUrl));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Payment"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
                _onCheckoutCancel(); // Treat back as cancel
              },
            ),
          ),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );
  }

  // ===== Timer (poll appointment API) =====
  void _startApiCallTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getAppointmentStages(context, copyOrderId);
    });
  }

  Future<void> getAppointmentStages(
      BuildContext context, String? orderId) async {
    _bloc = APIBloC();

    try {
      final value = await _bloc?.getAppointmentStages(orderId);
      appointmentStages = value!.appointment_stages;

      setState(() {
        _isLoading = false;
        vendorName = value.vendor_name ?? '';
        name = displayName?.isNotEmpty == true ? displayName! : vendorName;
        image = value.profile_image!;
        email = value.vendor_name!;
        time = DateConverter.convertTimeFormat(value.appointment_time!);
        date = value.appointment_date; //copyOrderDate;

        // Check if current date/time matches scheduled date/time
        _isScheduledDate = _checkIfScheduledDate(date, time);

        isVisible = false;

        for (var stage in value.appointment_stages!) {
          if (stage.status == "PAYMENT_REQUEST") {
            isVisible = stage.passed == true;
          }
        }

        _isPaymentDone =
            value.appointment_stages!.every((stage) => stage.passed == true);

        _startApiCallTimer();
      });
    } catch (e) {
      print("Error occurred during getAppointmentStages: $e");
    }
  }

  // Check if current date/time matches scheduled date/time
  bool _checkIfScheduledDate(String? scheduledDate, String? scheduledTime) {
    if (scheduledDate == null || scheduledTime == null || scheduledDate.isEmpty || scheduledTime.isEmpty) {
      return false;
    }

    try {
      // Parse scheduled date (format: yyyy-MM-dd)
      DateTime scheduledDateTime = DateFormat('yyyy-MM-dd').parse(scheduledDate);
      
      // Parse scheduled time (format: HH:mm)
      List<String> timeParts = scheduledTime.split(':');
      if (timeParts.length != 2) return false;
      
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      
      scheduledDateTime = DateTime(
        scheduledDateTime.year,
        scheduledDateTime.month,
        scheduledDateTime.day,
        hour,
        minute,
      );

      // Get current date/time
      DateTime now = DateTime.now();
      DateTime currentDate = DateTime(now.year, now.month, now.day);

      // Compare dates (ignore time for date comparison)
      DateTime scheduledDateOnly = DateTime(
        scheduledDateTime.year,
        scheduledDateTime.month,
        scheduledDateTime.day,
      );

      // Check if dates match
      return currentDate.isAtSameMomentAs(scheduledDateOnly);
    } catch (e) {
      print("Error checking scheduled date: $e");
      return false;
    }
  }

  // Calculate days until scheduled date
  int _calculateDaysUntil(String? scheduledDate) {
    if (scheduledDate == null || scheduledDate.isEmpty) {
      return 0;
    }

    try {
      DateTime scheduledDateTime = DateFormat('yyyy-MM-dd').parse(scheduledDate);
      DateTime scheduledDateOnly = DateTime(
        scheduledDateTime.year,
        scheduledDateTime.month,
        scheduledDateTime.day,
      );

      DateTime now = DateTime.now();
      DateTime currentDateOnly = DateTime(now.year, now.month, now.day);

      int days = scheduledDateOnly.difference(currentDateOnly).inDays;
      // Return 0 if date is in the past (shouldn't happen, but safety check)
      return days < 0 ? 0 : days;
    } catch (e) {
      print("Error calculating days until: $e");
      return 0;
    }
  }

  Future<String> getCheckoutLink(BuildContext context, String? orderId) async {
    _bloc = APIBloC();

    try {
      final checkoutUrl = await _bloc!.getCheckoutLink(orderId!);
      print("✅ Checkout Link: $checkoutUrl");
      return checkoutUrl!;
    } catch (e) {
      print("❌ Error occurred during getCheckoutLink: $e");
      rethrow;
    }
  }

  // ===== Success/Cancel handlers =====
  void _onCheckoutSuccess() {
    if (!mounted) return;
    setState(() {
      _isPaymentDone = true; // 👈 Hide button after success
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Payment Successful')),
    );
  }

  void _onCheckoutCancel() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Payment Cancelled')),
    );
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
        backgroundColor: Colors.black,
        body: Stack(
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
              child: Stack(
                children: [
                  // Stylish geometric pattern overlay
                  CustomPaint(
                    size: Size.infinite,
                    // painter: _WorkProgressPatternPainter(),
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
            // Main content
            SafeArea(
              child: _isLoading
                  ? WorkProgressScreenSkeleton()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopRow(),
                          _buildProfileImage(),
                          _buildDateTimeInfo(),
                          _isScheduledDate ? _buildWorkProgress() : _buildScheduledDateMessage(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== UI Widgets (same as before, unchanged except payment button) =====

  Widget _buildTopRow() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                _buildBackButton(),
                SizedBox(width: 14),
                Flexible(
                  child: Row(
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
                        'Service Progress',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: "Poppins",
                          letterSpacing: -0.5,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFA773F7).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(copyOrderId!, name!, image!),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      height: 160,
      margin: EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Profile Image
          image != null && image!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: image!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Color(0xFFF3F4F6),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Color(0xFFF3F4F6),
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey.shade400,
                      size: 48,
                    ),
                  ),
                )
              : Image.asset(
                  'assets/images/login_bg.png',
                  fit: BoxFit.cover,
                ),
          // Enhanced gradient overlay with pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Decorative pattern overlay
          Positioned.fill(
            child: CustomPaint(
              // painter: _ImagePatternPainter(),
            ),
          ),
          // Top heading section
          Positioned(
            left: 20,
            right: 20,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Service Provider',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: "Poppins",
                    letterSpacing: 1.2,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your Professional',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.75),
                    fontFamily: "Poppins",
                    letterSpacing: 0.5,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Display name and vendor name overlay at bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display name (business_name or professional_name) as heading
                Text(
                  displayName?.isNotEmpty == true ? displayName! : (name ?? ''),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: "Poppins",
                    letterSpacing: -0.5,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 16,
                        offset: Offset(0, 3),
                      ),
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // Vendor name as subheading
                if (vendorName?.isNotEmpty == true && vendorName != displayName)
                  Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            vendorName ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.95),
                              fontFamily: "Poppins",
                              letterSpacing: -0.2,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInfo() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Appointment Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: "Poppins",
                  letterSpacing: -0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'Date and time details',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.85),
                fontFamily: "Poppins",
                letterSpacing: 0.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(Icons.calendar_today_rounded, 'Date', date ?? ''),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoBox(Icons.access_time_rounded, 'Time', time ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Color(0xFFA773F7),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: "Poppins",
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkProgress() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Work Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: "Poppins",
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _WorkProgressStepper(stages: appointmentStages ?? []),
          if (isVisible) ...[
            SizedBox(height: 20),
            _buildBookingButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduledDateMessage() {
    int daysUntil = _calculateDaysUntil(date);
    String daysText = daysUntil == 1 ? 'day' : 'days';
    
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Scheduled Service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: "Poppins",
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  'Your appointment is confirmed',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                    fontFamily: "Poppins",
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFF97316).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: "Poppins",
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Service scheduled',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: "Poppins",
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: "Poppins",
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(text: 'After $daysUntil $daysText'),
                            if (time != null && time!.isNotEmpty) ...[
                              TextSpan(
                                text: ' at $time',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFA773F7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    if (_isPaymentDone) return const SizedBox.shrink(); // 👈 Hide button
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Color(0xFF7C3AED),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF97316).withOpacity(0.4),
            blurRadius: 16,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0xFFF97316).withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final checkoutURL = await getCheckoutLink(context, copyOrderId);
            await _openCheckout(checkoutURL);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Pay Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
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

class _WorkProgressStepper extends StatelessWidget {
  final List<OrderStagesDataDetailsResponse> stages;
  const _WorkProgressStepper({required this.stages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        final isCompleted = stage.passed == true;
        final isLast = index == stages.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFA773F7),
            Color(0xFF8B5CF6),
          ],
        )
                          : null,
                      color: isCompleted ? null : Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? Colors.transparent
                            : Color(0xFFD1D5DB),
                        width: isCompleted ? 0 : 1.5,
                      ),
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: Color(0xFFA773F7).withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: isCompleted
                        ? Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 16,
                      margin: EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        )
                            : null,
                        color: isCompleted ? null : Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stage.status ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? Color(0xFF111827) : Color(0xFF6B7280),
                        fontSize: 14,
                        fontFamily: "Poppins",
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    if ((stage.time?.isNotEmpty ?? false)) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(width: 4),
                          Text(
                            DateConverter.convertDateFormat(stage.time!),
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WorkProgressScreenSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row skeleton
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Back button
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Name
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 100,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                // Chat button
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 60,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Profile image/banner skeleton
          Container(
            height: 250,
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Date/time info boxes skeleton
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),
            child: Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Work progress section skeleton
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Stepper skeleton (3 steps)
                Column(
                  children: List.generate(
                      3,
                      (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dot and line
                                Column(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    if (index < 2)
                                      Container(
                                        width: 2,
                                        height: 18,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
                                SizedBox(width: 14),
                                // Stage info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 100,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 60,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                ),
                SizedBox(height: 16),
                // Approve button skeleton
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for stylish geometric pattern on work progress screen
class _WorkProgressPatternPainter extends CustomPainter {
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

// Custom painter for decorative pattern on image
class _ImagePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw diagonal lines
    for (int i = 0; i < 8; i++) {
      final startY = (size.height / 8) * i;
      canvas.drawLine(
        Offset(0, startY),
        Offset(size.width, startY + size.width * 0.3),
        paint..strokeWidth = 1,
      );
    }

    // Draw subtle circles
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final x = (size.width / 6) * i;
      for (int j = 0; j < 4; j++) {
        final y = (size.height / 4) * j;
        canvas.drawCircle(
          Offset(x, y),
          20 + (i * 5),
          circlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
