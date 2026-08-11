/*
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worker Profile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WorkerProfilePage(),
    );
  }
}

class WorkerProfilePage extends StatelessWidget {
  final Color primaryColor = Color(0xFFF97316); // Change from 0xFF586BA4 to 0xFFF97316
  final Color gradientStart = Color(0xFFF97316); // Change from 0xFF7971E8 to 0xFFF97316
  final Color gradientEnd = Color(0xFFEA580C); // Change from 0xFF434185 to 0xFFEA580C (a darker shade of orange for gradient)


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(),
              SizedBox(height: 16),
              _buildNameAndEmail(),
              SizedBox(height: 16),
              _buildProfileImage(),
              SizedBox(height: 16),
              _buildApproveButton(),
              SizedBox(height: 16),
              _buildDateTimeInfo(),
              SizedBox(height: 16),
              _buildWorkProgress(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StylishBottomBar(),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.chevron_left, color: Colors.white, size: 20),
        ),
        Container(
          height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ElevatedButton(
            onPressed: () {},
            child: Text(
              'Raise a complain',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leo Dorwart',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Erich.Pfannerstill31@yahoo.com',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://example.com/profile_image.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildApproveButton() {
    return ElevatedButton(
      onPressed: () {},
      child: Text('Approve request to commence work'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDateTimeInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoBox(Icons.calendar_today, 'Date', 'Tuesday, Jan 30'),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildInfoBox(Icons.access_time, 'Time', '12:30'),
        ),
      ],
    );
  }

  Widget _buildInfoBox(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: primaryColor)),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkProgress() {
    return Column(
      children: [
        _buildProgressItem('12:30 PM', 'Work Commenced'),
        SizedBox(height: 16),
        _buildProgressItem('1:30 PM', 'Work in progress'),
      ],
    );
  }

  Widget _buildProgressItem(String time, String status) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFEFECF0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(time, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(status),
        ),
      ],
    );
  }
}

class StylishBottomBar extends StatefulWidget {
  @override
  _StylishBottomBarState createState() => _StylishBottomBarState();
}

class _StylishBottomBarState extends State<StylishBottomBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            _buildNavItem(Icons.dashboard, 'Dashboard'),
            _buildNavItem(Icons.calendar_today, 'Calendar'),
            _buildNavItem(Icons.attach_money, 'Revenue'),
            _buildNavItem(Icons.chat_bubble, 'Chat'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFFA773F7), // Changed from 0xFFF97316
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          elevation: 0,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _selectedIndex == _getIndexForLabel(label)
              ? Color(0xFFF97316).withOpacity(0.1) // Change from 0xFF7971E8 to 0xFFF97316
              : Colors.transparent,
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }

  int _getIndexForLabel(String label) {
    switch (label) {
      case 'Dashboard':
        return 0;
      case 'Calendar':
        return 1;
      case 'Revenue':
        return 2;
      case 'Chat':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}*/
