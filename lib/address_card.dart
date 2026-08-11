import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  final String title;
  final String line1;
  final String line2;
  final VoidCallback onViewMap;

  /// selection props
  final bool isSelected;
  final ValueChanged<bool?> onSelect;

  const AddressCard({
    super.key,
    required this.title,
    required this.line1,
    required this.line2,
    required this.onViewMap,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8CFA5)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.home_rounded, color: Color(0xFFFF8A00)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
             /* Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A00).withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
              ),*/
              Checkbox(
                value: isSelected,
                onChanged: onSelect,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Address line 1 + checkbox at extreme right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  line1,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: "Poppins",
                    color: Colors.black87,
                  ),
                ),
              ),
              // Checkbox on the right

            ],
          ),

          // Address line 2
        /*  Text(
            line2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Poppins",
              color: Colors.black87,
            ),
          ),*/

          const Spacer(),

          // View on map
          GestureDetector(
            onTap: onViewMap,
            child: const Text(
              'View on map',
              style: TextStyle(
                fontSize: 13,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF8A00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
