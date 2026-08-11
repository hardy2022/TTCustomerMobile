import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../service_details.dart';
import '../service_item.dart';
import 'BLOC/APIBLoC.dart';
import 'POJO/services_response_data.dart';
import 'Utility/constants.dart';
import 'appointment_List_view_item.dart';
import 'login.dart';

void main() {
  runApp(homeScreenContent());
}

String? loginEmail, loginName, loginImage;
bool _isLoading = false;

class homeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreenContentDemo1(),
    );
  }
}

class HomeScreenContentDemo1 extends StatefulWidget {
  @override
  _HomeScreenContentDemoState createState() => _HomeScreenContentDemoState();
}

class _HomeScreenContentDemoState extends State<HomeScreenContentDemo1> {
  int _selectedIndex = 0;
  Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentLocation = LatLng(19.118826, 72.928508);
  ScrollController _scrollController = ScrollController();
  APIBloC? _bloc;
  final Set<Marker> _markers = {};
  List<ServicesResponseData> _allItems = [];
  List<ServicesResponseData> _filteredItems = [] ;
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();


  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    _searchController.addListener(_onSearchChanged);

    print("HERE @@@####^^^^");
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
      print("Response: " + ("" + value.toString()!!));


      for (var item in value!) {
        _allItems.add(item);
      }


      setState(() async {});
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  Future<void> getLocationBasedServiecs(BuildContext context) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.getLocationBasedServiecs();
      print("Response: " + ("" + value.toString()!!));

      // Now, update the state synchronously
      setState(() async {

        var indexedList = value?.toList().asMap().entries ?? [];

        for (var entry in indexedList) {
          int index = entry.key; // The index
          var item = entry.value; // The item

          _addMarker(
              item.service_latitude ?? "0.0", // Handle nullable latitude
              item.service_longitude ?? "0.0", // Handle nullable longitude
              item.service_city ?? "City", // Handle nullable city
              index // Pass the index
          );
        }

      });
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  Future<void> getProfessionals(BuildContext context) async {
    // Initialize the bloc
    _bloc = APIBloC();

    try {
      // Perform the async registration work
      final value = await _bloc?.getProfessionals("","","");
      print("Response: " + ("" + value.toString()!!));

      // Now, update the state synchronously
      setState(() async {});
    } catch (e) {
      print("Error occurred during registration: $e");
      // Handle any errors here if needed
    }
  }

  void _addMarker(String lat, String long, String cityName, int i) {
    _markers.add(
      Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(lat as double, long as double), // Los Angeles
        infoWindow: InfoWindow(
          title: '' + cityName,
          snippet: '' + cityName,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey_bg1,
      body: _isLoading
          ? new Center(
          child: new CircularProgressIndicator(
            backgroundColor: Colors.blueAccent.shade700,
          ))
          : Container(
          child: SingleChildScrollView(
            child: Container(
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        child: Column(
                          children: [
                            _buildHeader(),
                            _buildSegmentedControl(),
                            _buildSendMessageFooter(),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // Space the tags evenly
                              children: List.generate(
                                  5, (index) => _buildTag()), // 5 Tags
                            )
                          ],
                        )),
                    _selectedIndex == 0
                        ? _buildSegmentedControlData1()
                        : _selectedIndex == 1
                        ? _buildSegmentedControlData2()
                        : _buildSegmentedControlData3()
                  ],
                )),
          )),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),
      child: Column(
        children: [
          SizedBox(width: 10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Dirk',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Check out our various offerings',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Spacer(),
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                    'assets/images/login_bg.png') /*NetworkImage(
        'https://example.com/profile-pic.jpg')*/
                , // Replace with the actual profile picture URL
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme_color1,
        borderRadius: BorderRadius.circular(10),
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
          });
        },
        child: Container(
          height: 40, // Keep the overall height consistent
          padding: EdgeInsets.all(3), // Padding around the item
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            // Reduced vertical padding
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              // Center the text vertically and horizontally
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isSelected ? theme_color1 : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: "Poppins"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendMessageFooter() {
    return Column(children: [
      Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: border_color, // Here you add the border color
                  width: 1.0, // And the width of the border
                ),
              ),
              child: Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.cyan,
                    child: CompositedTransformTarget(
                      link: _layerLink,
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchTextChanged,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                        ),
                      ),
                    ),
                  ),






                  /*Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
                      hintText: 'Message',
                      hintStyle: TextStyle(
                        color:
                        hint_text_clr, // Set the color of the hint text here
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.black, // Border color
                          width: 2.0, // Border width
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      // Background color of the TextField
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: border_color,
                          // Border color when not focused
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: border_color,
                          // Border color when the field is focused
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),*/
                  SizedBox(width: 10),
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle send action
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        // Horizontal padding
                        backgroundColor: Colors.black,
                      ),
                      child: Center(
                        // Center the text within the button
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16, // Font size
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),

      /*Container(
        color: Colors.cyan,
        child: ListView.builder(
          shrinkWrap: true, // To ensure the list doesn't occupy infinite space
          itemCount: _filteredItems.length,
          physics: NeverScrollableScrollPhysics(),  // Disable ListView's scrolling

          itemBuilder: (context, index) {
            return ListTile(
              title: Text((_filteredItems[index].name)!),
              onTap: () {
                print('Selected: ${_filteredItems[index]}');
                // Perform your search or action on the selected item
              },
            );
          },
        ),
      ),*/



    ],);
  }

  Widget _buildTag() {
    return Container(
      height: 30,
      width: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.brown, // Background color of the tag
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: Text(
        'Tag',
        style: TextStyle(
            color: Colors.white, // Text color
            fontSize: 12,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildSegmentedControlData1() {
    setState(() {
      // _isLoading = true;
      getServices(context);
    });
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              'Popular in your area',
              style: TextStyle(
                  color: themeColor, // Text color
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            child: GridView.builder(
              itemCount: 5,
              physics: ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10.0, // Spacing between rows
                crossAxisSpacing: 10.0, // Spacing between columns
                childAspectRatio: 0.9,
              ),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {


                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GlowHomePage(1),
                      ),
                    );
                  },
                  child: Container(
                    child: AppointmentGridView(
                      name: "Name",
                      time: "time",
                      date: "date",
                      image: "image",
                      address: "address",
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

  Widget _buildSegmentedControlData2() {
    setState(() {
      // _isLoading = true;
      getLocationBasedServiecs(context);
    });

    return Container(
      child: Column(
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              // Custom behavior on vertical drag, if needed
            },
            // Wrap the GoogleMap widget in IgnorePointer only when you need specific control
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.35,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 14.0,
                  ),
                  mapType: MapType.normal,
                  markers: _markers,
                  // Pass the markers to the map
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  // Adding gestureRecognizers ensures GoogleMap can handle gestures
                  gestureRecognizers: Set()
                    ..add(Factory<OneSequenceGestureRecognizer>(
                          () =>
                          EagerGestureRecognizer(), // allows all gestures on map
                    )),
                ),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('Item tapped: $index');
                        print('Item tapped');
                        setState(() {});
                      },
                      child: ServiceItem(
                          image:
                          "https://www.shutterstock.com/image-photo/preparing-massage-oil-dropping-essential-woman-2465757151",
                          name: "Classic facial",
                          amount: 'Starts at 30',
                          duration: ""),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSegmentedControlData3() {
    setState(() {
      //_isLoading = true;
      getProfessionals(context);
    });

    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              'Popular in your area',
              style: TextStyle(
                  color: themeColor, // Text color
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            child: GridView.builder(
              itemCount: 5,
              physics: ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10.0, // Spacing between rows
                crossAxisSpacing: 10.0, // Spacing between columns
                childAspectRatio: 0.9,
              ),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    child: AppointmentGridView(
                      name: "Name",
                      time: "time",
                      date: "date",
                      image: "image",
                      address: "address",
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

  void _onSearchChanged() {
    setState(() {
      _filteredItems = _allItems
          .where((item) => item.name!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _onSearchTextChanged(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((item) => item.name!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });

    if (query.isNotEmpty) {
      _showOverlay();
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }




  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    final double compactWidth = 180.0;
    final double itemHeight = 28.0;
    final int maxItems = 5;
    final int displayCount = _filteredItems.length > maxItems ? maxItems : _filteredItems.length;
    final double compactHeight = displayCount * itemHeight + 2; // add slight padding

    return OverlayEntry(
      builder: (context) => Positioned(
        width: compactWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, 40.0), // Slightly reduced offset for compactness
          child: Material(
            elevation: 2.0,
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: compactWidth,
                maxHeight: compactHeight,
              ),
              child: Container(
                margin: EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Color(0xFFE5E7EB), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: displayCount > 0
                      ? ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: displayCount,
                          separatorBuilder: (context, index) => Divider(
                            height: 0.12,
                            thickness: 0.18,
                            color: Color(0xFFF3F4F6),
                            indent: 4,
                            endIndent: 4,
                          ),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: itemHeight,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    print('Selected: ${_filteredItems[index]}');
                                    _searchController.text = (_filteredItems[index].name)!;
                                    _overlayEntry?.remove(); // Remove overlay when an item is selected
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (_filteredItems[index].name)!,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
      ),
    );
  }


}
