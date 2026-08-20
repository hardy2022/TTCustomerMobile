import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import '../Utility/SkeletonLoader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../POJO/appointment_input_data.dart';
import '../Utility/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../Utility/date_converter.dart';
import '../service_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BLOC/APIBLoC.dart';
import 'POJO/rental_location_details.dart';
import 'POJO/reviews_response_data.dart';
import 'POJO/services_provided_by_vendor.dart';
import 'Utility/open_external_map.dart';
import 'Utility/permission_helper.dart';
import 'address_card.dart';
import 'cart_services.dart';
import 'home_screen.dart';
import 'home_screen_content.dart';
import 'login.dart';
import 'Utility/login_prompt.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:geolocator/geolocator.dart';
import 'services/location_service.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class GlowHomePage extends StatefulWidget {
  final int vendorId;
  static List<bool> serviceListSelection = [];

  GlowHomePage(this.vendorId);

  @override
  State<StatefulWidget> createState() {
    return _GlowHomePageState(this.vendorId!);
  }
}

class _GlowHomePageState extends State<GlowHomePage> {
  int _selectedIndex = 0;
  final Color _segmentedControlColor = theme_color1;
  Completer<GoogleMapController> _mapController = Completer();
  Location _location = Location();
  LatLng? _currentLocation;
  APIBloC? _bloc;
  bool _isLoading = false;
  bool _isBooking = false;

  late int copyVendorId;
  late DateTime? _selectedDateValue = DateTime.now();
  late String _selectedTimeValue = "";
  late List<String> _selectedServices = [];
  late String _selectedServiceId = "";
  String selectedType = "CUSTOMER";
  List<bool> isSelectedToggle = [true, false];

  late List<String> timeSlots = [];
  late List<String> weekList = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  late SharedPreferences prefs;

  Set<Marker> _markers = {};

  List<bool> isSelected = [];
  int selectedIndex1 = -1; // -1 means no selection initially
  String vendorImage = ''; // -1 means no selection initially
  ScrollController _scrollController = ScrollController();
  List<ServicesProvidedByVendorResponseData> serviceList = [];
  List<RentalLocationsDetails> rentalLocationList = [];
  bool hasAddresses = false;

  //List<ServicesAddressProvidedByVendorResponseData> addressList = [];

  List<ReviewsResponseData> ReviewsList = [];
  String des = "";
  String professionalName = "";
  String professionalAddress = "";
  String profileImage = "";

  final hours = {
    'Sunday': 'Closed',
    'Monday': 'Closed',
    'Tuesday': 'Closed',
    'Wednesday': 'Closed',
    'Thursday': 'Closed',
    'Friday': 'Closed',
    'Saturday': 'Closed',
  };
  Map<String, String> hoursByAPI = {};

  final LocationService _locationService = LocationService();

  // Add API call tracking
  bool _isLoadingWorkingHours = false;
  DateTime? _lastWorkingHoursCall;
  static const Duration _minCallInterval = Duration(milliseconds: 500);

  // Add booking window constants
  static const int _minBookingDaysAhead = 0; // Can book for today
  static const int _maxBookingDaysAhead = 90; // Can book up to 90 days ahead
  static const int _maxFutureYears =
      1; // Maximum years in future for date picker
  int? selectedAddressIndex;
  final Set<int> selected = {};
  double? selectedLat;
  double? selectedLng;

  _GlowHomePageState(int vendorId);

  final PageController _addressPageCtrl = PageController(viewportFraction: 0.9);
  int _addressPage = 0;

  @override
  void initState() {
    super.initState();

    PermissionHelper.requestLocationPermission(context);
    _initialize();
    _isLoading = true;
    copyVendorId = widget.vendorId;

    // Initialize with empty states
    timeSlots = [];
    isSelected = [];
    serviceList = [];
    ReviewsList = [];

    // Load data with proper error handling
    _loadVendorData().catchError((error) {
      print('Error in initial data load: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadVendorData() async {
    if (!mounted) return;

    try {
      // First load vendor profile
      await getVendorProfile(context, copyVendorId.toString());

      //if (!mounted) return;

      // Then load services with a small delay
      /* await Future.delayed(Duration(milliseconds: 100));
      await getServicesProvidedByVendor(context, copyVendorId.toString());*/
      // await getServiceLocationsProvidedByVendor(context, copyVendorId.toString());

      //if (!mounted) return;

      /*  await Future.delayed(Duration(milliseconds: 100));
      await getVendorReviews(context, copyVendorId.toString());*/

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading vendor data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Initialize empty states
          ReviewsList = [];
          serviceList = [];
          timeSlots = [];
          isSelected = [];
        });
      }
    }
  }

  getServiceLocationsProvidedByVendor(
      BuildContext context, String copyVendorId) async {
    if (!mounted) return;

    try {
      final bloc = APIBloC();
      final value = await bloc.getRentalLocations(copyVendorId);

      if (!mounted) return;
      setState(() {
        rentalLocationList = value?.rental_address ?? [];
      });
    } catch (e) {
      print('Error fetching services: $e');
      if (mounted) {
        setState(() {
          if (rentalLocationList.isEmpty) {
          } else {}
        });
        showErrorSnackbar(
            context, 'Unable to fetch services. Please try again.');
      }
    }
  }

  Future<Position> getCurrentLocation() async {
    try {
      return await _locationService.getCurrentLocation();
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  void fetchLocation() async {
    try {
      final latLng = await _locationService.getCurrentLatLng();
      setState(() {
        _currentLocation = latLng;
      });
      print('Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}');
    } catch (e) {
      print('Error fetching location: $e');
      // Show error to user if needed
    }
  }

  Future<void> getVendorProfile(
      BuildContext context, String copyVendorId) async {
    try {
      _bloc = APIBloC();
      final value = await _bloc?.getVendorProfileData(copyVendorId);

      if (!mounted) return;

      if (value?.message == "Unauthorized") {
        //showAlertDialog();
        getToken(context);

        return;
      }

      if (value != null) {
        setState(() {
          vendorImage = value.user?.profile_image ?? '';
          des = value.user?.about_me ?? '';
          professionalName = (value.business_name?.trim().isNotEmpty == true)
              ? value.business_name!.trim()
              : (value.professional_name?.trim().isNotEmpty == true)
                  ? value.professional_name!.trim()
                  : '';
          professionalAddress = (value.location?.isNotEmpty == true)
              ? value.location!
              : (value.service_location?.address1?.isNotEmpty == true)
                  ? value.service_location!.address1!
                  : (value.service_location?.address2?.isNotEmpty == true)
                      ? value.service_location!.address2!
                      : '';
          profileImage = value.user?.profile_image ?? '';
          rentalLocationList = value?.rental_address ?? [];
          hasAddresses =
              rentalLocationList != null && rentalLocationList!.isNotEmpty;

          print("rental_address " + value!.rental_address.toString());

          print("rentalLocationList " + rentalLocationList.toString());
          print("hasAddresses " + hasAddresses.toString());

          //rentalLocationList = value?.rental_address ?? [];

          // Update location if available
          if (value.service_location?.service_latitude != null &&
              value.service_location?.service_longitude != null) {
            try {
              final lat =
                  double.parse(value.service_location!.service_latitude!);
              final lng =
                  double.parse(value.service_location!.service_longitude!);
              _currentLocation = LatLng(lat, lng);

              getServicesProvidedByVendor(context, copyVendorId.toString());
              getVendorReviews(context, copyVendorId.toString());

              // Update map location in next frame to prevent UI jank
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _updateMapLocation(lat, lng);
                }
              });
            } catch (e) {
              print('Error parsing location: $e');
            }
          }

          // Update business hours
          hoursByAPI.clear();
          if (value.service_hours != null) {
            for (var hour in value.service_hours!) {
              if (hour.day != null &&
                  hour.from_time != null &&
                  hour.to_time != null) {
                hoursByAPI[hour.day!] =
                    '${DateConverter.convertTimeFormat1(hour.from_time!)}-${DateConverter.convertTimeFormat1(hour.to_time!)}';
              }
            }
            hours.addAll(hoursByAPI);
          }
        });
      }
    } catch (e) {
      print('Error fetching vendor profile: $e');
      rethrow;
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

          getVendorProfile(context, copyVendorId.toString());
        });
      }
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  Future<void> getServicesProvidedByVendor(
      BuildContext context, String copyVendorId) async {
    if (!mounted) return;

    try {
      final bloc = APIBloC();
      final value =
          await bloc.getServicesProvidedByVendor(copyVendorId).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('Timeout fetching services');
          return null;
        },
      ).catchError((error) {
        print('Error fetching services: $error');
        return null;
      });

      if (!mounted) return;

      setState(() {
        serviceList = value ?? [];
        GlowHomePage.serviceListSelection =
            List<bool>.filled(serviceList.length, false);

        if (serviceList.isNotEmpty) {
          _selectedServiceId = serviceList[0].service_id.toString();

          // Schedule working hours fetch with debounce
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted && _selectedServiceId.isNotEmpty) {
              final date = DateConverter.convertDateFormat1(
                  _selectedDateValue.toString().split(" ")[0]);

              // Validate date before making the call
              if (date.isNotEmpty) {
                getVendorWorkingHours(
                    context, copyVendorId, date, _selectedServiceId);
              }
            }
          });
        } else {
          _selectedServiceId = "";
          timeSlots = [];
          isSelected = [];
        }
      });
    } catch (e) {
      print('Error fetching services: $e');
      if (mounted) {
        setState(() {
          serviceList = [];
          GlowHomePage.serviceListSelection = [];
          _selectedServiceId = "";
          timeSlots = [];
          isSelected = [];
        });
        showErrorSnackbar(
            context, 'Unable to fetch services. Please try again.');
      }
    }
  }

  // Update date validation helper
  bool _isValidDate(DateTime date) {
    final now = DateTime.now();
    final minDate = now.subtract(Duration(days: 1)); // Can't book in the past
    final maxDate = now.add(
        Duration(days: _maxBookingDaysAhead)); // Can book up to 90 days ahead
    return date.isAfter(minDate) && date.isBefore(maxDate);
  }

  // Add helper to check if date is within booking window
  bool _isWithinBookingWindow(DateTime date) {
    final now = DateTime.now();
    final daysDifference = date.difference(now).inDays;
    return daysDifference >= _minBookingDaysAhead &&
        daysDifference <= _maxBookingDaysAhead;
  }

  // Add helper to get available booking dates
  List<DateTime> _getAvailableBookingDates() {
    final now = DateTime.now();
    final maxDate = now.add(Duration(days: _maxBookingDaysAhead));
    final dates = <DateTime>[];

    var currentDate = now;
    while (currentDate.isBefore(maxDate)) {
      // Skip dates in the past
      if (currentDate.isAfter(now.subtract(Duration(days: 1)))) {
        dates.add(currentDate);
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    return dates;
  }

  Future<void> getVendorWorkingHours(BuildContext context, String copyVendorId,
      String appointment_date, String service_id) async {
    if (!mounted) return;

    // Prevent rapid API calls
    if (_isLoadingWorkingHours) {
      print('Working hours request already in progress');
      return;
    }

    final now = DateTime.now();
    if (_lastWorkingHoursCall != null &&
        now.difference(_lastWorkingHoursCall!) < _minCallInterval) {
      print('Working hours request too soon after last call');
      return;
    }

    try {
      setState(() {
        _isLoadingWorkingHours = true;
      });
      _lastWorkingHoursCall = now;

      // Validate inputs before making the API call
      if (copyVendorId.isEmpty ||
          appointment_date.isEmpty ||
          service_id.isEmpty) {
        print('Invalid parameters for working hours request');
        _handleWorkingHoursError();
        return;
      }

      // Validate the date
      final dateParts = appointment_date.split('-');
      if (dateParts.length != 3) {
        print('Invalid date format: $appointment_date');
        _handleWorkingHoursError();
        return;
      }

      try {
        final year = int.parse(dateParts[2]);
        final month = int.parse(dateParts[1]);
        final day = int.parse(dateParts[0]);
        final date = DateTime(year, month, day);

        if (!_isWithinBookingWindow(date)) {
          print('Date outside booking window: $appointment_date');
          _handleWorkingHoursError();
          return;
        }
      } catch (e) {
        print('Error parsing date: $appointment_date');
        _handleWorkingHoursError();
        return;
      }

      // Create a new bloc instance for each call
      final bloc = APIBloC();

      // Add timeout and error handling
      final value = await bloc
          .getVendorWorkingHours(copyVendorId, appointment_date, service_id)
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('Timeout fetching working hours');
          return null;
        },
      ).catchError((error) {
        print('Error fetching working hours: $error');
        return null;
      });

      if (!mounted) return;

      // Handle the response
      if (value != null && value.all_slots != null) {
        // Filter available slots
        final availableSlots = value.all_slots!
            .where((slot) => !(value.booked_slots ?? []).contains(slot))
            .toList();

        if (mounted) {
          setState(() {
            timeSlots = availableSlots;
            isSelected = List<bool>.filled(timeSlots.length, false);
          });
        }
      } else {
        // Handle empty or null response
        _handleEmptyWorkingHours();
      }
    } catch (e) {
      print('Error in working hours request: $e');
      _handleWorkingHoursError();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWorkingHours = false;
          if (_isLoading) {
            _isLoading = false;
          }
        });
      }
    }
  }

  void _handleWorkingHoursError() {
    if (mounted) {
      setState(() {
        timeSlots = [];
        isSelected = [];
      });
      // Show error to user
      showErrorSnackbar(
          context, 'Unable to fetch available time slots. Please try again.');
    }
  }

  void _handleEmptyWorkingHours() {
    if (mounted) {
      setState(() {
        timeSlots = [];
        isSelected = [];
      });

      // Show appropriate message based on selected date
      final selectedDate = _selectedDateValue;
      if (selectedDate != null) {
        final daysDifference = selectedDate.difference(DateTime.now()).inDays;
        if (daysDifference > _maxBookingDaysAhead) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Bookings are only available up to $_maxBookingDaysAhead days in advance.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'No available time slots for the selected date. Please try another date.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> getVendorReviews(
      BuildContext context, String copyVendorId) async {
    try {
      _bloc = APIBloC();
      final value = await _bloc?.getVendorReviews(copyVendorId);

      if (!mounted) return;

      // Handle empty reviews gracefully
      setState(() {
        ReviewsList = value ?? [];
        // Don't set _isLoading here as it's managed by _loadVendorData
      });
    } catch (e) {
      print('Error fetching reviews: $e');
      // Handle error gracefully without throwing
      if (mounted) {
        setState(() {
          ReviewsList = [];
        });
      }
    }
  }

  Future<void> createAppointment(
      BuildContext context, AppointmentInputData appointmentInputData) async {
    _bloc = APIBloC();
    _bloc?.createAppointment(appointmentInputData).then((value) {
      this.setState(() {
        // _isLoading = false;
        _isBooking = false;
        if (value?.message == null) {
          print("Resssponnnssee1112222${(value?.vendor_id.toString())!}");
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return Dialog(
                backgroundColor: Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Booking Successful!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your service has been successfully booked.',
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
                          onPressed: () {
                            Navigator.pop(dialogContext); // Close dialog
                            Navigator.pop(context); // Close GlowHomePage
                            Future.delayed(const Duration(milliseconds: 100), () {
                              BottomTabBar.selectFourthTab();
                            });
                          },
                          child: Text(
                            'Go to Bookings',
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
        } else {
          // Show error message from API
          String errorMessage = value?.message ?? 'Failed to book service. Please try again.';
          showErrorSnackbar(context, errorMessage);
        }
      });
    }).catchError((error) {
      print('Error creating appointment: $error');
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
        showErrorSnackbar(context, 'Failed to book service. Please try again.');
      }
    });
  }

  Future<void> _updateMapLocation(double latitude, double longitude) async {
    try {
      final GoogleMapController controller = await _mapController.future;

      if (!mounted) return;

      setState(() {
        _currentLocation = LatLng(latitude, longitude);
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId(_currentLocation.toString()),
            position: _currentLocation!,
            infoWindow: InfoWindow(
              title: 'Location',
              snippet:
                  '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
            ),
          ),
        );
      });

      // Animate camera in next frame
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          try {
            await controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _currentLocation!,
                  zoom: 14.0,
                ),
              ),
            );
          } catch (e) {
            print('Error animating camera: $e');
          }
        }
      });
    } catch (e) {
      print('Error updating map location: $e');
    }
  }

  void showAlertDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Server Error!'),
            content: const Text(
                'The server found one or more errors in the information that you sent..'),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor1),
                  onPressed: () async {
                    //Navigator.pop(context);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                (TrendTodayLogin(from: "Appointment"))),
                        (Route<dynamic> route) => false);
                  },
                  child: const Text('Ok')),
            ],
          );
        });
  }

  void showAlertDialog1() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Missing Details...'),
            actions: [
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: theme_color2),
                  onPressed: () async {
                    Navigator.pop(context);
                    /* SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            (TrendTodayLogin(from: "Appointment"))),
                            (Route<dynamic> route) => false);*/
                  },
                  child: const Text('Ok')),
            ],
          );
        });
  }

  Future<void> getServiceDetails(BuildContext context) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.getServiecs();
      print("Response: " + ("" + value.toString()!!));
      setState(() async {});
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  Widget _buildSkeletonLoader() {
    return Stack(
        children: [
        // Orange gradient background with pattern (matching the main content)
          Container(
          height: MediaQuery.of(context).size.height * 0.35,
                        width: double.infinity,
                        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.4, 1.0],
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        ),
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
                      color: Color(0xFFA773F7).withOpacity(0.4),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA773F7)),
                        backgroundColor: Color(0xFFA773F7).withOpacity(0.2),
                              ),
                            ),
                    // Inner gradient circle
                  Container(
                      width: 60,
                      height: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFA773F7).withOpacity(0.15),
                                boxShadow: [
                                  BoxShadow(
                            color: Color(0xFFA773F7).withOpacity(0.5),
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
                  color: Color(0xFFA773F7),
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: _isLoading
            ? _buildSkeletonLoader()
            : Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
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
                  // Content
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildBackButton(),
                                _buildHeader(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                  child: _buildSegmentedControl(),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 40.0),
                                    child: _buildContent(),
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
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  String result = "refresh data";
                  Navigator.pop(context, result);
                },
                borderRadius: BorderRadius.circular(22),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              professionalName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: "Poppins",
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12, bottom: 20),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E), // Premium dark grey
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile image with a premium look
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFA773F7).withOpacity(0.3),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Color(0xFFA773F7),
                width: 2.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: vendorImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: vendorImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.white.withOpacity(0.05),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA773F7)),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.white.withOpacity(0.05),
                          child: Image.asset(
                            'assets/images/nl.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.white.withOpacity(0.05),
                        child: Image.asset(
                          'assets/images/nl.png',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(width: 18),
          // Name and location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  professionalName,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: Color(0xFFA773F7),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        professionalAddress.isNotEmpty ? professionalAddress : "Location not available",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0, bottom: 8),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildSegmentedControlItem('About', 0, Icons.info_outline_rounded),
          _buildSegmentedControlItem('Book', 1, Icons.calendar_today_rounded),
          _buildSegmentedControlItem('Review', 2, Icons.star_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildSegmentedControlItem(String text, int index, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
            color: isSelected ? Color(0xFFA773F7).withOpacity(0.15) : Colors.transparent,
            border: isSelected ? Border.all(color: Color(0xFFA773F7).withOpacity(0.3), width: 1) : Border.all(color: Colors.transparent, width: 1),
            borderRadius: BorderRadius.circular(10),
        
      ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.white54,
              ),
              SizedBox(width: 6),
              Flexible(
        child: Text(
          text,
                  overflow: TextOverflow.ellipsis,
          style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
            fontFamily: "Poppins",
                    letterSpacing: -0.2,
          ),
        ),
      ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationToggleItem(String text, IconData icon, int index) {
    bool isSelected = isSelectedToggle[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          for (int i = 0; i < isSelectedToggle.length; i++) {
            isSelectedToggle[i] = i == index;
          }
          selectedType = index == 0 ? "CUSTOMER" : "VENDOR";
          print("Selected: $selectedType");
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFA773F7).withOpacity(0.15) : Colors.transparent,
            border: isSelected ? Border.all(color: Color(0xFFA773F7).withOpacity(0.3), width: 1) : Border.all(color: Colors.transparent, width: 1),
          borderRadius: BorderRadius.circular(10),
          
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Color(0xFFA773F7) : Color(0xFF6B7280),
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Color(0xFFA773F7) : Color(0xFF6B7280),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildAboutContent();
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Service Selection Section
            Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8, bottom: 8),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(0xFFA773F7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 12),
                        
                        Expanded(
                          child: Text(
                            'Select a Service',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.8,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Services List
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: _scrollController,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: serviceList!.length!,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: index < serviceList!.length! - 1 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () {
                              print('Item tapped: $index');
                              setState(() {});
                            },
                            child: ServiceItem(
                              image: vendorImage,
                              name: serviceList![index].service!,
                              amount: serviceList![index].cost.toString()!,
                              duration:
                                  serviceList![index].service_minutes.toString()!,
                              isSelected: GlowHomePage.serviceListSelection![index],
                              onPressed: () {
                                setState(() {
                                  GlowHomePage.serviceListSelection[index] =
                                      !GlowHomePage.serviceListSelection[index];

                                  print(
                                      "GlowHomePage.serviceListSelection[index] " +
                                          GlowHomePage.serviceListSelection[index]
                                              .toString());
                                  if (GlowHomePage.serviceListSelection[index] ==
                                      true) {
                                    _selectedServices.add((serviceList![index]
                                        .service_id
                                        .toString())!);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Date and Time Selection Section
            Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12, bottom: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                'Select Time and Date',
                style: TextStyle(
                          fontSize: 16,
                  fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.4,
                ),
              ),
                    ],
            ),
                  SizedBox(height: 16),
            _buildDatePicker(),
                  SizedBox(height: 16),
                  if (_isLoadingWorkingHours)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFFA773F7),
                        ),
                      ),
                    )
                  else if (timeSlots.isNotEmpty)
                    GridView.builder(
                      itemCount: timeSlots!.length,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 2.8,
                      ),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex1 = index;
                              _selectedTimeValue = timeSlots[index];
                            });
                          },
                          child: TimeSlotItem(
                            time: timeSlots[index],
                            isSelected: selectedIndex1 == index,
                          ),
                        );
                      },
                    )
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'No time slots available for this date.',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Location Selection Header
            Container(
              margin: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose the place you would like to avail the service',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                            letterSpacing: -0.1,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Location Type Toggle
            Container(
              margin: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 0, bottom: 0),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildLocationToggleItem(
                      'Customer Location',
                      Icons.person_outline_rounded,
                      0,
                    ),
                  ),
                  if (hasAddresses)
                    Expanded(
                      child: _buildLocationToggleItem(
                        'Vendor Outlet',
                        Icons.store_outlined,
                        1,
                      ),
                    ),
                ],
              ),
            ),

            // ---- Address Section ----
            hasAddresses && selectedType == "VENDOR"
                ? Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 12, bottom: 0),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                      children: [
                        Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFFA773F7).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFA773F7),
                                size: 18,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                            'Select Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.4,
                            ),
                          ),
                          ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: Column(
                            children: [
                              Expanded(
                                child: PageView.builder(
                                  controller: _addressPageCtrl,
                                  itemCount: rentalLocationList.length,
                                  onPageChanged: (i) =>
                                      setState(() => _addressPage = i),
                                  itemBuilder: (context, index) {
                                    final a = rentalLocationList[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: AddressCard(
                                        title: 'Address ' + index.toString(),
                                        line1: a.address!,
                                        line2: a.address!,
                                        isSelected:
                                            selectedAddressIndex == index,
                                        onSelect: (v) {
                                          setState(() {
                                            selectedAddressIndex =
                                                v == true ? index : null;
                                            if (v == true) {
                                              selected.add(index);
                                            } else {
                                              selected.remove(index);
                                            }

                                            if (v == true) {
                                              selectedAddressIndex = index;
                                              selectedLat = double.tryParse(
                                                  a.latitude ?? '');
                                              selectedLng = double.tryParse(
                                                  a.longitude ?? '');
                                            } else {
                                              selectedAddressIndex = null;
                                              selectedLat = null;
                                              selectedLng = null;
                                            }
                                          });
                                        },
                                        onViewMap: () {
                                          if (a.longitude != null &&
                                              a.latitude != null) {
                                            openExternalMap(
                                                lat: double.tryParse(
                                                    a.latitude ?? ''),
                                                lng: double.tryParse(
                                                    a.longitude ?? ''),
                                                label: a.address);
                                          } else {
                                            final q = Uri.encodeComponent(
                                                a.address ?? 'Location');
                                            launchUrl(
                                              Uri.parse(
                                                  'https://www.google.com/maps/search/?api=1&query=$q'),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Dot indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                    rentalLocationList.length, (i) {
                                  final bool active = i == _addressPage;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    height: 6,
                                    width: active ? 16 : 6,
                                    decoration: BoxDecoration(
                                      gradient: active
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
                                      color: active ? null : Color(0xFFD1D5DB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),

            // Book A Service button

            Container(
              margin: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 24, bottom: 20),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Color(0xFFA773F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isBooking
                    ? null
                    : () {
                        if (ConstantVariable.authToken == null || ConstantVariable.authToken!.isEmpty) {
                          LoginPrompt.show(context);
                          return;
                        }
                        setState(() {
                          _isBooking = true;
                        });
                        if (_selectedDateValue != null &&
                            _selectedTimeValue != null &&
                            _selectedTimeValue.length != 0 &&
                            _selectedServices.isNotEmpty) {
                          // Validate that the selected date and time are not in the past
                          try {
                            DateTime now = DateTime.now();
                            DateTime selectedDate = _selectedDateValue!;
                            
                            // Parse the time string (format: "10:00 AM" or "10:00:00 AM")
                            String timeStr = _selectedTimeValue.trim();
                            int hour = 0;
                            int minute = 0;
                            
                            // Handle different time formats
                            if (timeStr.contains("AM") || timeStr.contains("PM")) {
                              // Format: "10:00 AM" or "10:00:00 AM"
                              bool isPM = timeStr.toUpperCase().contains("PM");
                              String timeOnly = timeStr.replaceAll(RegExp(r'[APM\s]'), '');
                              List<String> timeParts = timeOnly.split(':');
                              hour = int.parse(timeParts[0]);
                              minute = int.parse(timeParts[1]);
                              
                              if (isPM && hour != 12) {
                                hour += 12;
                              } else if (!isPM && hour == 12) {
                                hour = 0;
                              }
                            } else {
                              // Format: "10:00" or "10:00:00"
                              List<String> timeParts = timeStr.split(':');
                              hour = int.parse(timeParts[0]);
                              minute = int.parse(timeParts[1]);
                            }
                            
                            // Create DateTime with selected date and time
                            DateTime appointmentDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              hour,
                              minute,
                            );
                            
                            // Check if the appointment time is in the past
                            if (appointmentDateTime.isBefore(now)) {
                              _isBooking = false;
                              showErrorSnackbar(
                                  context, 'Service date and time cannot be in the past. Please select a future date and time.');
                              return;
                            }
                          } catch (e) {
                            print('Error validating date and time: $e');
                            _isBooking = false;
                            showErrorSnackbar(
                                context, 'Invalid date or time format. Please try again.');
                            return;
                          }
                          
                          AppointmentInputData xyz = AppointmentInputData();
                          xyz.vendor_id = copyVendorId.toString();
                          xyz.service_location = selectedType;
                          if (selectedLat != null) {
                            xyz.vendor_latitude = selectedLat.toString();
                            xyz.vendor_longitude = selectedLng.toString();
                          } else {
                            xyz.vendor_latitude = "";
                            xyz.vendor_longitude = "";
                          }

                          xyz.service_details = [];

                          for (int i = 0; i < _selectedServices.length; i++) {
                            ServiceDetails xyz1 = ServiceDetails();
                            xyz1.quantity = "1";
                            xyz1.service_date =
                                DateConverter.convertDateFormat1(
                                    (_selectedDateValue
                                        .toString()
                                        .split(" "))[0]);
                            xyz1.service_time = _selectedTimeValue.toString();
                            xyz1.service_id = _selectedServices[i].toString();
                            xyz.service_details?.add(xyz1);
                          }

                          ConstantVariable.appointmentInputData = xyz;

                          if (ConstantVariable.authToken!.isNotEmpty) {
                            createAppointment(
                                context, ConstantVariable.appointmentInputData);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TrendTodayLogin(from: "Appointment"),
                              ),
                            );
                          }
                        } else {
                          _isBooking = false;
                          showErrorSnackbar(
                              context, 'Please select date and time slot');
                        }
                      },
                child: _isBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Book a Service',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins",
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
            ),
          ],
        ); // Center(child: Text('Staff Content'));
      case 2:
        return Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader1(),
              const SizedBox(height: 16),
              ReviewsList.length > 0
                  ? _buildReviewsList()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(48),
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
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.star_outline_rounded,
                              size: 48,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No Reviews Yet',
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 20,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Be the first to share your experience',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                      ],
                    )
            ],
          ),
        );
      /*Center(child: Text('Comming Soon'));*/
      default:
        return SizedBox.shrink();
    }
  }

  void showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.black,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            // Optional: Add code to handle the dismiss action if needed
          },
        ),
      ),
    );
  }

  Widget _buildAboutContent() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(0xFFA773F7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 12),
                      
                      Expanded(
                        child: Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            fontFamily: "Poppins",
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.8,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Section
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Text(
                    des != null && des.isNotEmpty ? des : "No description available.",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(top: 0),
            height: MediaQuery.of(context).size.height * 0.18,
                decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFFF3E8FF),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation ?? LatLng(0.0, 0.0),
                      zoom: 14.0,
                    ),
                    mapType: MapType.normal,
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController?.complete(controller);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    gestureRecognizers: Set()
                      ..add(Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      )),
                    padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                  ),
                  // Compact Map Controls Overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                  color: Color(0xFF6B7280),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.2),
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
                                  color: Color(0xFF6B7280),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.2),
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
                                  color: Color(0xFFA773F7).withOpacity(0.15),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(14),
                                    bottomRight: Radius.circular(14),
                                  ),
                                ),
                                child: Icon(
                                  Icons.my_location_rounded,
                                  color: Colors.white,
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
                  if (_markers.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                color: Color(0xFFA773F7).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.2,
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
          ),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(0xFFA773F7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 12),
                Text(
                  'Business Hours',
                  style: TextStyle(
                    fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Poppins",
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                  ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildBusinessHours(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessHours() {
    final today = DateTime.now();
    final currentDay = weekList[today.weekday % 7];
    
    return Column(
      children: hours.entries.map((entry) {
        final isToday = entry.key == currentDay;
        final isClosed = entry.value.toLowerCase().contains('closed');
        
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isToday 
                ? Color(0xFFF3E8FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isToday 
                  ? Color(0xFFA773F7).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              width: isToday ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3,
                height: 28,
                decoration: BoxDecoration(
                  gradient: isToday
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
                  color: isToday ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                child: Text(
                  entry.key,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                          fontFamily: "Poppins",
                          color: isToday ? Color(0xFFA773F7) : Color(0xFF6B7280),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (isToday) ...[
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Color(0xFFA773F7).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins",
                    color: Color(0xFFA773F7),
                            letterSpacing: 0.1,
                  ),
                ),
              ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(
                isClosed ? Icons.close_rounded : Icons.schedule_rounded,
                size: 14,
                color: isClosed 
                    ? Color(0xFFEF4444)
                    : (isToday ? Color(0xFFA773F7) : Color(0xFF6B7280)),
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  entry.value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                    fontFamily: "Poppins",
                    color: isClosed 
                        ? Color(0xFFEF4444)
                        : (isToday ? Color(0xFFA773F7) : Color(0xFF6B7280)),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader1() {
    return Container(
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(0xFFA773F7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              
              Expanded(
                child: Text(
                  'Ratings & Reviews',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Poppins",
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.8,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFFA773F7),
                  size: 16,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'All reviews from verified Trend Today customers',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
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

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Color(0xFFFACC15), size: 20);
        } else if (index == rating.floor() && rating % 1 > 0) {
          return const Icon(Icons.star_half,
              color: Color(0xFFFACC15), size: 20);
        }
        return const Icon(Icons.star_border,
            color: Color(0xFFFACC15), size: 20);
      }),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterDropdown('Filter by'),
          const SizedBox(width: 12),
          _buildFilterDropdown('Sort by'),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'Select one',
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              items: <String>['Select one', 'Option 1', 'Option 2', 'Option 3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Add state management here
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    return Column(
      children: [
        SizedBox(height: 24),
        _buildReviewCard(
          name: 'Margaret Simon',
          rating: 4.5,
          date: '4 September 2023',
          comment:
              'Beth did an amazing job helping me get decked up for my wedding! She was OUTSTANDING! She was extremely knowledgeable on the latest trends, what I needed to do to get top dollar for my big day and did a great job.',
          hasReply: true,
        ),
        const SizedBox(height: 16),
        _buildReviewCard(
          name: 'Jameson Thacher',
          rating: 5.0,
          date: '4 September 2023',
          comment:
              'Beth did an amazing job helping me get decked up for my wedding! She was OUTSTANDING! She was extremely knowledgeable on the latest trends, what I needed to do to get top dollar for my big day and did a great job.',
          hasReply: true,
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required double rating,
    required String date,
    required String comment,
    required bool hasReply,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image with gradient border
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFA773F7).withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFA773F7).withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      'https://picsum.photos/44',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white.withOpacity(0.05),
                        child: Icon(
                          Icons.person_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 24,
                        ),
                      ),
                    ),
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
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Poppins",
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        // Rating stars
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating.floor()
                                  ? Icons.star_rounded
                                  : (index == rating.floor() && rating % 1 > 0)
                                      ? Icons.star_half_rounded
                                      : Icons.star_border_rounded,
                              color: Color(0xFFFACC15),
                              size: 14,
                            );
                          }),
                        ),
                        SizedBox(width: 6),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins",
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(width: 6),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              comment,
              style: TextStyle(
                fontSize: 14,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w400,
                color: Color(0xFF1F2937),
                height: 1.5,
                letterSpacing: -0.1,
              ),
            ),
          ),
          if (hasReply) ...[
            SizedBox(height: 14),
            _buildReply(),
          ],
        ],
      ),
    );
  }

  Widget _buildReply() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAFAFA),
            Color(0xFFF3E8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Color(0xFFA773F7).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFA773F7).withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFA773F7).withOpacity(0.2),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://picsum.photos/32',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white.withOpacity(0.05),
                    child: Icon(
                      Icons.business_rounded,
                      color: Color(0xFFA773F7),
                      size: 18,
                    ),
                  ),
                ),
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
                    Text(
                      professionalName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Poppins",
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFA773F7).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Vendor',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins",
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "Thank you for your kind words! It was a pleasure helping you prepare for your special day. I'm so glad I could contribute to making your wedding experience perfect.",
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final availableDates = _getAvailableBookingDates();
    final now = DateTime.now();
    final maxDate = now.add(Duration(days: _maxBookingDaysAhead));

    // Get the currently selected month name
    final String monthName = _selectedDateValue != null
        ? DateFormat('MMMM yyyy').format(_selectedDateValue!)
        : DateFormat('MMMM yyyy').format(DateTime.now());

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month name above the calendar
          Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              monthName,
              style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 15,
              fontWeight: FontWeight.w700,
                fontFamily: "Poppins",
              letterSpacing: -0.3,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
          height: 65,
            width: double.infinity,
            child: DatePicker(
              DateTime.now(),
              initialSelectedDate: _selectedDateValue ?? DateTime.now(),
            selectionColor: Color(0xFFA773F7),
              selectedTextColor: Colors.white,
              dayTextStyle: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 9,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
                height: 0.7,
              ),
              monthTextStyle: TextStyle(
                color: Colors.transparent,
                fontSize: 0,
                fontWeight: FontWeight.w400,
              ),
              dateTextStyle: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
                height: 0.9,
              ),
              onDateChange: (date) {
                if (date.isBefore(now) || date.isAfter(maxDate)) {
                  showErrorSnackbar(context,
                      'Please select a date between today and $_maxBookingDaysAhead days from now');
                  return;
                }
                setState(() {
                  _selectedDateValue = date;
                  timeSlots = [];
                  isSelected = [];
                  if (_selectedServiceId.isNotEmpty) {
                    final formattedDate = DateConverter.convertDateFormat1(
                        date.toString().split(" ")[0]);
                    Future.delayed(Duration(milliseconds: 300), () {
                      if (mounted) {
                        getVendorWorkingHours(context, copyVendorId.toString(),
                            formattedDate, _selectedServiceId);
                      }
                    });
                  }
                });
              },
            ),
          ),
        ],
    );
  }

  @override
  void dispose() {
    // Cancel any pending operations
    _bloc = null;
    _locationService.dispose();
    // Comment out map controller disposal
    //_mapController.future.then((controller) => controller.dispose());
    _scrollController.dispose();
    _isLoadingWorkingHours = false;
    _lastWorkingHoursCall = null;
    _addressPageCtrl.dispose();

    // Clear any pending state updates
    if (mounted) {
      setState(() {
        _isLoading = false;
        ReviewsList = [];
        serviceList = [];
        timeSlots = [];
        isSelected = [];
        // Comment out markers clear
        //_markers.clear();
      });
    }
    super.dispose();
  }
}

class TimeSlotItem extends StatelessWidget {
  const TimeSlotItem({
    required this.time,
    required this.isSelected,
  });

  final String time;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? Colors.black
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        
      ),
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontFamily: "Poppins",
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// Pattern painter for orange gradient background
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
