import 'package:flutter/cupertino.dart';
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  IslamicPatternPainter({this.color = const Color(0xFF8B7E66), this.opacity = 0.03});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double patternSize = 40.0; // نفس عرض الـ pattern في الـ SVG

    for (double x = 0; x < size.width; x += patternSize) {
      for (double y = 0; y < size.height; y += patternSize) {
        // رسم شكل المعينة (المثلثات المتداخلة)
        Path path = Path();
        path.moveTo(x + 20, y);          // M20 0
        path.lineTo(x + 40, y + 20);     // L40 20
        path.lineTo(x + 20, y + 40);     // L20 40
        path.lineTo(x, y + 20);          // L0 20
        path.close();
        canvas.drawPath(path, paint);

        // رسم الدائرة المركزية
        canvas.drawCircle(
            Offset(x + 20, y + 20),
            5,
            strokePaint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}