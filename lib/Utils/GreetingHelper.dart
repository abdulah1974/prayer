class GreetingHelper {
  static String getGreeting() {
    final int hour = DateTime.now().hour;
    // الفجر والليل (من 12 ليلاً حتى 4:59 فجراً)
    if (hour >= 0 && hour < 5) {
      return "ليلة سعيدة"; // أو "وقت السحر"
    }
    // الصباح (من 5 فجراً حتى 11:59 صباحاً)
    else if (hour >= 5 && hour < 12) {
      return "صباح الخير";
    }
    // الظهيرة والعصر (من 12 ظهراً حتى 4:59 عصراً)
    else if (hour >= 12 && hour < 17) {
      return "طاب يومك";
    }
    // المساء (من 5 مساءً حتى 11:59 ليلاً)
    else {
      return "مساء الخير";
    }
  }
}