import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:prayer/Utils/LocationService.dart'; // تأكد من المسار الخاص بك

class InitialPrayerData {
  final Position position;
  final String address;
  final PrayerTime prayerTime;

  InitialPrayerData({
    required this.position,
    required this.address,
    required this.prayerTime,
  });
}

class TimeInitializer {
  static Future<InitialPrayerData> initialize(BuildContext context) async {
    // 1. جلب الـ GPS والانتظار حتى ينتهي تماماً
    Position? position = await LocationService.determinePosition(context);
    if (position == null) {
      throw Exception("تعذر الوصول للموقع");
    }

    // 2. جلب مواقيت الصلاة بناءً على الإحداثيات المستلمة فوراً
    final repo = MuslimRepository();
    final dbLocation = await repo.reverseGeocoder(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (dbLocation == null) {
      throw Exception("الموقع غير مدعوم في قاعدة البيانات");
    }

    final attribute = PrayerAttribute(
      calculationMethod: CalculationMethod.makkah,
      asrMethod: AsrMethod.shafii,
      higherLatitudeMethod: HigherLatitudeMethod.angleBased,
      offset: [0, 0, 0, 0, 0, 0],
    );

    final prayerTime = await repo.getPrayerTimes(
      location: dbLocation,
      date: DateTime.now(),
      attribute: attribute,
    );

    // 3. جلب اسم المنطقة (مع تحديد وقت انتظار قصير)
    String address = "تم تحديد الموقع";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 2), onTimeout: () => []);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address = "${place.locality}، ${place.country}";
      }
    } catch (_) {}

    // إرجاع كل البيانات مجمعة وجاهزة
    return InitialPrayerData(
      position: position,
      address: address,
      prayerTime: prayerTime!,
    );
  }
}