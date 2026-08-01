import 'dart:math' as math;

class QiblaCalculator {
  // إحداثيات الكعبة
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  static double calculateQibla({
    required double latitude,
    required double longitude,
  }) {
    final lat1 = _toRadians(latitude);
    final lon1 = _toRadians(longitude);

    final lat2 = _toRadians(kaabaLat);
    final lon2 = _toRadians(kaabaLng);

    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);

    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = _toDegrees(math.atan2(y, x));

    // تحويلها إلى 0 - 360
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  static double _toDegrees(double radian) {
    return radian * 180 / math.pi;
  }
}