import 'package:flutter/material.dart';
import 'package:prayer/Utils/Sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';
enum PrayerState { passed, active, upcoming }
class TodayPrayersList extends StatelessWidget {
  final String icon;
  final String name;
  final String subtitle;
  final String time;
  final PrayerState state;

  const TodayPrayersList({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.time,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed = state == PrayerState.passed;
    final isActive = state == PrayerState.active;
    const duration = Duration(milliseconds: 400);
    const curve = Curves.easeInOutCubic;
    return  AnimatedContainer(
      duration: duration,
      curve: curve,
      padding: EdgeInsets.symmetric(
        horizontal: Sizes(context).GetWidth() * 3,
        vertical: Sizes(context).GetHeight() * 2,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : isPassed
            ? Color(0x66FFFFFF)
            : Color(0xB3FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Color(0xFF8b7e66).withOpacity(0.3)
              : Color(0xFFe3ded3).withOpacity(isPassed ? 0.5 : 0.6),
          width: 1,
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: Color(0xFF8b7e66).withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Row(
        children: [

          Container(
            width: Sizes(context).GetWidth()*10,
            height: Sizes(context).GetWidth()*10,
            decoration: BoxDecoration(
              color: isActive
                  ? Color(0xFFe8e1d1)
                  : isPassed
                  ? Color(0xFF8b7e66).withOpacity(0.1)
                  : Color(0xFF8b7e66).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: Sizes(context).GetWidth()*6,
                height: Sizes(context).GetWidth()*6,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  isActive
                      ? const Color(0xFF8b7e66)
                      : isPassed
                      ? const Color(0xFF5c5446)
                      : const Color(0xFF7a7468),
                  BlendMode.srcIn,
                ),
                         ),
            ),
         ),
          SizedBox(width: Sizes(context).GetWidth()*2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: isActive ? 18 : 16,
                    color: isPassed ? Color(0xFF7a7468) : Color(0xFF3d3a33),
                    decoration: isPassed ? TextDecoration.lineThrough : null,
                    decorationColor: Color(0xFFe3ded3),
                  ),
                ),

                SizedBox(height: Sizes(context).GetHeight()*0.5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive
                        ? Color(0xFF8b7e66)
                        : Color(0xFF7a7468).withOpacity(0.7),
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // Time & bell
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: isActive ? 18 : 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Color(0xFF8b7e66) : Color(0xFF7a7468),
                ),
              ),
              /*
              if (isActive) ...[
                const SizedBox(height: 4),
                Icon(Icons.notifications_active, size: 16, color: Color(0xFF8b7e66)),
              ],

               */
            ],
          ),
        ],
      ),
    );
  }
}