import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';

import '../Utility/SkeletonLoader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../POJO/professional_response_data.dart';
import '../service_details.dart';
import '../service_item.dart';
import 'BLOC/APIBloC.dart';
import 'POJO/services_response_data.dart';
import 'Utility/constants.dart';
import 'Utility/permission_helper.dart';
import 'Utility/service_error_widget.dart';
import 'appointment_List_view_item.dart';
import 'location_based_item.dart';
import 'login.dart';
import 'Utility/login_prompt.dart';
import 'package:flutter/cupertino.dart';
import 'services/location_service.dart';
import 'home_screen.dart';

/*void main() {
  runApp(homeScreenContent());
}*/

String? loginEmail, loginName, loginImage;
bool _isLoading = false;
/*

class homeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreenContentDemo(),
    );
  }
}
*/

class HomeScreenContentDemo extends StatefulWidget {
  // Define a GlobalKey to access the state
  static final GlobalKey<_HomeScreenContentDemoState> globalKey = GlobalKey();

  HomeScreenContentDemo() : super(key: globalKey);

  // Static method to select the fourth tab
  static void selectFourthTab() {
    globalKey.currentState?.setFourthTab();
  }

  @override
  _HomeScreenContentDemoState createState() => _HomeScreenContentDemoState();
}

class _HomeScreenContentDemoState extends State<HomeScreenContentDemo> {
  int _selectedIndex = 0;
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentLocation;
  final ScrollController _scrollController = ScrollController();
  APIBloC? _bloc;
  String selectedId = "0";
  late String selectedPriceRange = "0";
  final Set<Marker> _markers = {};
  final List<ServicesResponseData> _allItems = [];
  List<ServicesResponseData> _filteredItems = [];
  final List<ServicesResponseData> _serviceMaster = [];

  final List<ProfessionalResponseData>? _allProfessionals = [];
  List<ProfessionalResponseData>? _allFilteredProfessionals = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _professionalSearchController =
      TextEditingController();

  OverlayEntry? _overlayEntry;
  OverlayEntry? _overlayEntry1;

  final LayerLink _layerLink = LayerLink();
  final LayerLink _layerLink1 = LayerLink();
  int tagIndex = 0;
  bool isLoading = false;
  String selectedLocation = "";

  bool _isLoadingTab1 = true;
  bool _isLoadingTab2 = true;
  bool _isLoadingTab3 = true;
  bool _hasServiceError = false;
  bool _hasLocationError = false;
  bool _hasProfessionalError = false;
  final List<String> priceRanges = ['0-50', '51-100', '101-150', '150+'];
  final LocationService _locationService = LocationService();
  late SharedPreferences prefs;

  /* @override
  Future<void> initState() async {
    super.initState();
    PermissionHelper.requestAllPermissions(); // Add this
    prefs = await SharedPreferences.getInstance();

    _searchController.addListener(_onSearchChanged);
    _professionalSearchController.addListener(_onProfessionalSearchChanged);

    getServices(context);
    getProfessionals(context, "", "", "");
    if (ConstantVariable.authToken != null &&
        ConstantVariable.authToken!.isNotEmpty) {
      getUserProfile(context);
    }
    //print("HERE @@@####^^^^");
  }*/

  @override
  void initState() {
    super.initState();


    _initializePreferences(); // Call async initializer

    _searchController.addListener(_onSearchChanged);
    _professionalSearchController.addListener(_onProfessionalSearchChanged);

    getServices(context);
    getProfessionals(context, "", "", "");

    if (ConstantVariable.authToken != null &&
        ConstantVariable.authToken!.isNotEmpty) {
      print("ConstantVariable.authToken here in fetch profile" +
          ConstantVariable.authToken!);

      getUserProfile(context);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _professionalSearchController.dispose();
    _bloc?.dispose();
    _overlayEntry?.remove();
    _overlayEntry1?.remove();
    _locationService.dispose();

    _searchController.removeListener(_onSearchChanged);
    _professionalSearchController.removeListener(_onProfessionalSearchChanged);

    super.dispose();
  }

  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    // You can also do other async setup here if needed
  }

  // Method to set the index to the fourth tab
  void setFourthTab() {
    if (!mounted) return;
    setState(() {
      print("here in selected");
      _selectedIndex = 3; // Set index to 3 for the fourth tab
    });
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

  Future<void> getServices(BuildContext context) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.getServiecs();

      print("Services Response: ${value?.toString() ?? "null"}");
      print("Value length: ${value?.length.toString() ?? "0"}");

      // Clear _allItems and add the new values outside setState
      _allItems.clear();
      _serviceMaster.clear();

      if (value != null && value.isNotEmpty) {
        _allItems.addAll(value);
        _serviceMaster.addAll(value); // Add items directly to _allItems
        _hasServiceError = false;
      } else {
        _hasServiceError = true;
      }
      _filteredItems = _allItems;

      if (_allItems.length > 5) {
        tagIndex = 5;
      } else {
        tagIndex = _allItems.length;
      }

      print("_allItems $_allItems");
      print("_allItems ${_allItems!.length}");

      // Now update the UI state synchronously
      if (!mounted) return;
      setState(() {
        _isLoadingTab1 = false;
        print("Size of _allItems: ${_allItems.length}");
      });
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle service/network errors
      if (!mounted) return;
      setState(() {
        _isLoadingTab1 = false;
        _hasServiceError = true;
      });
    }
  }

  Future<void> getLocationBasedServiecs(BuildContext context) async {
    _bloc = APIBloC();

    try {
      // First ensure we have location permission
      if (!await _locationService.hasLocationPermission()) {
        await _locationService.requestLocationPermission();
      }

      // Get current location
      final currentLatLng = await _locationService.getCurrentLatLng();
      if (!mounted) return;
      setState(() {
        _currentLocation = currentLatLng;
      });

      // Now fetch location-based services
      final value = await _bloc?.getLocationBasedServiecs();
      print("Location Response: ${value.toString()}");

      if (value != null && value.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoadingTab2 = false;
          _hasLocationError = false;
          _markers.clear();
          _allProfessionals?.clear();
          _filteredItems.clear();

          // Update markers and other UI elements
          for (var item in value) {
            if (item.service_latitude != null &&
                item.service_longitude != null &&
                item.service_city != null) {
              // Add markers or update UI as needed
            }
          }

          // Set initial location to first service location if available
          if (value[0].service_latitude != null &&
              value[0].service_longitude != null) {
            _currentLocation = LatLng(
              double.parse(value[0].service_latitude!),
              double.parse(value[0].service_longitude!),
            );
          }
        });
      } else {
        // Service/Network error
        if (!mounted) return;
        setState(() {
          _isLoadingTab2 = false;
          _hasLocationError = true;
        });
      }
    } catch (e) {
      print("Error occurred during fetching location-based services: $e");
      // Handle service/network errors
      if (!mounted) return;
      setState(() {
        _isLoadingTab2 = false;
        _hasLocationError = true;
      });
    }
  }

  Future<void> getUserProfile(BuildContext context) async {
    if (ConstantVariable.authToken == null || ConstantVariable.authToken!.isEmpty) return;
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.getCustomerProfileData();

      if (value != null) {
        if (value.message == "Unauthorized") {
          print("Unauthorized ");
          getToken(context);
        } else {
          print("Profile Response: ${value?.toString() ?? "null"}");

          if (!mounted) return;
          setState(() {
            //print("Size of _allItems: " + _allItems.length.toString());

            if (value.user != null) {
              print("here in image set${(value.user!.profile_image ?? "")}");
            ConstantVariable.userProfileImage = value.user?.profile_image!;
              // Set username from first_name and last_name
              if (value.user!.first_name != null && value.user!.last_name != null) {
                ConstantVariable.userName = 
                    (value.user!.first_name ?? "") + " " + (value.user!.last_name ?? "");
              } else if (value.user!.first_name != null) {
                ConstantVariable.userName = value.user!.first_name ?? "";
              }
            }
            updateFCMToken(context);
          });
        }
      } else {
        //showAlertDialog();
      }
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  Future<void> updateFCMToken(BuildContext context) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.updateFCMToken();

      print("here 22222222444444");

      if (value!.message == null) {
      } else {}
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  Future<void> getToken(BuildContext context) async {
    if (ConstantVariable.authToken == null || ConstantVariable.authToken!.isEmpty) return;
    // Initialize the bloc
    try {
      // Perform the async registration work

      print("ConstantVariable.authToken " + ConstantVariable.authToken!);
      print("ConstantVariable.refreshToken " + ConstantVariable.refreshToken!);

      final value = await _bloc?.getNewToken(
          ConstantVariable.authToken!, ConstantVariable.refreshToken!);

      if (value!.message == null) {
        if (!mounted) return;
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

        print("here 22222222");
      } else {
        print("here 2");
        if (!mounted) return;
        setState(() {
          print("here 3");

          _isLoading = false;

          if (value.message == "Unauthorized") {
            print("Unauthorized1111111 ");
            ConstantVariable.authToken = "";
            ConstantVariable.refreshToken = "";
            prefs.remove("auth_token");
            prefs.remove("refresh_token");
            ConstantVariable.userName = "Guest";
            ConstantVariable.userProfileImage = "";
            //getToken(context);
          } else {}
        });
      }
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  Future<void> getMapKey(BuildContext context) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.getCustomerProfileData();

      if (value != null) {
        print("Profile Response: ${value?.toString() ?? "null"}");

        if (!mounted) return;
        setState(() {
          //print("Size of _allItems: " + _allItems.length.toString());

          print("here in image set${(value?.user!.profile_image!)!}");
          ConstantVariable.userProfileImage = value.user?.profile_image!;
        });
      } else {}
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  // Update the map location after receiving API data
  /* Future<void> _updateMapLocation(
      double latitude, double longitude, String location, String cost) async {
    final GoogleMapController controller = await _mapController.future;

    // Perform asynchronous operations outside setState
    final markerIcon = await _createCustomMarkerBitmap(cost);
    final newLocation = LatLng(latitude, longitude);

    setState(() {
      _currentLocation = newLocation;
      print("_currentLocation !!!! $_currentLocation");

      _markers.add(
        Marker(
          markerId: MarkerId(newLocation.toString()),
          position: newLocation,
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: 'New Location',
            snippet: '$latitude, $longitude', // Optional description
          ),
          onTap: () {
            selectedLocation = location;
            getProfessionals(context, location, '', '');
          },
        ),
      );
    });

    // Animate the camera to the new location
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newLocation,
          zoom: 12.0, // Adjust zoom level as necessary
        ),
      ),
    );
  }*/

  Future<void> _updateMapLocation(double latitude, double longitude,
      String location, String cost, String image, int id) async {
    final GoogleMapController controller = await _mapController.future;

    // Perform asynchronous operations first
    LatLng newLocation = LatLng(latitude, longitude);
    print("_currentLocation !!!!$newLocation");

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double size = 400;

    // Load and draw profile image
    ui.Image profileImage;
    if (image.isNotEmpty) {
      try {
        final NetworkImage networkImage = NetworkImage(image);
        final ImageStream stream = networkImage.resolve(ImageConfiguration());
        final Completer<ui.Image> completer = Completer<ui.Image>();
        stream.addListener(ImageStreamListener((info, _) {
          completer.complete(info.image);
        }));
        profileImage = await completer.future;
      } catch (e) {
        print("Error loading profile image: $e");
        // Use default placeholder image
        final ByteData data = await rootBundle.load('assets/images/nl.png');
        profileImage = await decodeImageFromList(data.buffer.asUint8List());
      }
    } else {
      // Use default placeholder image
      final ByteData data = await rootBundle.load('assets/images/nl.png');
      profileImage = await decodeImageFromList(data.buffer.asUint8List());
    }

    // Draw profile image with gradient border
    final double imageSize = 140;
    final double borderWidth = 6;
    final Rect imageRect = Rect.fromLTWH(
      size / 2 - imageSize / 2,
      size / 2 - imageSize / 2 - 20,
      imageSize,
      imageSize,
    );

    // Draw outer shadow for profile image
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(
      Offset(size / 2, size / 2 - 20),
      imageSize / 2 + borderWidth,
      shadowPaint,
    );

    // Draw orange gradient border (outer circle) - using solid orange with glow effect
    final Paint borderPaint = Paint()
      ..color = Color(0xFFA773F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(
      Offset(size / 2, size / 2 - 20),
      imageSize / 2 + borderWidth / 2,
      borderPaint,
    );

    // Draw inner orange border for gradient effect
    final Paint innerBorderPaint = Paint()
      ..color = Color(0xFFA773F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size / 2, size / 2 - 20),
      imageSize / 2 + 1,
      innerBorderPaint,
    );

    // Draw white border circle
    final Paint whiteBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
      Offset(size / 2, size / 2 - 20),
      imageSize / 2 - 1,
      whiteBorderPaint,
    );

    // Draw profile image in circle
    final Path clipPath = Path()..addOval(imageRect);
    canvas.save();
    canvas.clipPath(clipPath);
    canvas.drawImageRect(
      profileImage,
      Rect.fromLTWH(
          0, 0, profileImage.width.toDouble(), profileImage.height.toDouble()),
      imageRect,
      Paint(),
    );
    canvas.restore();

    // Draw modern price badge with gradient background
    final double badgeWidth = 120;
    final double badgeHeight = 50;
    final double badgeRadius = 25;
    final double badgeX = size / 2 - badgeWidth / 2;
    final double badgeY = size / 2 + 100;

    // Draw shadow for badge
    final Paint badgeShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    final RRect shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX + 2, badgeY + 2, badgeWidth, badgeHeight),
      Radius.circular(badgeRadius),
    );
    canvas.drawRRect(shadowRect, badgeShadowPaint);

    // Draw gradient background for price badge - using solid orange with inner highlight
    final Paint badgeBgPaint = Paint()
      ..color = Color(0xFFA773F7);
    final RRect badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX, badgeY, badgeWidth, badgeHeight),
      Radius.circular(badgeRadius),
    );
    canvas.drawRRect(badgeRect, badgeBgPaint);

    // Draw inner highlight for gradient effect
    final Paint highlightPaint = Paint()
      ..color = Color(0xFFA773F7).withOpacity(0.5);
    final RRect highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX, badgeY, badgeWidth, badgeHeight / 2),
      Radius.circular(badgeRadius),
    );
    canvas.drawRRect(highlightRect, highlightPaint);

    // Draw white border for badge
    final Paint badgeBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(badgeRect, badgeBorderPaint);

    // Draw cost text with improved typography
    final TextPainter costPainter = TextPainter(
      text: TextSpan(
        text: "\$$cost",
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          fontFamily: "Poppins",
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    costPainter.layout();
    costPainter.paint(
      canvas,
      Offset(
        size / 2 - costPainter.width / 2,
        badgeY + badgeHeight / 2 - costPainter.height / 2,
      ),
    );

    final ui.Image markerImage = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final ByteData? byteData =
        await markerImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List markerIcon = byteData!.buffer.asUint8List();

    // Update the state synchronously
    if (!mounted) return;
    setState(() {
      _currentLocation = newLocation;
      _markers.add(
        Marker(
          markerId: MarkerId(_currentLocation.toString()),
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          onTap: () {
            selectedLocation = location;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GlowHomePage(
                    //  _allProfessionals![index].vendor_id!,
                    id),
              ),
            );

            //getProfessionals(context, location, '', '');
          },
        ),
      );
    });

    // Animate camera to new location
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentLocation!,
          zoom: 12.0,
        ),
      ),
    );
  }

  Future<BitmapDescriptor> _createCustomMarkerBitmap(String text) async {
    // Create a widget with text to convert to bitmap
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.blue;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 60.0, color: Colors.black),
      ),
    );

    // Draw text on canvas
    textPainter.layout();
    textPainter.paint(canvas, Offset(20.0, 10.0));

    // Complete drawing and convert to image
    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(150, 100);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  Future<void> getProfessionals(BuildContext context, String location,
      String priceRange, String sid) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async work and await the result
      final value = await _bloc?.getProfessionals(location, priceRange, sid);
      print("Professional Response:@@@@ ${value.toString()}");

      _allProfessionals!.clear();

      if (value != null && value.isNotEmpty) {
        _allProfessionals!.addAll(value); // Add items directly to _allItems
        _hasProfessionalError = false;
      } else {
        _hasProfessionalError = true;
      }
      _allFilteredProfessionals = _allProfessionals;
      print(
          "Size of _allFilteredProfessionals: @@@@${_allFilteredProfessionals!.length}");

      // Now, update the state synchronously
      if (!mounted) return;
      setState(() {
        _isLoadingTab1 = false;
        _isLoadingTab2 = false;
        _isLoadingTab3 = false;

        print("Size of _allItems: ${_allProfessionals!.length}");
      });
    } catch (e) {
      print("Error occurred during fetching professionals: $e");
      // Handle service/network errors
      if (!mounted) return;
      setState(() {
        _isLoadingTab1 = false;
        _isLoadingTab2 = false;
        _isLoadingTab3 = false;
        _hasProfessionalError = true;
      });
    }
  }

  Future<void> getProfessionals1(BuildContext context, String location,
      String priceRange, String sid) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async work and await the result
      final value = await _bloc?.getProfessionals(location, priceRange, sid);
      print("Professional Response:@@@@ ${value.toString()}");

      _allProfessionals!.clear();

      if (!mounted) return;
      setState(() {
        if (value != null && value.isNotEmpty) {
          _allProfessionals!.addAll(value); // Add items directly to _allItems
          _hasLocationError = false;
        } else {
          _hasLocationError = true;
        }
        _allFilteredProfessionals = _allProfessionals;
        print(
            "Location based professionals${_allFilteredProfessionals!.length}");

        _markers.clear();

        for (var item in _allFilteredProfessionals!) {
          if (item.service_latitude != null &&
              item.service_latitude!.isNotEmpty &&
              item.service_longitude != null &&
              item.service_longitude!.isNotEmpty &&
              item.vendor_id != null) {
            try {
              _updateMapLocation(
                  double.parse(item.service_latitude!),
                  double.parse(item.service_longitude!),
                  item.location ?? " ",
                  item.cost ?? " ",
                  item.profile_image ?? " ",
                  item.vendor_id!);
            } catch (e) {
              print('Error parsing location for marker: $e');
            }
          }
        }
      });

      /*_updateMapLocation(double.parse(item.serv!ice_latitude!),
          double.parse(item.service_longitude!), item.service_city?? " ",value!.toList()[0].service_city?? " ");*/

      // Now, update the state synchronously
      setState(() {
        print("Size of _allItems: ${_allProfessionals!.length}");
      });
    } catch (e) {
      print("Error occurred during fetching professionals: $e");
      // Handle service/network errors
      if (!mounted) return;
      setState(() {
        _hasLocationError = true;
      });
    }
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
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Colors.blueAccent.shade700,
                ))
              : Stack(
                  children: [
                    // Premium Background Header with Orange Gradient and Pattern
                    Container(
                      height: double.infinity,
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

                    SafeArea(
                        child: Column(
                          children: [
                          // Static header section (not scrollable)
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 9, bottom: 24),
                            child: _buildHeader(),
                          ),
                          // Static tabs section (not scrollable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: _buildSegmentedControl(),
                          ),
                                  SizedBox(height: 24),
                          // Static search bar section (not scrollable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    child: _selectedIndex == 0
                                        ? _buildSendMessageFooter()
                                        : _selectedIndex == 1
                                            ? _buildLocationFilters()
                                            : _buildSendMessageFooter1(),
                            ),
                                  ),
                                  SizedBox(height: 20),
                          // Scrollable content section (tags and main content)
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: _allItems.isNotEmpty
                                  ? Container(
                                          height: 32,
                                          margin: EdgeInsets.only(top: 10),
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _allItems.length,
                                            physics:
                                                BouncingScrollPhysics(),
                                            padding: EdgeInsets.symmetric(horizontal: 2),
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                    selectedId =
                                                        _allItems[index].id!;
                                              });
                                                  getProfessionals(
                                                      context,
                                                      selectedLocation,
                                                      '',
                                                      selectedId);
                                            },
                                            child: _buildTag(
                                                _allItems[index].name!,
                                                  _allItems[index].id ==
                                                      selectedId,
                                                ),
                                          );
                                        },
                                      ),
                                    )
                                      : Container(),
                            ),
                      _selectedIndex == 0
                          ? _isLoadingTab1
                              ? ServicesTabSkeleton()
                              : (_hasServiceError && _allItems.isEmpty)
                                  ? ServiceErrorWidget(
                                      onRetry: () {
                                        setState(() {
                                          _hasServiceError = false;
                                          _hasProfessionalError = false;
                                          _isLoadingTab1 = true;
                                        });
                                        getServices(context);
                                        getProfessionals(context, "", "", "");
                                      },
                                    )
                                  : _buildSegmentedControlData1()
                          : _selectedIndex == 1
                              ? _isLoadingTab2
                                  ? LocationTabSkeleton()
                                  : _hasLocationError
                                      ? ServiceErrorWidget(
                                          onRetry: () {
                                            setState(() {
                                              _hasLocationError = false;
                                              _isLoadingTab2 = true;
                                            });
                                            getLocationBasedServiecs(context);
                                          },
                                        )
                                      : _buildSegmentedControlData2()
                              : _isLoadingTab3
                                  ? ProfessionalTabSkeleton()
                                  : (_hasProfessionalError && (_allProfessionals == null || _allProfessionals!.isEmpty))
                                      ? ServiceErrorWidget(
                                          onRetry: () {
                                            setState(() {
                                              _hasProfessionalError = false;
                                              _isLoadingTab3 = true;
                                            });
                                            getProfessionals(context, "", "", "");
                                          },
                                        )
                                      : _buildSegmentedControlData3(),
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
        );
  }

  void showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.black.withOpacity(0.3),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedPriceRange = priceRanges[index];
                    });
                  },
                  children: priceRanges
                      .map((range) => Center(
                            child: Text(
                              '\$$range',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showPicker1(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.black.withOpacity(0.3),
          child: Column(
            children: [
              // Header with a "Done" button
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              // Picker for services
              Expanded(
                child: ListView.builder(
                  itemCount: _serviceMaster.length,
                  itemBuilder: (context, index) {
                    final service = _serviceMaster[index];
                    return ListTile(
                      title: Text(
                        service.name ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: "Poppins",
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedId = service.id ?? "0";
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    // Get customer name, fallback to "Guest" if not available
    String customerName = ConstantVariable.userName?.isNotEmpty == true
        ? ConstantVariable.userName!
        : "Guest";
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Friendly greeting with emoji
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.9),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        '👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.85),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          fontFamily: "Poppins",
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                // Stylish Customer Name with enhanced styling
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.98),
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.9),
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    customerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      fontFamily: "Poppins",
                      letterSpacing: -0.4,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4),
                // Welcoming subtitle message
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.8),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Let\'s find your perfect service today',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      fontFamily: "Poppins",
                      letterSpacing: 0.15,
                      height: 1.25,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          (ConstantVariable.authToken != null &&
                  ConstantVariable.authToken!.isNotEmpty)
              ? GestureDetector(
                  onTap: () {
                    BottomTabBar.selectProfileTab();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Enhanced outer glow effect with multiple layers
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFFA773F7).withOpacity(0.3),
                              Color(0xFFA773F7).withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFA773F7).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 3,
                              offset: Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Color(0xFFA773F7).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: Offset(0, -1),
                            ),
                          ],
                        ),
                      ),
                      // Gradient border ring with enhanced styling
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, -1),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(3),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ConstantVariable.userProfileImage?.isNotEmpty == true
                              ? CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(ConstantVariable.userProfileImage!) as ImageProvider,
                                )
                              : Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        ),
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFFA773F7).withOpacity(0.6),
                                    size: 28,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    _navigateAndGetResult(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFA773F7),
                          Color(0xFF8A4DF4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFA773F7).withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins",
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _navigateAndGetResult(BuildContext context) async {
    Navigator.pop(context);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrendTodayLogin(from: "cart")),
    );

    if (result == "result") {
      print("Returned result: $result");
      getUserProfile(context);
    }
    // Use the returned result here
    // Perform any actions with the result
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 54,
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSegmentedControlItem('Services', 0),
          _buildSegmentedControlItem('Location', 1),
          _buildSegmentedControlItem('Professional', 2),
        ],
      ),
    );
  }

  Widget _buildSegmentedControlItem(String text, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
            if (_selectedIndex == 0) {
              _isLoadingTab1 = true;
              getServices(context);
              getProfessionals(context, "", "", "");
            } else if (_selectedIndex == 1) {
              _isLoadingTab2 = true;
              PermissionHelper.requestLocationPermission(context);
              getLocationBasedServiecs(context);
            } else {
              _isLoadingTab3 = true;
              getServices(context);
              getProfessionals(context, "", "", "");
            }
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFA773F7) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              )
            ] : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                fontSize: 11,
                fontFamily: "Poppins",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFilters() {
    final isServiceSelected = selectedId != "0";
    final isPriceSelected = selectedPriceRange != "0";
    
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.black.withOpacity(0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Color(0xFFE5E7EB).withOpacity(0.5),
              width: 1,
            ),
          ),
          textStyle: TextStyle(
            fontFamily: "Poppins",
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      child: Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isServiceSelected 
                    ? Color(0xFFA773F7).withOpacity(0.3)
                    : Color(0xFFE5E7EB),
                width: isServiceSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isServiceSelected
                      ? Color(0xFFA773F7).withOpacity(0.1)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Builder(
              builder: (context) {
                final uniqueServices = _serviceMaster.fold<List<ServicesResponseData>>([], (list, item) {
                  if (!list.any((e) => e.id == item.id)) list.add(item);
                  return list;
                });
                final safeSelectedId = (selectedId == "0" || !uniqueServices.any((item) => item.id == selectedId)) ? null : selectedId;
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    isDense: true,
                    value: safeSelectedId,
                    hint: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedId == "0" 
                                  ? 'Select Service' 
                                  : uniqueServices.firstWhere(
                                      (item) => item.id == selectedId,
                                      orElse: () => ServicesResponseData()
                                    ).name ?? 'Select Service',
                              style: TextStyle(
                                color: isServiceSelected 
                                    ? Color(0xFF111827)
                                    : Color(0xFF9CA3AF),
                    fontFamily: "Poppins",
                    fontSize: 11,
                                fontWeight: isServiceSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 2,
                              
                            ),
                          ),
                        ],
                ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isServiceSelected 
                            ? Color(0xFFA773F7)
                            : Color(0xFF6B7280),
                        size: 20,
                      ),
                      iconSize: 20,
                      menuMaxHeight: 300,
                      itemHeight: null,
                items: uniqueServices.map((item) {
                        final isSelected = safeSelectedId == item.id;
                  return DropdownMenuItem<String>(
                    value: item.id,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Color(0xFFA773F7).withOpacity(0.05)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                    child: Text(
                      item.name ?? '',
                                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontSize: 12,
                                      fontWeight: isSelected 
                                          ? FontWeight.w600 
                                          : FontWeight.w400,
                                      letterSpacing: -0.2,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFFA773F7),
                                    size: 18,
                                  ),
                              ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedId = value ?? "0";
                  });
                },
                      dropdownColor: Color(0xFF1A1A1A),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        return uniqueServices.map((item) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.1,
                                  ),
                                  maxLines: 2,
                                  
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                );
              }
            ),
          ),
            ),
          ),
        ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPriceSelected 
                    ? Color(0xFFA773F7).withOpacity(0.3)
                    : Color(0xFFE5E7EB),
                width: isPriceSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isPriceSelected
                      ? Color(0xFFA773F7).withOpacity(0.1)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Builder(
              builder: (context) {
                final validPriceRanges = ['0-50', '51-100', '101-150', '150+'];
                final safePriceRange = validPriceRanges.contains(selectedPriceRange) ? selectedPriceRange : null;
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    isDense: true,
                    value: safePriceRange,
                    hint: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedPriceRange == "0" 
                                  ? 'price range' 
                                  : '\$$selectedPriceRange',
                  style: TextStyle(
                                color: isPriceSelected 
                                    ? Color(0xFF111827)
                                    : Color(0xFF9CA3AF),
                    fontFamily: "Poppins",
                    fontSize: 11,
                                fontWeight: isPriceSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 2,
                              
                            ),
                          ),
                        ],
                ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isPriceSelected 
                            ? Color(0xFFA773F7)
                            : Color(0xFF6B7280),
                        size: 20,
                      ),
                      iconSize: 20,
                      menuMaxHeight: 300,
                      itemHeight: 48,
                items: [
                        DropdownMenuItem(
                          value: '0-50',
                          child: Builder(
                            builder: (context) {
                              final isSelected = selectedPriceRange == '0-50';
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Color(0xFFA773F7).withOpacity(0.05)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '\$0 - \$50',
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 12,
                                          fontWeight: isSelected 
                                              ? FontWeight.w600 
                                              : FontWeight.w400,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFFA773F7),
                                        size: 18,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        DropdownMenuItem(
                          value: '51-100',
                          child: Builder(
                            builder: (context) {
                              final isSelected = selectedPriceRange == '51-100';
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Color(0xFFA773F7).withOpacity(0.05)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '\$51 - \$100',
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 12,
                                          fontWeight: isSelected 
                                              ? FontWeight.w600 
                                              : FontWeight.w400,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFFA773F7),
                                        size: 18,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        DropdownMenuItem(
                          value: '101-150',
                          child: Builder(
                            builder: (context) {
                              final isSelected = selectedPriceRange == '101-150';
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Color(0xFFA773F7).withOpacity(0.05)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '\$101 - \$150',
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 12,
                                          fontWeight: isSelected 
                                              ? FontWeight.w600 
                                              : FontWeight.w400,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFFA773F7),
                                        size: 18,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        DropdownMenuItem(
                          value: '150+',
                          child: Builder(
                            builder: (context) {
                              final isSelected = selectedPriceRange == '150+';
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Color(0xFFA773F7).withOpacity(0.05)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '\$151+',
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 12,
                                          fontWeight: isSelected 
                                              ? FontWeight.w600 
                                              : FontWeight.w400,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFFA773F7),
                                        size: 18,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPriceRange = value ?? "0";
                  });
                },
                      dropdownColor: Color(0xFF1A1A1A),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        final validPriceRanges = ['0-50', '51-100', '101-150', '150+'];
                        return validPriceRanges.map((priceItem) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '\$$priceItem',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.1,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                );
              }
            ),
          ),
            ),
          ),
        ),
        ),
        SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                getProfessionals1(context, "", selectedPriceRange, selectedId);
              },
              borderRadius: BorderRadius.circular(14),
              child: Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildSendMessageFooter() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: CompositedTransformTarget(
              link: _layerLink,
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                _onSearchTextChanged(query, context);
              },
              style: TextStyle(
                fontSize: 15,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintText: 'Search for services...',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.white, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(6),
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: InkWell(
              onTap: () => getProfessionals(context, "", "", selectedId),
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Text(
                  'GO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontFamily: "Poppins",
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendMessageFooter1() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _professionalSearchController,
              onChanged: (query) {
                _onSearchTextChanged1(query, context);
              },
              style: TextStyle(
                fontSize: 15,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintText: 'Search professional...',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(Icons.person_search_rounded, color: Colors.white, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(6),
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: InkWell(
              onTap: () => getProfessionals(context, "", "", selectedId),
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Text(
                  'GO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontFamily: "Poppins",
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildTag(String? tag) {
    return Container(
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.brown, // Background color of the tag
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: Text(
        tag!,
        style: TextStyle(
            color: Colors.white, // Text color
            fontSize: 12,
            fontWeight: FontWeight.w400),
      ),
    );
  }*/

  Widget _buildTag(String tag, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        gradient: isSelected 
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
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected 
              ? Colors.transparent 
              : Color(0xFFA773F7),
          width: isSelected ? 0 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: Color(0xFFA773F7).withOpacity(0.35),
            blurRadius: 10,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0xFFA773F7).withOpacity(0.15),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          tag,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF374151),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontFamily: "Poppins",
            letterSpacing: 0,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSegmentedControlData1() {
    return _isLoadingTab1
        ? ServicesTabSkeleton()
        : Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Header Section
                Row(
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
                                'Popular Professionals',
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
                              'Top-rated experts in your area',
                            style: TextStyle(
                              color: Colors.white60,
                                fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFA773F7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFA773F7).withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_allProfessionals!.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Modern Grid Layout
                GridView.builder(
                    itemCount: _allProfessionals!.length,
                  physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 0.68,
                    ),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                    final professional = _allProfessionals![index];
                      return GestureDetector(
                        onTap: () {
                          navigateToGlowHomePage(context,
                              _allFilteredProfessionals![index].vendor_id!);
                        },
                      child: _buildModernProfessionalCard(professional),
                      );
                    },
                  ),
              ],
            ),
          );
  }

  Widget _buildModernProfessionalCard(ProfessionalResponseData professional) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 1),
            spreadRadius: 0,
                ),
              ],
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                    ),
                    child: (professional.profile_image != null && professional.profile_image!.isNotEmpty) ||
                           (professional.logo != null && professional.logo!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: (professional.profile_image != null && professional.profile_image!.isNotEmpty)
                                ? professional.profile_image!
                                : professional.logo!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFA773F7),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: Color(0xFFA773F7).withOpacity(0.3),
                              size: 32,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: Color(0xFFA773F7).withOpacity(0.3),
                            size: 32,
                          ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: Color(0xFFA773F7), size: 10),
                          SizedBox(width: 2),
                          Text(
                            '4.5',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Business Name
                  Text(
                    (professional.business_name?.trim().isNotEmpty == true)
                        ? professional.business_name!.trim()
                        : (professional.professional_name?.trim().isNotEmpty == true)
                            ? professional.professional_name!.trim()
                            : 'Professional',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontFamily: "Poppins",
                      letterSpacing: -0.1,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    
                  ),
                  SizedBox(height: 3),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 10,
                        color: Colors.white60,
                      ),
                      SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          professional.location ?? 'Location',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white60,
                            fontFamily: "Poppins",
                            height: 1.2,
                          ),
                          maxLines: 2,
                          
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          professional.cost != null && professional.cost!.isNotEmpty
                              ? '\$${professional.cost}'
                              : '\$--',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 8,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
          );
  }

  // Widget to build segmented control data with map and list of professionals
  Widget _buildSegmentedControlData2() {
    /* selectedPriceRange  =  "0";
    selectedId  =  "0";*/
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header Section
          Row(
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
                        SizedBox(width: 10),
                        Text(
                          'Location Based Services',
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
                        'Find professionals near you',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
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
          SizedBox(height: 20),
          // Modern Map Container
          GestureDetector(
            onVerticalDragUpdate: (details) {
              // Custom behavior on vertical drag, if needed
            },
            child: _currentLocation != null
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFA773F7).withOpacity(0.25),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
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
                    padding: EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Stack(
                        children: [
                          GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation!,
                          zoom: 14.0,
                        ),
                        mapType: MapType.normal,
                        markers: _markers,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController.complete(controller);
                        },
                        myLocationEnabled: true,
                            myLocationButtonEnabled: false, // We'll add custom button
                            zoomControlsEnabled: false, // We'll add custom controls
                            mapToolbarEnabled: false,
                        gestureRecognizers: {
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                            padding: EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              left: 8,
                              right: 8,
                            ),
                          ),
                          // Compact Map Controls Overlay
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Zoom In Button
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final controller = await _mapController.future;
                                        controller.animateCamera(
                                          CameraUpdate.zoomIn(),
                                        );
                                      },
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(14),
                                        topRight: Radius.circular(14),
                                      ),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        child: Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Color(0xFFE5E7EB),
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  // Zoom Out Button
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final controller = await _mapController.future;
                                        controller.animateCamera(
                                          CameraUpdate.zoomOut(),
                                        );
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        child: Icon(
                                          Icons.remove_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Color(0xFFE5E7EB),
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  // My Location Button
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        if (_currentLocation != null) {
                                          final controller = await _mapController.future;
                                          controller.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                target: _currentLocation!,
                                                zoom: 14.0,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(14),
                                        bottomRight: Radius.circular(14),
                                      ),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFA773F7).withOpacity(0.1),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(14),
                                            bottomRight: Radius.circular(14),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.my_location_rounded,
                                          color: Colors.black.withOpacity(0.3),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Compact Map Info Badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFA773F7).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.black.withOpacity(0.3),
                                      size: 12,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '${_markers.length}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Professionals',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white60,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.28,
                    decoration: BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            color: Colors.white54,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Loading map...',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 16),
          // Check if professionals list is not empty
          _allProfessionals!.isNotEmpty
              ? ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _allProfessionals!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                      onTap: () {
                        print('Item tapped: $index');
                        setState(() {
                          navigateToGlowHomePage(context, _allProfessionals![index].vendor_id ?? 0);
                        });
                      },
                          borderRadius: BorderRadius.circular(18),
                        child: LocationBasedItem(
                          image: _allProfessionals![index].profile_image ?? _allProfessionals![index].logo ?? "",
                          name: _allProfessionals![index].professional_name ?? _allProfessionals![index].business_name ?? "",
                          amount: _allProfessionals![index].cost ?? "CAD 0",
                          duration:
                              _allProfessionals![index].professional_name ?? _allProfessionals![index].business_name ?? "",
                          ),
                        ),
                      ),
                    );
                  },
                )
              // Show message if no professionals available
              : Transform.translate(
                  offset: Offset(0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 24),
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
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
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFFA773F7).withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.location_off_rounded,
                            size: 40,
                            color: Color(0xFFA773F7),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No Professionals Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            color: Colors.white60,
                            letterSpacing: -0.1,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControlData3() {
    return _isLoadingTab3
        ? ProfessionalTabSkeleton()
        : Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Header Section
                Row(
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
                              SizedBox(width: 10),
                              Text(
                                'Top Professionals',
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
                              'Book appointments with vetted experts',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
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
                SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(left: 0.0, right: 0.0, top: 0),
                  child: GridView.builder(
                    itemCount: _allFilteredProfessionals!.length,
                    padding: EdgeInsets.zero,
                    // Ensures no internal padding
                    physics: ScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0, // Spacing between rows
                      crossAxisSpacing: 10.0, // Spacing between columns
                      childAspectRatio: 0.8,
                    ),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          navigateToGlowHomePage(context, _allFilteredProfessionals![index].vendor_id!);
                        },
                        child: Container(
                          child: AppointmentGridView(
                            name: _allFilteredProfessionals![index]
                                .business_name!,
                            time: _allFilteredProfessionals![index]
                                .business_name!,
                            date: _allFilteredProfessionals![index]
                                .business_name!,
                            image: _allFilteredProfessionals![index]
                                        .profile_image !=
                                    null
                                ? _allFilteredProfessionals![index]
                                    .profile_image!
                                : "",
                            address:
                                _allFilteredProfessionals![index].location !=
                                            null &&
                                        _allFilteredProfessionals![index]
                                            .location!
                                            .isNotEmpty
                                    ? _allFilteredProfessionals![index].location
                                    : "Address",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  void navigateToGlowHomePage(BuildContext context, int vendorId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlowHomePage(vendorId),
      ),
    );

    // Handle the result from GlowHomePage here
    if (result != null) {
      print("Returned value: $result");

      setState(() {
        getUserProfile(context);
      });
      // Perform additional actions based on the result
    }
  }

  void _onSearchChanged() {
    setState(() {
      print("here in search ${_searchController.text}");
      if (_searchController.text.isNotEmpty) {
        _filteredItems = _allItems
            .where((item) => item.name!
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();

        print("_filteredItems $_filteredItems");
        print("_filteredItems ${_filteredItems.length}");
      } else {
        // When search is cleared, reset selectedId and show all professionals
        selectedId = "0";
        getProfessionals(context, "", "", "");
      }
    });
  }

  void _onProfessionalSearchChanged() {
    setState(() {
      print(
          "_allFilteredProfessionals${jsonEncode(_allFilteredProfessionals)}");
      print("_allProfessionals${jsonEncode(_allProfessionals)}");

      if (_professionalSearchController.text.isNotEmpty) {
        _allFilteredProfessionals = _allProfessionals
            ?.where((item) {
              final businessName = (item.business_name?.trim().isNotEmpty == true)
                  ? item.business_name!.trim().toLowerCase()
                  : (item.professional_name?.trim().isNotEmpty == true)
                      ? item.professional_name!.trim().toLowerCase()
                      : '';
              return businessName.contains(_professionalSearchController.text.toLowerCase());
            })
            .toList();

        // Show the overlay if there are filtered results
        if (_allFilteredProfessionals != null && _allFilteredProfessionals!.isNotEmpty) {
          _showOverlay1(context);
        } else {
          _removeOverlay1(); // Remove overlay when no results
        }
      } else {
        _allFilteredProfessionals = _allProfessionals;
        _removeOverlay1(); // Remove overlay when query is empty
        getProfessionals(context, "", "", "");
      }
    });
  }

  // Function to handle search text changes
  void _onSearchTextChanged(String query, BuildContext context) {
    setState(() {
      if (_selectedIndex == 0) {
        if (query.isNotEmpty) {
          // Filter the items based on the search query
          _filteredItems = _allItems
              .where((item) =>
                  item.name!.toLowerCase().contains(query.toLowerCase()))
              .toList();

          // Show the overlay if there are filtered results, otherwise remove it
          if (_filteredItems.isNotEmpty) {
            _showOverlay(context);
          } else {
            _removeOverlay(); // Remove overlay when no results
          }
        } else {
          // Reset the filtered items to the full list
          _filteredItems = _allItems;
          _removeOverlay(); // Remove overlay when query is empty
          // When search is cleared, reset selectedId and show all professionals
          selectedId = "0";
          getProfessionals(context, "", "", "");
        }
      }
      if (_selectedIndex == 1) {
        if (query.isNotEmpty) {
          // Filter the items based on the search query
          _allFilteredProfessionals = _allProfessionals!
              .where((item) => item.business_name!
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();

          // Show the overlay if there are filtered results
          if (_allFilteredProfessionals!.isNotEmpty) {
            _showOverlay(context);
          }
        } else {
          // Reset the filtered items to the full list
          _allFilteredProfessionals = _allProfessionals;
          _removeOverlay(); // Remove overlay when query is empty
        }
      }
      print("_filteredItems: $_filteredItems");
    });
  }

  void _onSearchTextChanged1(String query, BuildContext context) {
    setState(() {
      print("query!!!! $query");
      if (query.isNotEmpty) {
        // Filter the items based on the search query
        _allFilteredProfessionals = _allProfessionals!
            .where((item) =>
                item.business_name!.toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Show the overlay if there are filtered results
        if (_allFilteredProfessionals!.isNotEmpty) {
          _showOverlay(context);
        }
      } else {
        // Reset the filtered items to the full list
        _allFilteredProfessionals = _allProfessionals;
        _removeOverlay(); // Remove overlay when query is empty
      }
      print("_filteredItems: $_allFilteredProfessionals");
      print("_filteredItems: ${_allFilteredProfessionals!.length}");
    });
  }

// Function to show the overlay
  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry?.remove(); // Ensure the previous overlay is removed
      _overlayEntry = null; // Clear the existing overlay
    }

    // Create a new overlay entry
    _overlayEntry = _createOverlayEntry(context);

    // Get the overlay from the current context
    final overlay = Overlay.of(context);

    overlay.insert(_overlayEntry!); // Insert the new overlay entry
  }

// Function to remove the overlay
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove(); // Remove the existing overlay
      _overlayEntry = null; // Clear the reference after removal
    }
  }

// Handle the selection of an item from the search list
  void _onItemSelected(String selectedItem) {
    setState(() {
      _searchController.text =
          selectedItem; // Update the TextField with the selected item
      _removeOverlay(); // Remove the overlay when an item is selected
    });
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0.0, 56.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth - 40,
            maxHeight: 250.0, // Force height to no more than 250 px
          ),
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFFE5E7EB).withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: Offset(0, 8),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _filteredItems.length > 0
                    ? ListView.separated(
                        shrinkWrap: false,
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 6),
                        itemCount: _filteredItems.length,
                        separatorBuilder: (context, index) => Container(
                          height: 1,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFFF3F4F6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        itemBuilder: (context, index) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                print('Selected: ${_filteredItems[index].name}');
                                var selectedI = _filteredItems[index].id ?? '';
                                print("selectedI $selectedI");
                                print("_filteredItems  ${_filteredItems.length}");

                                // Update selectedId to track the selected service
                                selectedId = selectedI;
                                getProfessionals(context, "", "", selectedId);
                                _searchController.text =
                                    _filteredItems[index].name ?? '';

                                _removeOverlay(); // Remove overlay when an item is selected
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Modern Icon Container
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFA773F7).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Color(0xFFA773F7).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.search_rounded,
                                        color: Color(0xFFA773F7),
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // Text Content
                                    Flexible(
                                      child: SizedBox(
                                        width: 180,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _filteredItems[index].name ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                                letterSpacing: -0.2,
                                                height: 1.2,
                                              ),
                                              maxLines: null,
                                              overflow: TextOverflow.visible,
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Service',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white60,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // Arrow Icon
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 12,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }

// Function to show the overlay
  void _showOverlay1(BuildContext context) {
    if (_overlayEntry1 != null) {
      _overlayEntry1?.remove(); // Ensure the previous overlay is removed
      _overlayEntry1 = null; // Clear the existing overlay
    }

    // Create a new overlay entry
    _overlayEntry1 = _createOverlayEntry1(context);

    // Get the overlay from the current context
    final overlay = Overlay.of(context);

    overlay.insert(_overlayEntry1!); // Insert the new overlay entry
  }

// Function to remove the overlay
  void _removeOverlay1() {
    if (_overlayEntry1 != null) {
      _overlayEntry1?.remove(); // Remove the existing overlay
      _overlayEntry1 = null; // Clear the reference after removal
    }
  }

// Handle the selection of an item from the search list
  void _onItemSelected1(String selectedItem) {
    setState(() {
      _professionalSearchController.text =
          selectedItem; // Update the TextField with the selected item
      _removeOverlay1(); // Remove the overlay when an item is selected
    });
  }

  OverlayEntry _createOverlayEntry1(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final filteredCount = _allFilteredProfessionals != null && _allFilteredProfessionals!.isNotEmpty
        ? _allFilteredProfessionals!.length
        : (_allProfessionals != null ? _allProfessionals!.length : 0);

    return OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink1,
        showWhenUnlinked: false,
        offset: Offset(0.0, 50),
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth - 40,
              maxHeight: 200.0,
            ),
            margin: EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFE5E7EB).withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: Offset(0, 8),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: filteredCount > 0
                  ? ListView.builder(
                      shrinkWrap: false,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 6),
                      itemCount: filteredCount,
                      itemBuilder: (context, index) {
                        final professional = (_allFilteredProfessionals != null && _allFilteredProfessionals!.isNotEmpty)
                            ? _allFilteredProfessionals![index]
                            : _allProfessionals![index];
                        final businessName = (professional.business_name?.trim().isNotEmpty == true)
                            ? professional.business_name!.trim()
                            : (professional.professional_name?.trim().isNotEmpty == true)
                                ? professional.professional_name!.trim()
                                : 'Professional';
                        
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              print('Selected: $businessName');
                              _professionalSearchController.text = businessName;
                              _removeOverlay1(); // Remove overlay when an item is selected
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFA773F7).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Color(0xFFA773F7).withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      color: Color(0xFFA773F7),
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      businessName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

// Add this widget class after the HomeScreenContentDemo class
class HomeScreenContentSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header skeleton
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 40),
            child: Row(
              children: [
                // Welcome text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(
                      isLoading: true,
                      child: Container(
                        width: 100,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    ShimmerLoading(
                      isLoading: true,
                      child: Container(
                        width: 160,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                // Avatar/Login skeleton
                ShimmerLoading(
                  isLoading: true,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Segmented control skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 20),
          // Tag row skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 30,
            child: Row(
              children: List.generate(
                  4,
                  (i) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ShimmerLoading(
                          isLoading: true,
                          child: Container(
                            width: 60,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      )),
            ),
          ),
          SizedBox(height: 20),
          // Grid skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return ShimmerLoading(
                  isLoading: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              topRight: Radius.circular(7),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              SizedBox(height: 4),
                              Container(
                                width: 60,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Container(
                                    width: 20,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Add the Shimmer widget class before ServicesGridSkeleton
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

// --- SKELETONS FOR EACH TAB ---
class ServicesTabSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFFA773F7)),
      ),
    );
  }
}

class LocationTabSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFFA773F7)),
      ),
    );
  }
}

class ProfessionalTabSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFFA773F7)),
      ),
    );
  }
}

// --- SHARED SKELETON PARTS ---
class _HomeHeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 40),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading(
                isLoading: true,
                child: Container(
                  width: 100,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: 8),
              ShimmerLoading(
                isLoading: true,
                child: Container(
                  width: 160,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          ShimmerLoading(
            isLoading: true,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBarSkeleton extends StatelessWidget {
  final String hint;
  const _SearchBarSkeleton({required this.hint});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: ShimmerLoading(
              isLoading: true,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          ShimmerLoading(
            isLoading: true,
            child: Container(
              width: 70,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: ShimmerLoading(
              isLoading: true,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ShimmerLoading(
              isLoading: true,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          ShimmerLoading(
            isLoading: true,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 30,
      child: Row(
        children: List.generate(
            4,
            (i) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShimmerLoading(
                    isLoading: true,
                    child: Container(
                      width: 90,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                )),
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return ShimmerLoading(
            isLoading: true,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(7),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            SizedBox(width: 3),
                            Container(
                              width: 20,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: List.generate(
            5,
            (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      // Image
                      ShimmerLoading(
                        isLoading: true,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Name and city
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoading(
                              isLoading: true,
                              child: Container(
                                width: 120,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            ShimmerLoading(
                              isLoading: true,
                              child: Container(
                                width: 60,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      // Price
                      ShimmerLoading(
                        isLoading: true,
                        child: Container(
                          width: 50,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Arrow button
                      ShimmerLoading(
                        isLoading: true,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.brown[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
      ),
    );
  }
}

// Custom painter for stylish geometric pattern on home screen
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
