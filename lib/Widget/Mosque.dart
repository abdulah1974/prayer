
import 'package:flutter/cupertino.dart';

class Mosque extends CustomPainter {
  final Color primaryColor;
  Mosque({this.primaryColor = const Color(0xFF8B7E66)});

  @override
  void paint(Canvas canvas, Size size) {
    // حساب مقياس الرسم ليتناسب مع حجم الحاوية
    double scaleX = size.width / 400;
    double scaleY = size.height / 200;

    final Paint mainPaint = Paint()
      ..color = primaryColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // 1. القبة المركزية مع التدرج
    final Rect domeRect = Rect.fromLTWH(130 * scaleX, 60 * scaleY, 140 * scaleX, 140 * scaleY);
    final Paint domePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.8),
          primaryColor.withOpacity(0.2),
        ],
      ).createShader(domeRect);

    Path domePath = Path();
    domePath.moveTo(130 * scaleX, 200 * scaleY);
    domePath.lineTo(270 * scaleX, 200 * scaleY);
    domePath.lineTo(270 * scaleX, 160 * scaleY);
    domePath.cubicTo(
        270 * scaleX, 160 * scaleY,
        270 * scaleX, 80 * scaleY,
        200 * scaleX, 60 * scaleY
    );
    domePath.cubicTo(
        130 * scaleX, 80 * scaleY,
        130 * scaleX, 160 * scaleY,
        130 * scaleX, 160 * scaleY
    );
    domePath.close();
    canvas.drawPath(domePath, domePaint);

    // 2. الهلال / الرمح العلوي
    Path spirePath = Path();
    spirePath.moveTo(198 * scaleX, 60 * scaleY);
    spirePath.lineTo(202 * scaleX, 60 * scaleY);
    spirePath.lineTo(200 * scaleX, 30 * scaleY);
    spirePath.close();
    canvas.drawPath(spirePath, mainPaint..color = primaryColor);
    canvas.drawCircle(Offset(200 * scaleX, 28 * scaleY), 3 * scaleX, mainPaint);

    // 3. المئذنة اليسرى
    canvas.drawRect(Rect.fromLTWH(80 * scaleX, 100 * scaleY, 20 * scaleX, 100 * scaleY), mainPaint..color = primaryColor.withOpacity(0.6));
    Path leftMinaretTop = Path();
    leftMinaretTop.moveTo(75 * scaleX, 100 * scaleY);
    leftMinaretTop.lineTo(105 * scaleX, 100 * scaleY);
    leftMinaretTop.lineTo(90 * scaleX, 80 * scaleY);
    leftMinaretTop.close();
    canvas.drawPath(leftMinaretTop, mainPaint);

    // 4. المئذنة اليمنى
    canvas.drawRect(Rect.fromLTWH(300 * scaleX, 100 * scaleY, 20 * scaleX, 100 * scaleY), mainPaint);
    Path rightMinaretTop = Path();
    rightMinaretTop.moveTo(295 * scaleX, 100 * scaleY);
    rightMinaretTop.lineTo(325 * scaleX, 100 * scaleY);
    rightMinaretTop.lineTo(310 * scaleX, 80 * scaleY);
    rightMinaretTop.close();
    canvas.drawPath(rightMinaretTop, mainPaint);

    // 5. خط الأرضية
    canvas.drawRect(Rect.fromLTWH(0, 198 * scaleY, size.width, 2 * scaleY), mainPaint..color = primaryColor.withOpacity(0.4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}