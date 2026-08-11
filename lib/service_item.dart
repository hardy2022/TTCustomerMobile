import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../service_details.dart';

import 'Utility/constants.dart';


void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
            child: ServiceItem(
              image: '',
              name: '',
              amount: "",
              duration: "",
              isSelected: false,


            )),
      ),
    ),
  );
}

class ServiceItem extends StatelessWidget {
  ServiceItem({
    this.image,
    this.name,
    this.amount,
    this.duration,
    this.isSelected,
    this.onPressed,
  });

  final String? image;
  final String? name;
  final String? amount;
  final String? duration;
  final bool? isSelected;
  final VoidCallback? onPressed; // Pass the function to handle the button press


  @override
  Widget build(BuildContext context) {
    var devheight = MediaQuery.of(context).size.height;
    var devwidth = MediaQuery.of(context).size.width;
    double maxWidth = devwidth;
    //DateFormatter formatter = DateFormatter();

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected! 
            ? Color(0xFFF97316).withOpacity(0.3)
            : Color(0xFFE5E7EB),
          width: isSelected! ? 2 : 1,
        ),
        boxShadow: isSelected! ? [
          BoxShadow(
            color: Color(0xFFF97316).withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Service Image with Gradient Border
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        ),
              boxShadow: isSelected! ? [
                BoxShadow(
                  color: Color(0xFFF97316).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ] : null,
            ),
            padding: EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_bg.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(width: 10),
          // Service Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_money_rounded,
                            size: 12,
                            color: Color(0xFF374151),
                          ),
                          SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              amount.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (duration != null && duration!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Color(0xFF374151),
                            ),
                            SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                duration.toString() + " min",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Action Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 36,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected! ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        ) : null,
                  color: isSelected! ? null : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected! 
                      ? Colors.transparent
                      : Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  boxShadow: isSelected! ? [
                    BoxShadow(
                      color: Color(0xFFF97316).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected!) ...[
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                      ],
                      Text(
                        isSelected! ? 'Added' : 'Book',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                          color: isSelected! 
                            ? Colors.white
                            : Color(0xFFF97316),
                          letterSpacing: -0.2,
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
}
