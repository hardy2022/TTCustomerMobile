import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../Utility/constants.dart';

import 'chat_screen.dart'; // Replace with your actual import path

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendor Profile',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BeauticianProfilePage(),
    );
  }
}

class BeauticianProfilePage extends StatefulWidget {
  @override
  _BeauticianProfilePageState createState() => _BeauticianProfilePageState();
}

class _BeauticianProfilePageState extends State<BeauticianProfilePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey_bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(context),
              _buildReviews(),
              _buildBookingButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      color: gb,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7971E8), Color(0xFF434185)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.75), width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage('assets/images/login_bg.png'),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 0),
                        child: Text(
                          'Di Acumen',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 0),
                        child: Row(
                          children: [
                            Text('Beautician',
                                style: TextStyle(color: Colors.white)),
                            SizedBox(width: 5),
                            Icon(Icons.star, color: Colors.yellow, size: 16),
                            Text('4.5', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.53,
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 0.0, top: 0),
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 0.0, top: 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.black, size: 16),
                            Text(
                              'Toronto, Ontario',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 5),
                            Spacer(),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'CAD 12.00',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _buildActionButton('Message me', Icons.message),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Services', '3', context),
                _buildStatItem('Clients', '114', context),
                _buildStatItem('Reviews', '18', context),
              ],
            ),
            SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 0),
              child: Text(
                'Convallis viverra pharetra, at arcu sodales pharetra, volutpat. Urna bibendum dui mattis facilisis aliquet nisi euismod sit turpis. Viverra cras laoreet et amet consequat eu nibh. In sagittis adipiscing velit vestibulum, ante feugiat enim. In venenatis vel in ultrices.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF111620),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.white)),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gb, gb],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.all(40),
/*
      color: Colors.white,
*/
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Container(
            height: 150,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildReview(
                    'https://example.com/reviewer_image.jpg',
                    'Theodore Roosevelt',
                    'In sagittis adipiscing velit vestibulum, ante feugiat enim. In venenatis vel in ultrices. Scelerisque molestie enim etiam arcu semper nunc dui lacus. At volutpat ut odio lobortis.'),
                _buildReview(
                    'https://example.com/reviewer_image2.jpg',
                    'Albert Einstein',
                    'In sagittis adipiscing velit vestibulum, ante feugiat enim. In venenatis vel in ultrices. Scelerisque molestie enim etiam arcu semper nunc dui lacus. At volutpat ut odio lobortis.'),
                _buildReview(
                    'https://example.com/reviewer_image2.jpg',
                    'Albert Einstein',
                    'In sagittis adipiscing velit vestibulum, ante feugiat enim. In venenatis vel in ultrices. Scelerisque molestie enim etiam arcu semper nunc dui lacus. At volutpat ut odio lobortis.'),
                // Add more reviews here
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            child: DotsIndicator(
              dotsCount: 3, // Total number of pages
              position: _currentPage.toDouble(),
              decorator: DotsDecorator(
                activeColor: Colors.black,
                size: const Size.square(9.0),
                activeSize: const Size(9.0, 9.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(String imageUrl, String name, String review) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align items at the start (top)

      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(review),
            ],
          ),
        ),
      ],
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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            'Book a service',
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
