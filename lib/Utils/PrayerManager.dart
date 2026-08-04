import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:get_storage/get_storage.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
class PrayerManager {
  static final PrayerManager _instance = PrayerManager._internal();
  factory PrayerManager() => _instance;
  PrayerManager._internal();

  static const String _enabledKey = 'prayer_enabled_ids';

  final GetStorage _box = GetStorage();
  final MuslimRepository _repo = MuslimRepository();
  StreamSubscription<AlarmSettings>? _ringSubscription;
  int? activeRingingAlarmId;

  final StreamController<AlarmSettings> _onRingController =
  StreamController<AlarmSettings>.broadcast();
  Stream<AlarmSettings> get onRing => _onRingController.stream;

  Future<void> _lock = Future.value();

  Future<T> _synchronized<T>(Future<T> Function() action) async {
    final previous = _lock;
    final completer = Completer<void>();
    _lock = completer.future;
    await previous;
    try {
      return await action();
    } finally {
      completer.complete();
    }
  }


  Future<void> init() async {
    try {
      await Alarm.init();
      _initRingListener();
      await rescheduleAllEnabledPrayers();
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
  /// إعادة جدولة جميع الصلوات المفعلة بناءً على الوقت الحالي الحقيقي
  Future<void> rescheduleAllEnabledPrayers() async {
    for (int id = 1; id <= 5; id++) {
      if (isPrayerEnabled(id)) {
        await schedulePrayerById(id);
      }
    }
  }

  void _initRingListener() {
    _ringSubscription = Alarm.ringStream.stream.listen((alarmSettings) async {
      activeRingingAlarmId = alarmSettings.id;
      _onRingController.add(alarmSettings);

      if (!isPrayerEnabled(alarmSettings.id)) return;

      // عند انتهاء المنبه اليوم، يُجدول تلقائياً ليوم الغد بـ مواقيت الغد الحقيقية
      await schedulePrayerById(alarmSettings.id);
    });
  }

  /// تجلب وقت الصلاة الصحيح (سواء لليوم أو للغد إذا مضى وقت اليوم)
  Future<DateTime?> getNextPrayerTime(int id) async {
    final double lat = _box.read('latitude') ?? 36.1912;
    final double lng = _box.read('longitude') ?? 44.0091;
    final location = await _repo.reverseGeocoder(latitude: lat, longitude: lng);

    if (location == null) return null;

    final attribute = PrayerAttribute(
      calculationMethod: CalculationMethod.makkah,
      asrMethod: AsrMethod.shafii,
      higherLatitudeMethod: HigherLatitudeMethod.angleBased,
      offset: [0, 0, 0, 0, 0, 0],
    );

    final now = DateTime.now();

    // 1. تجربة مواقيت اليوم أولاً
    final todayPrayerTime = await _repo.getPrayerTimes(
      location: location,
      date: now,
      attribute: attribute,
    );

    if (todayPrayerTime == null) return null;

    final todayTimes = [
      fixDate(todayPrayerTime.fajr, now),
      fixDate(todayPrayerTime.dhuhr, now),
      fixDate(todayPrayerTime.asr, now),
      fixDate(todayPrayerTime.maghrib, now),
      fixDate(todayPrayerTime.isha, now),
    ];

    final prayerIndex = id - 1;
    DateTime scheduledTime = todayTimes[prayerIndex];

    // 2. إذا مضى وقت الصلاة اليوم، نجلب مواقيت الغد الحقيقية من المكتبة
    if (scheduledTime.isBefore(now)) {
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowPrayerTime = await _repo.getPrayerTimes(
        location: location,
        date: tomorrow,
        attribute: attribute,
      );

      if (tomorrowPrayerTime != null) {
        final tomorrowTimes = [
          fixDate(tomorrowPrayerTime.fajr, tomorrow),
          fixDate(tomorrowPrayerTime.dhuhr, tomorrow),
          fixDate(tomorrowPrayerTime.asr, tomorrow),
          fixDate(tomorrowPrayerTime.maghrib, tomorrow),
          fixDate(tomorrowPrayerTime.isha, tomorrow),
        ];
        scheduledTime = tomorrowTimes[prayerIndex];
      }
    }

    return scheduledTime;
  }

  /// جدول صلاة محددة باستخدام الـ ID
  Future<void> schedulePrayerById(int id) {
    return _synchronized(() async {
      final scheduledTime = await getNextPrayerTime(id);
      if (scheduledTime == null) return;

      final alarmSettings = AlarmSettings(
        id: id,
        dateTime: scheduledTime,
        assetAudioPath: 'assets/audio/adhan.mp3',
        loopAudio: false,
        vibrate: true,
        volumeSettings: VolumeSettings.fixed(volume: 1.0),
        notificationSettings: const NotificationSettings(
          title: 'الله أكبر - حان وقت الصلاة',
          body: 'اضغط زر الإيقاف لإيقاف صوت الأذان',
          stopButton: 'إيقاف الأذان',
        ),
        androidFullScreenIntent: false,
      );

      await Alarm.set(alarmSettings: alarmSettings);
      _setEnabled(id, true);
    });
  }

  Future<void> cancelSinglePrayer(int id) {
    return _synchronized(() async {
      await Alarm.stop(id);
      _setEnabled(id, false);
    });
  }

  Future<void> stopRinging() {
    return _synchronized(() async {
      if (activeRingingAlarmId != null) {
        await Alarm.stop(activeRingingAlarmId!);
        activeRingingAlarmId = null;
      }
    });
  }

  bool isPrayerEnabled(int id) {
    final Map<String, dynamic> map =
        _box.read<Map<String, dynamic>>(_enabledKey) ?? {};
    return map[id.toString()] == true;
  }

  void _setEnabled(int id, bool value) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(
        _box.read<Map<String, dynamic>>(_enabledKey) ?? {});
    map[id.toString()] = value;
    _box.write(_enabledKey, map);
  }

  DateTime fixDate(DateTime apiTime, DateTime refDate) {
    return DateTime(
      refDate.year,
      refDate.month,
      refDate.day,
      apiTime.hour,
      apiTime.minute,
    );
  }
}