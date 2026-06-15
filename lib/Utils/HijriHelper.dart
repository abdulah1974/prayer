import 'package:hijri/hijri_calendar.dart';
import 'package:get_storage/get_storage.dart';
class HijriHelper {
  static const List<String> _monthsAr = [
    "محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة",
    "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
  ];
  static const List<String> _monthsEn = [
    "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani", "Jumada al-Awwal", "Jumada al-Thani",
    "Rajab", "Shaban", "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"
  ];
  static String getTodayHijri() {
    final hijri = HijriCalendar.now();
    final box = GetStorage();
    final int language = box.read('Language') ?? 1;
    final months = language == 1 ? _monthsAr : _monthsEn;
    final suffix = language == 1 ? 'هـ' : 'AH';
    return "${hijri.hDay} ${months[hijri.hMonth - 1]} ${hijri.hYear} $suffix";
  }
}