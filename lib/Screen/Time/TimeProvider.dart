import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../Utils/GreetingHelper.dart';
import '../../Utils/HijriHelper.dart';
import '../../Utils/LocationService.dart';
import 'package:geocoding/geocoding.dart';
class TimeProvider extends ChangeNotifier {
  String _currentAddress = "جاري تحديد الموقع...";
  Position? _currentPosition;
  String _hijriDate = "";
  String _greeting = "";
  String get currentAddress => _currentAddress;
  Position? get currentPosition => _currentPosition;
  String get hijriDate => _hijriDate;
  String get greeting => _greeting;
  // الوظيفة الأساسية لتشغيل كل شيء
  Future<void> initTimeData(BuildContext context) async {
    // استدعاء الكلاسات مباشرة
    _greeting = GreetingHelper.getGreeting();
    _hijriDate = HijriHelper.getTodayHijri();

    notifyListeners(); // نحدث الواجهة فوراً للترحيب والتاريخ

    await fetchLocationAndAddress(context); // ثم نحدث الموقع
  }



  Future<void> fetchLocationAndAddress(BuildContext context) async {
    Position? position = await LocationService.determinePosition(context);
    if (position != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5), onTimeout: () {
          throw Exception("انتهى وقت الانتظار");
        });

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          _currentAddress = "${place.locality}، ${place.country}";
        }
      } catch (e) {
        _currentAddress = "تعذر تحديد اسم المنطقة";
      } finally {
        notifyListeners();
      }
    } else {
      _currentAddress = "الموقع معطل";
      notifyListeners();
    }
  }
}