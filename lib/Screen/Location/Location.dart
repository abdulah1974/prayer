import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../Utils/LocationService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Widget/IslamicPatternPainter.dart';
import '../../Widget/Mosque.dart';
import '../BottomNavBar/BottomNavBar.dart';
import 'package:get_storage/get_storage.dart';
class Location extends StatefulWidget {
  const Location({super.key, required this.title});
  final String title;

  @override
  State<Location> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Location> {
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF8B7E66);
    const Color backgroundColor = Color(0xFFFBF9F4);
    final Sizes size = Sizes(context);
    final textLanguage = TextLanguage();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 1. الخلفية الزخرفية (النمط الإسلامي) - معزولة للأداء
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: IslamicPatternPainter(), // تأكد من استدعاء الكلاس الصحيح
              ),
            ),
          ),

          // 3. محتوى الصفحة الرئيسي
          Column(
            children: [
              // القسم العلوي: رسمة الجامع
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: const Size(double.infinity, 200),
                      painter: Mosque(primaryColor: primaryColor),
                    ),
                  ),
                ),
              ),

              // القسم الأوسط: النصوص (Typography)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // خط ديكوري بسيط
                    Container(
                      width: 2,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, primaryColor.withOpacity(0.4), Colors.transparent],
                        ),
                      ),
                    ),
                    SizedBox(height: size.GetHeight() * 2),
                     Text(
                      textLanguage.GetWord('الوصول إلى الموقع'),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: size.GetHeight() * 2),
                     Text(
                      textLanguage.GetWord('اسم_التطبيق'),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D3A33),
                        // fontFamily: 'Amiri', // لو محمل الخط
                      ),
                    ),
                    SizedBox(height: size.GetHeight() * 1),
                     Text(
                      textLanguage.GetWord('تحتاج سكينة إلى إحداثياتك لحساب مواقيت الصلاة الدقيقة لمنطقتك.'),
                       textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A7468),
                      ),
                    ),
                     SizedBox(height: size.GetHeight() * 1),
                     Text(
                       textLanguage.GetWord('يرجى تفعيل الموقع للمتابعة إلى أوقات الصلاة.'),
                       textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A7468),
                      ),
                    ),
                  ],
                ),
              ),

              // القسم السفلي: الأزرار
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: size.GetWidth()*5, vertical: size.GetHeight()*7),
                child: ElevatedButton(
                  onPressed: ()async {
                    final box = GetStorage();
                    Position? position = await LocationService.determinePosition(context);
                    if (position != null) {
                     await box.write('latitude', position.latitude);
                     await box.write('longitude', position.longitude);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const BottomNavBar()),
                            (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(textLanguage.GetWord('تفعيل خدمة الموقع'), style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.location_on),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
