import 'package:flutter/material.dart';
import 'package:prayer/Utils/Sizes.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;
  final String location;
  final String hijriDate;

  const HomeHeader({
    super.key,
    this.greeting = "Good Afternoon",
    this.location = "Cairo, EG",
    this.hijriDate = "14 Ramadan, 1445",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding:  EdgeInsets.symmetric(horizontal: Sizes(context).GetWidth()*2, vertical: Sizes(context).GetHeight()*1),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE3DED3).withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: const Color(0xFF7A7468).withOpacity(0.7),
              ),
              SizedBox(width: Sizes(context).GetWidth()*1),
              Text(
                hijriDate,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7A7468).withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding:  EdgeInsets.symmetric(horizontal: Sizes(context).GetWidth()*2, vertical: Sizes(context).GetHeight()*1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE3DED3).withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Color(0xFF8B7E66),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D3A33),
                    ),
                  ),
                ],
              ),
            ),

            // التاريخ الهجري
          ],
        ),
      ],
    );
  }
}