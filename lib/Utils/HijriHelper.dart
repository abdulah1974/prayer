class HijriHelper {
  static const List<String> _months = [
    "محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة",
    "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
  ];

  static String getTodayHijri() {
    final DateTime now = DateTime.now();

    // الحساب التقريبي بناءً على الفرق الزمني بين التقويمين
    // السنة الهجرية المتوسطة = 354.367 يوم
    // السنة الميلادية المتوسطة = 365.2422 يوم

    double iYear = (now.year - 622) * (365.25 / 354.36);
    int hYear = iYear.floor();

    // حساب الشهر التقريبي
    int hMonth = (((iYear - hYear) * 354.36) / 29.53).floor() + 1;

    // حساب اليوم التقريبي
    int hDay = (((((iYear - hYear) * 354.36) / 29.53) - hMonth + 1) * 29.53).floor() + 1;

    // حماية للحدود
    if (hMonth > 12) hMonth = 12;
    if (hMonth < 1) hMonth = 1;
    if (hDay > 30) hDay = 30;
    if (hDay < 1) hDay = 1;

    return "$hDay ${_months[hMonth - 1]} $hYear هـ";
  }
}