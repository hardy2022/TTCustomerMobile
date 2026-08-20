import 'package:flutter/material.dart';
import '../cart_services.dart';
import '../login.dart';
import '../service_details.dart';
import '../vendor_profile.dart';
import '../work_progress.dart';
import 'Utility/constants.dart';
import 'custome.dart';
import 'customer_profile_screen.dart';
import 'home_screen_content.dart';
import 'Utility/login_prompt.dart';


class BottomTabBar extends StatefulWidget {
  // Define a GlobalKey to access the state
  static final GlobalKey<_BottomTabBarState> globalKey = GlobalKey();

  const BottomTabBar({Key? key}) : super(key: key);

  // Static method to select the fourth tab
  static void selectFourthTab() {
   // globalKey.currentState?.setFourthTab();
    globalKey.currentState?.setFourthTab();

  }

  static void selectFirstTab() {
    globalKey.currentState?.setFisrtTab();
  }

  static void selectProfileTab() {
    globalKey.currentState?.setProfileTab();
  }

  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}



class _BottomTabBarState extends State<BottomTabBar> {
  int _selectedIndex = 0;
  late TabController _tabController;


  // Widget options for each tab
  final List<Widget> _widgetOptions = [
    HomeScreenContentDemo(),
    CustomerProfilePage(),
    //BeauticianProfilePage(),
    CartServices(),


  ];

  void setFourthTab() {
    setState(() {

      print("here in selected");
      _selectedIndex = 2; // Set index to 3 for the fourth tab
    });
  }


  void setFisrtTab() {
    setState(() {

      print("here in selected");
      _selectedIndex = 0; // Set index to 3 for the fourth tab
    });
  }

  void setProfileTab() {
    setState(() {
      print("here in selected profile");
      _selectedIndex = 1; // Profile tab is at index 1
    });
  }

  // Handle navigation on tapping different BottomNavigationBar items
  void _onItemTapped(int index) {
    if ((index == 1 || index == 2) && (ConstantVariable.authToken == null || ConstantVariable.authToken!.isEmpty)) {
      LoginPrompt.show(context);
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // The content displayed for the selected tab
      body: _widgetOptions[_selectedIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
        items:<BottomNavigationBarItem>[
            _buildNavItem(Icons.dashboard, 'Home', 0),
            _buildNavItem(Icons.person, 'Profile', 1),
            _buildNavItem(Icons.shopping_cart, 'Bookings', 2),
        ],
        currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
        onTap: _onItemTapped,
        selectedFontSize: 12,
          unselectedFontSize: 11,
        iconSize: 24,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: "Poppins",
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),
        ),
      ),
    );
  }


  void selectFourthTab() {
    setState(() {
      _selectedIndex = 3; // 4th tab has index 3
    });
  }


  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected 
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : [],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
          size: 24,
        ),
      ),
      activeIcon: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
      ),
      label: label,
    );
  }



  int _getIndexForLabel(String label) {
    switch (label) {
      case 'Home':
        return 0;
      case 'Profile':
        return 1;
      case 'Bookings':
        return 2;
      default:
        return 0;
    }
  }



}

