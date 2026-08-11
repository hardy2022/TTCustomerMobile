import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Utility/constants.dart';
import '../service_item.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
// Set to transparent or same as AppBar/Scaffold color
    statusBarIconBrightness: Brightness.dark, // Brightness of icons
  ));
  runApp(SelectServicePage());
}

class SelectServicePage extends StatefulWidget {
  @override
  _SelectServicePageState createState() => _SelectServicePageState();
}

class _SelectServicePageState extends State<SelectServicePage> {
  int _selectedIndex = 0;
  final Color _segmentedControlColor = segmented_bg;
  ScrollController _scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Set to transparent or same as AppBar/Scaffold color
      statusBarIconBrightness: Brightness.dark, // Brightness of icons
    ));

    return Scaffold(
      backgroundColor: themeColor,
      // Make sure the background color contrasts with the status bar icons
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBackButton(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),

                      Divider(
                        color: Color(0xFFEAEAEA),
                        thickness: 10,
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSelectService(),
                      ),



                      Divider(
                        color: Color(0xFFEAEAEA),
                        thickness: 10,
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:  _buildSelectTimeSlot(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),

      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.35,
              child: Container(
                height: 100,
                width: 140,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login_bg.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hint_txt,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(width: 15),
            Container(
              width: MediaQuery.of(context).size.width * 0.43,
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Get your Glow',
                    style: TextStyle(
                      fontSize: 23,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D386F),
                    ),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildSelectService() {
    return
      Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),
          color: Colors.white,
          child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a service',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _segmentedControlColor,
            ),
          ),
          ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: 5,
            itemBuilder:
                (BuildContext context, int index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      print('Item tapped: $index');
                      print('Item tapped');
                      setState(() {

                      });
                    },
                    child: ServiceItem(

                        image : "https://www.shutterstock.com/image-photo/preparing-massage-oil-dropping-essential-woman-2465757151",
                        name : "Classic facial",
                        amount : 'Starts at 30',
                        duration : ""
                    ),
                  ),

                ],
              );
            },
          ),
        ],
      ));

  }

  Widget _buildSelectTimeSlot() {
    return
      Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0),
          color: Colors.white,
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Time and Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _segmentedControlColor,
                ),
              ),
            ],
          ));

  }
}
