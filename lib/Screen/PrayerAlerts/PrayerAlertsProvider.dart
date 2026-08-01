import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../Utils/PrayerManager.dart';

enum AlertType { sound, vibrate, off }

class PrayerAlertsProvider extends ChangeNotifier {
  final _box = GetStorage();
  final PrayerManager _prayerManager = PrayerManager();

  // 🔥 1. أضفنا الفجر هنا
  static const _prayers = ['الفجر', 'الضهر', 'العصر', 'المغرب', 'العشاء'];

  // 🔥 2. جعلنا الديفولت كله مطفي (off) كما طلبت
  static const _defaults = {
    'الفجر': AlertType.off,
    'الضهر': AlertType.off,
    'العصر': AlertType.off,
    'المغرب': AlertType.off,
    'العشاء': AlertType.off,
  };

  // 🔥 3. أضفنا رقم 1 للفجر
  static const Map<String, int> _prayerIds = {
    'الفجر': 1,
    'الضهر': 2,
    'العصر': 3,
    'المغرب': 4,
    'العشاء': 5,
  };

  // 🔥 4. أضفنا كلمة fajr
  static const Map<String, String> _prayerEnglishKeys = {
    'الفجر': 'fajr',
    'الضهر': 'dhuhr',
    'العصر': 'asr',
    'المغرب': 'maghrib',
    'العشاء': 'isha',
  };

  String getPrayerIcon(String key) {
    switch (key) {
      case 'الفجر':
        return "assets/icon/Fajr.svg";
      case 'الشروق':
        return "assets/icon/Sunrise.svg";
      case 'الضهر':
        return "assets/icon/Dhuhr.svg";
      case 'العصر':
        return "assets/icon/Asr.svg";
      case 'المغرب':
        return "assets/icon/Maghrib.svg";
      case 'العشاء':
        return "assets/icon/Isha.svg";
      default:
        return "assets/icon/Fajr.svg";
    }
  }

  late Map<String, AlertType> _alerts = _loadFromStorage();

  Map<String, AlertType> get alerts => _alerts;

  Map<String, AlertType> _loadFromStorage() {
    final Map<String, AlertType> result = {};
    for (final prayer in _prayers) {
      final savedIndex = _box.read('alert_$prayer');
      result[prayer] = savedIndex != null
          ? AlertType.values[savedIndex]
          : _defaults[prayer]!;
    }
    return result;
  }

  Future<void> setAlert(String prayer, AlertType type) async {
    _alerts = {..._alerts, prayer: type};
    await _box.write('alert_$prayer', type.index);
    notifyListeners();

    final id = _prayerIds[prayer];
    if (id == null) return;

    if (type == AlertType.off) {
      // كتم -> نلغي المنبه
      await _prayerManager.cancelSinglePrayer(id);
    } else {
      // تفعيل -> جدولة الصلاة بالوقت الحقيقي والدقيق (سواء اليوم أو الغد)
      await _prayerManager.schedulePrayerById(id);
    }
  }

  void resetAll() {
    _alerts = Map.from(_defaults);
    for (final prayer in _prayers) {
      _box.remove('alert_$prayer');
    }
    notifyListeners();
  }
}