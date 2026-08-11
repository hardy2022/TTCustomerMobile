import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../service_details.dart';

import 'Utility/constants.dart';

class LocationBasedItem extends StatelessWidget {
  LocationBasedItem({
    this.image,
    this.name,
    this.amount,
    this.duration,
  });

  final String? image;
  final String? name;
  final String? amount;
  final String? duration;

  // Pass the function to handle the button press

  @override
  Widget build(BuildContext context) {
    var devheight = MediaQuery.of(context).size.height;
    var devwidth = MediaQuery.of(context).size.width;
    double maxWidth = devwidth;
    //DateFormatter formatter = DateFormatter();

    return Container(
      width: devwidth,
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image with Gradient Border
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                  color: Colors.black.withOpacity(0.2),
                ),
                padding: EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11.5),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11.5),
                    child: Image.network(
                      image ?? "assets/images/nl.png",
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Color(0xFFF3F4F6),
                          child: Image.asset(
                            "assets/images/nl.png",
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14),
          // Name and Price Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFFA773F7).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFA773F7).withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    amount!.startsWith("CAD ") ? amount! : "CAD " + amount!,
                    style: TextStyle(
                      color: Color(0xFFA773F7),
                      fontSize: 12,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          // Arrow Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
