import 'package:flutter/material.dart';

import 'Utility/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';


void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
            child: AppointmentGridView(
              name: '',
              time: '',
              date: '',
              image: "",
              address: "",
            )),
      ),
    ),
  );
}

class AppointmentGridView extends StatelessWidget {
  const AppointmentGridView({
    required this.name,
    required this.time,
    required this.date,
    required this.image,
    this.fallbackImage,
    required this.address,
  });

  final String name;
  final String time;
  final String date;
  final String image;
  final String? fallbackImage;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background image that fills the entire container with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(16), // Match the parent container's radius
            child: (image.isNotEmpty)
                ? CachedNetworkImage(
              imageUrl: image,
              width: MediaQuery.of(context).size.width,
              height: double.infinity, // Ensures full height coverage
              fit: BoxFit.cover,       // Ensures image covers the whole container
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Color(0xFFA773F7)),
              ),
              errorWidget: (context, url, error) {
                if (fallbackImage != null && fallbackImage!.isNotEmpty) {
                  return CachedNetworkImage(
                    imageUrl: fallbackImage!,
                    width: MediaQuery.of(context).size.width,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFFA773F7)),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/nl.png',
                      width: MediaQuery.of(context).size.width,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return Image.asset(
                  'assets/images/nl.png',
                  width: MediaQuery.of(context).size.width,
                  height: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            )
                : (fallbackImage != null && fallbackImage!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: fallbackImage!,
                      width: MediaQuery.of(context).size.width,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFA773F7)),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/nl.png',
                        width: MediaQuery.of(context).size.width,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/nl.png',
                      width: MediaQuery.of(context).size.width,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
          ),

          // Bottom content: rating and name
          Positioned(
            bottom: 0, // Align the content at the bottom
            left: 0,
            right: 0,
            child: Container(
              height: 70, // Adjust height as needed
              padding: EdgeInsets.all(8.0), // Add some padding
              decoration: BoxDecoration(
                color: Colors.black, // Solid black background instead of translucent
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ), // Background with opacity for readability
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "4.5", // Replace with actual rating value
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      name, // Replace with actual name
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                          fontFamily: "Poppins"

                      ),
                      maxLines: 1, // Restrict to a single line
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      address!, // Replace with actual address
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
