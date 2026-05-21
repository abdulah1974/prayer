// 3. كارد الصلاة القادمة (Next Prayer Hero Card)
import 'package:flutter/material.dart';
import 'package:prayer/Utils/TextLanguage.dart';

import '../../../Utils/Sizes.dart';
class AppColors {
  static const Color background = Color(0xFFFBF9F4);
  static const Color foreground = Color(0xFF3D3A33);
  static const Color primary = Color(0xFF8B7E66);
  static const Color primaryDark = Color(0xFF5C5446);
  static const Color secondary = Color(0xFFE8E1D1);
  static const Color secondaryForeground = Color(0xFF5C5446);
  static const Color mutedForeground = Color(0xFF7A7468);
  static const Color border = Color(0xFFE3DED3);
  static const Color cardBg = Color(0xB3FFFFFF); // white with opacity
}

class NextPrayerHeroCard extends StatelessWidget {
  final String prayerName;     // اسم الصلاة مثل: Asr
  final String prayerTime;     // وقت الصلاة مثل: 03:45 PM
  final String timeRemaining;  // الوقت المتبقي مثل: -00:45:22

  static const String title = 'Next Prayer';
  const NextPrayerHeroCard({
    Key? key,
    required this.prayerName,
    required this.prayerTime,
    required this.timeRemaining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Sizes size = Sizes(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding:  EdgeInsets.all(size.GetHeight()*4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              Icon(Icons.access_time, size: 18, color: Colors.white),
              SizedBox(width: size.GetWidth()*2),
              Text(
                TextLanguage().GetWord("الصلاة التالية"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: size.GetHeight()*1),
          Text(
            prayerName, // استخدام المتغير هنا
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
          ),
          Text(
            prayerTime, // استخدام المتغير هنا
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontStyle: FontStyle.italic,
            ),
          ),
           SizedBox(height: Sizes(context).GetHeight()*2),
           Text(
            TextLanguage().GetWord('الوقت المتبقي'),
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: size.GetHeight()*1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child:  Text(
              timeRemaining, // استخدام المتغير هنا
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w500,
                fontFamily: 'Courier',
                // بديل لـ Mono font للتناسق الرقمي
                letterSpacing: 2,
              ),
            ),
          )
        ],
      ),
    );
  }
}