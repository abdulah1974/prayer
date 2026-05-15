import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  static Position? lastKnownPosition;

  static Future<Position?> determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. التحقق من تشغيل GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar(
        context,
        'خدمة الموقع معطلة. يرجى تفعيل الـ GPS',
        actionLabel: 'الإعدادات',
        onActionPressed: () => Geolocator.openLocationSettings(), // يفتح إعدادات الموقع العامة
      );
      return null;
    }

    // 2. التحقق من الصلاحيات
    permission = await Geolocator.checkPermission();

    // في حال الرفض العادي
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar(context, 'تم رفض الصلاحية، لن نتمكن من تحديد أوقات الصلاة بدقة');
        return null;
      }
    }

    // في حال الرفض النهائي (الذهاب للإعدادات إجباري هنا)
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
        context,
        'لقد قمت برفض الصلاحية بشكل دائم. يرجى تفعيلها من إعدادات التطبيق',
        actionLabel: 'فتح الإعدادات',
        onActionPressed: () => Geolocator.openAppSettings(), // يفتح إعدادات التطبيق الخاصة
      );
      return null;
    }

    // 3. محاولة جلب آخر موقع معروف (للسرعة)
    lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      return lastKnownPosition;
    }

    // 4. إعدادات الموقع
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.low,
    );

    // 5. جلب الموقع الحالي
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      _showSnackBar(context, 'تعذر جلب الموقع، يرجى المحاولة مرة أخرى');
      return null;
    }
  }

  // تطوير الـ SnackBar ليدعم الأزرار (Action)
  static void _showSnackBar(BuildContext context, String message, {String? actionLabel, VoidCallback? onActionPressed}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8B7E66),
        behavior: SnackBarBehavior.floating,
        action: actionLabel != null
            ? SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onActionPressed!,
        )
            : null,
      ),
    );
  }
}