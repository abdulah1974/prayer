import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../Utils/GreetingHelper.dart';
import '../../Utils/HijriHelper.dart';
import '../../Utils/LocationService.dart';
import 'package:geocoding/geocoding.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location;

import 'Widget/TodayPrayersList.dart';

class TimeProvider extends ChangeNotifier {
  String _currentAddress = "جاري تحديد الموقع...";
  Position? _currentPosition;
  String _hijriDate = "";
  String _greeting = "";

  // متغيرات الصلاة القادمة
  String _nextPrayerName = "---";
  String _nextPrayerTime = "--:-- --";
  String _timeRemaining = "00:00:00";
  Timer? _countdownTimer;

  String get currentAddress => _currentAddress;
  Position? get currentPosition => _currentPosition;
  String get hijriDate => _hijriDate;
  String get greeting => _greeting;

  String get nextPrayerName => _nextPrayerName;
  String get nextPrayerTime => _nextPrayerTime;
  String get timeRemaining => _timeRemaining;

  MuslimRepository repo = MuslimRepository();
  PrayerTime? prayerTime;

  Future<void> initTimeData(BuildContext context) async {
    _greeting = GreetingHelper.getGreeting();
    _hijriDate = HijriHelper.getTodayHijri();
    notifyListeners();

    await fetchLocationAndAddress(context);
    await loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    try {
      double lat = _currentPosition?.latitude ?? 36.1912;
      double lng = _currentPosition?.longitude ?? 44.0091;

      final dbLocation = await repo.reverseGeocoder(
        latitude: lat,
        longitude: lng,
      );

      if (dbLocation == null) {
        print("تعذر العثور على الموقع في قاعدة البيانات");
        return;
      }

      final attribute = PrayerAttribute(
        calculationMethod: CalculationMethod.makkah,
        asrMethod: AsrMethod.shafii,
        higherLatitudeMethod: HigherLatitudeMethod.angleBased,
        offset: [0, 0, 0, 0, 0, 0],
      );

      final result = await repo.getPrayerTimes(
        location: dbLocation,
        date: DateTime.now(),
        attribute: attribute,
      );

      prayerTime = result;

      // تشغيل العداد مباشرة بعد جلب البيانات بنجاح
      _startCountdown();

      notifyListeners();
    } catch (e) {
      print("خطأ في جلب مواقيت الصلاة: $e");
    }
  }

  // العداد التنازلي المحدث بعد تعديل الأنواع إلى DateTime
  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (prayerTime == null) return;

      final now = DateTime.now();
      DateTime? nextPrayerDateTime;
      String name = "";

      final fajr = prayerTime!.fajr;
      final dhuhr = prayerTime!.dhuhr;
      final asr = prayerTime!.asr;
      final maghrib = prayerTime!.maghrib;
      final isha = prayerTime!.isha;
      if (now.isBefore(fajr)) {
        name = "الفجر";
        nextPrayerDateTime = fajr;
      } else if (now.isBefore(dhuhr)) {
        name = "الضهر";
        nextPrayerDateTime = dhuhr;
      } else if (now.isBefore(asr)) {
        name = "العصر";
        nextPrayerDateTime = asr;
      } else if (now.isBefore(maghrib)) {
        name = "المغرب";
        nextPrayerDateTime = maghrib;
      } else if (now.isBefore(isha)) {
        name = "العشاء";
        nextPrayerDateTime = isha;
      } else {
        name = "الفجر";
        nextPrayerDateTime = fajr.add(const Duration(days: 1));
      }

      _nextPrayerName = name;
      _nextPrayerTime = _formatToAmPm(nextPrayerDateTime);
      final difference = nextPrayerDateTime.difference(now);
      _timeRemaining = "-${_formatDuration(difference)}";

      notifyListeners();
    });
  }

  String _formatToAmPm(DateTime dateTime) {
    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Future<void> fetchLocationAndAddress(BuildContext context) async {
    Position? position = await LocationService.determinePosition(context);
    if (position != null) {
      _currentPosition = position;
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
  List<Map<String, dynamic>> get prayerList {
    if (prayerTime == null) return [];

    final prayers = [
      {'nameAr': 'الفجر',   'nameKey': 'الفجر',   'time': prayerTime!.fajr},
      {'nameAr': 'الظهر',   'nameKey': 'الضهر',   'time': prayerTime!.dhuhr},
      {'nameAr': 'العصر',   'nameKey': 'العصر',   'time': prayerTime!.asr},
      {'nameAr': 'المغرب',  'nameKey': 'المغرب',  'time': prayerTime!.maghrib},
      {'nameAr': 'العشاء',  'nameKey': 'العشاء',  'time': prayerTime!.isha},
    ];

    final now = DateTime.now();
    return prayers.map((p) {
      final pTime = p['time'] as DateTime;
      PrayerState state;

      if (_nextPrayerName == p['nameKey']) {
        state = PrayerState.active;
      } else if (pTime.isBefore(now)) {
        state = PrayerState.passed;
      } else {
        state = PrayerState.upcoming;
      }

      return {
        ...p,
        'timeStr': _formatToAmPm(pTime),
        'state': state,
      };
    }).toList();
  }
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

}