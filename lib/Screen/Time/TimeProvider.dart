import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import '../../Utils/GreetingHelper.dart';
import '../../Utils/HijriHelper.dart';
import '../../Utils/LocationService.dart';
import '../../Utils/TextLanguage.dart';
import 'Widget/TodayPrayersList.dart';

class TimeProvider extends ChangeNotifier {
  String _currentAddress = "جاري تحديد الموقع...";
  Position? _currentPosition;
  String _hijriDate = "";
  String _greeting = "";

  String _nextPrayerKey = "fajr";
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

  final MuslimRepository repo = MuslimRepository();
  PrayerTime? prayerTime;
  Location? _cachedLocation;
  DateTime? _tomorrowFajr; // تم تعريف المتغير هنا لحل الخطأ الأول
  final TextLanguage _lang = TextLanguage();

  Future<void> initTimeData(BuildContext context) async {
    _greeting = GreetingHelper.getGreeting();
    _hijriDate = HijriHelper.getTodayHijri();
    notifyListeners();

    if (_cachedLocation == null) {
      final box = GetStorage();
      double lat = box.read('latitude') ?? 36.1912;
      double lng = box.read('longitude') ?? 44.0091;
      _cachedLocation = await repo.reverseGeocoder(latitude: lat, longitude: lng);
    }

    await loadPrayerTimes();
    _fetchLocationInBackground(context);
  }

  Future<void> loadPrayerTimes() async {
    try {
      if (_cachedLocation == null) return;

      final attribute = PrayerAttribute(
        calculationMethod: CalculationMethod.makkah,
        asrMethod: AsrMethod.shafii,
        higherLatitudeMethod: HigherLatitudeMethod.angleBased,
        offset: [0, 0, 0, 0, 0, 0],
      );

      // جلب مواقيت اليوم
      final result = await repo.getPrayerTimes(
        location: _cachedLocation!,
        date: DateTime.now(),
        attribute: attribute,
      );

      // جلب مواقيت الغد لحساب الفجر بشكل دقيق
      final tomorrowResult = await repo.getPrayerTimes(
        location: _cachedLocation!,
        date: DateTime.now().add(const Duration(days: 1)),
        attribute: attribute,
      );
      _tomorrowFajr = tomorrowResult?.fajr;

      prayerTime = result;
      _startCountdown();
      notifyListeners();
    } catch (e) {
      print("خطأ في جلب مواقيت الصلاة: $e");
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (prayerTime == null) return;

      final now = DateTime.now();
      DateTime? nextPrayerDateTime;
      String nextKey = "fajr";

      final fajr = prayerTime!.fajr;
      final sunrise = prayerTime!.sunrise;
      final dhuhr = prayerTime!.dhuhr;
      final asr = prayerTime!.asr;
      final maghrib = prayerTime!.maghrib;
      final isha = prayerTime!.isha;

      if (now.isBefore(fajr)) {
        nextKey = "fajr";
        nextPrayerDateTime = fajr;
      } else if (now.isBefore(sunrise)) {
        nextKey = "sunrise";
        nextPrayerDateTime = sunrise;
      } else if (now.isBefore(dhuhr)) {
        nextKey = "dhuhr";
        nextPrayerDateTime = dhuhr;
      } else if (now.isBefore(asr)) {
        nextKey = "asr";
        nextPrayerDateTime = asr;
      } else if (now.isBefore(maghrib)) {
        nextKey = "maghrib";
        nextPrayerDateTime = maghrib;
      } else if (now.isBefore(isha)) {
        nextKey = "isha";
        nextPrayerDateTime = isha;
      } else {
        nextKey = "fajr";
        nextPrayerDateTime = _tomorrowFajr ?? fajr.add(const Duration(days: 1));
      }

      _nextPrayerKey = nextKey;
      _nextPrayerName = _getPrayerLocalizedName(nextKey);

      // إضافة ! لحل خطأ الـ Null Safety (الخطأ الثاني والثالث)
      _nextPrayerTime = _formatToAmPm(nextPrayerDateTime!);
      final difference = nextPrayerDateTime!.difference(now);
      _timeRemaining = "-${_formatDuration(difference)}";

      notifyListeners();
    });
  }

  String _getPrayerLocalizedName(String key) {
    switch (key) {
      case 'fajr':
        return _lang.GetWord('الفجر');
      case 'sunrise':
        return _lang.GetWord('الشروق');
      case 'dhuhr':
        return _lang.GetWord('الضهر');
      case 'asr':
        return _lang.GetWord('العصر');
      case 'maghrib':
        return _lang.GetWord('المغرب');
      case 'isha':
        return _lang.GetWord('العشاء');
      default:
        return _lang.GetWord('الفجر');
    }
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

  Future<void> _fetchLocationInBackground(BuildContext context) async {
    try {
      Position? position = await LocationService.determinePosition(context);
      if (position == null) {
        _currentAddress = "الموقع معطل";
        notifyListeners();
        return;
      }

      _currentPosition = position;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 2));

        if (placemarks.isNotEmpty) {
          _currentAddress = "${placemarks[0].locality}، ${placemarks[0].country}";
        }
      } catch (_) {
        _currentAddress = "تم تحديد الموقع (بدون إنترنت)";
      }

      notifyListeners();
    } catch (e) {
      print("خطأ في تحديد الموقع: $e");
    }
  }

  List<Map<String, dynamic>> get prayerList {
    if (prayerTime == null) return [];

    final prayers = [
      {'nameKey': 'fajr',    'nameLocalized': _lang.GetWord('الفجر'),   'time': prayerTime!.fajr,    'isInfo': false},
      {'nameKey': 'sunrise', 'nameLocalized': _lang.GetWord('الشروق'),  'time': prayerTime!.sunrise, 'isInfo': true},
      {'nameKey': 'dhuhr',   'nameLocalized': _lang.GetWord('الضهر'),   'time': prayerTime!.dhuhr,   'isInfo': false},
      {'nameKey': 'asr',     'nameLocalized': _lang.GetWord('العصر'),   'time': prayerTime!.asr,     'isInfo': false},
      {'nameKey': 'maghrib', 'nameLocalized': _lang.GetWord('المغرب'),  'time': prayerTime!.maghrib, 'isInfo': false},
      {'nameKey': 'isha',    'nameLocalized': _lang.GetWord('العشاء'),  'time': prayerTime!.isha,    'isInfo': false},
    ];

    final now = DateTime.now();

    return prayers.map((p) {
      final pTime = p['time'] as DateTime;
      final isInfo = p['isInfo'] as bool;
      PrayerState state;

      if (isInfo) {
        state = pTime.isBefore(now) ? PrayerState.passed : PrayerState.upcoming;
      } else if (_nextPrayerKey == p['nameKey']) {
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