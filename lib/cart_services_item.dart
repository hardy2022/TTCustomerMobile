import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'Utility/constants.dart';
import 'Utility/date_converter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartServicesItem extends StatelessWidget {
  CartServicesItem({
    this.image,
    this.name,
    this.amount,
    this.duration,
    this.date,
    this.time,
    this.services,
  });

  final String? image;
  final String? name;
  final String? amount;
  final String? duration;
  final String? date;
  final String? time;
  final List<String>? services;

  @override
  Widget build(BuildContext context) {
    var devwidth = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      width: devwidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with gradient border
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFFA773F7),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF97316).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: image != null && image!.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: image!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                      Container(
                        color: Colors.white.withOpacity(0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white.withOpacity(0.1),
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    )
                        : Container(
                      color: Colors.white.withOpacity(0.1),
                      child: Image.asset(
                        'assets/images/login_bg.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12),
          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Vendor name
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    (name != null && name!.trim().isNotEmpty) ? name!.trim() : 'Vendor',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    letterSpacing: -0.4,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  ),
                ),
                SizedBox(height: 6),
                // Services tags - more compact
                Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: services!.take(2).map((service) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (services!.length > 2)
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '+${services!.length - 2} more',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                // Price - more compact
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFFA773F7),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFF97316).withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'CAD ' + amount!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          // Date and Time Section - more compact
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(width: 4),
                    Text(
                      DateConverter.convertTimeFormat(time!),
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1F2937),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(width: 4),
                    Text(
                      DateConverter.convertDateFormat1(date!)!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1F2937),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
