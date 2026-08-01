import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:prayer/Utils/TextLanguage.dart';
import '../../Utils/QiblaCalculator.dart';
import '../../Utils/Sizes.dart';
import '../../Widget/IslamicPatternPainter.dart';
import 'package:get_storage/get_storage.dart';

class Qibla extends StatefulWidget {
  const Qibla({super.key});

  @override
  State<Qibla> createState() => _QiblaState();
}

class _QiblaState extends State<Qibla> {
  static const Color primary    = Color(0xFF8b7e66);
  static const Color background = Color(0xFFFBF9F4);
  static const Color foreground = Color(0xFF3d3a33);
  static const Color mutedFg    = Color(0xFF7a7468);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFe3ded3);

  late Future<bool?> _deviceSupport;

  @override
  void initState() {
    super.initState();
    _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();
  }



  @override
  Widget build(BuildContext context) {
    final s = Sizes(context);
    final box= GetStorage();
    final qibla = QiblaCalculator.calculateQibla(
      latitude:box.read('latitude')?? 36.1912,
      longitude: box.read('longitude')?? 44.0091,
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: IslamicPatternPainter()),
              ),
            ),
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: Sizes(context).GetWidth()*4),
                child: Column(
                  children: [
                    Column(
                      children:  [
                        Text(
                          TextLanguage().GetWord('القبلة'),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            //color: foregroundColor,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: FutureBuilder<bool?>(
                        future: _deviceSupport,
                        builder: (context, deviceSnapshot) {
                          if (deviceSnapshot.connectionState == ConnectionState.waiting) {
                            return _buildLoadingState(s,qibla.round());
                          }

                          // جهاز بدون مستشعر
                          if (deviceSnapshot.data == false) {
                            return const Center(
                              child: Text('جهازك لا يدعم مستشعر الاتجاه'),
                            );
                          }

                          // تحقق من الـ location قبل فتح الـ stream
                          return FutureBuilder<LocationStatus>(
                            future: FlutterQiblah.checkLocationStatus(),
                            builder: (context, locationSnapshot) {
                              if (locationSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(color: primary),
                                );
                              }
                              // كل شي تمام ← افتح الـ stream
                              return StreamBuilder<QiblahDirection>(
                                stream: FlutterQiblah.qiblahStream,
                                builder: (context, snapshot) {
                                  final bool locationOff = locationSnapshot.data?.enabled == false;
                                  if (!snapshot.hasData) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildLoadingState(s,qibla.round()),
                                        if (locationOff)
                                          Padding(
                                            padding: EdgeInsets.only(top: s.GetHeight() * 2),
                                            child: Text(
                                              TextLanguage().GetWord('يجب تفعيل خدمة الموقع لعمل البوصلة بشكل صحيح'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: s.GetWidth() * 3.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return const Center(
                                      child: Text('حدث خطأ في قراءة مستشعرات الجهاز'),
                                    );
                                  }

                                  final double heading = snapshot.data!.direction;
                                  final double qiblaAngle = snapshot.data!.qiblah;
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildCompass(s, heading, qiblaAngle),
                                      SizedBox(height: s.GetHeight() * 5),
                                      _buildInfoSection(qibla.toInt(),s, heading, qiblaAngle),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLoadingState(Sizes s,int qibla) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: 0.4,
          child: _buildCompass(s, 0, 0),
        ),
        SizedBox(height: s.GetHeight() * 5),
        Opacity(
          opacity: 0.4,
          child: _buildInfoSection(qibla,s, 0, 0),
        ),
      ],
    );
  }


  Widget _buildCompass(Sizes s, double heading, double qiblaAngle) {
    final double compassSize = s.GetWidth() * 75;
    final double innerSize   = compassSize * 0.70;
    final double kaabaSize   = s.GetWidth() * 10;

    final double compassTurns = -heading / 360;
    final double kaabaTurns   = -qiblaAngle / 360;

    return SizedBox(
      width: compassSize,
      height: compassSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardBg.withOpacity(0.3),
              border: Border.all(color: primary.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          CustomPaint(
            size: Size(compassSize * 0.93, compassSize * 0.93),
            painter: _DashedCirclePainter(
              color: primary.withOpacity(0.25),
              radius: compassSize * 0.93 / 2,
            ),
          ),
          AnimatedRotation(
            turns: compassTurns,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Stack(children: _buildCardinalPoints(s, compassSize)),
          ),
          AnimatedRotation(
            turns: kaabaTurns,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: s.GetHeight() * 0.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: kaabaSize,
                      height: kaabaSize,
                      decoration: BoxDecoration(
                        color: foreground,
                        borderRadius: BorderRadius.circular(s.GetWidth() * 2.5),
                        border: Border.all(color: primary.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mosque_rounded,
                        color: primary,
                        size: s.GetWidth() * 5.5,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: s.GetHeight() * 2,
                      color: primary.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: background,
              border: Border.all(color: primary.withOpacity(0.1)),
            ),
            child: AnimatedRotation(
              turns: compassTurns,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: const CustomPaint(painter: _NeedlePainter()),
            ),
          ),
          Container(
            width: s.GetWidth() * 4,
            height: s.GetWidth() * 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, Color(0xFF5c5446)],
              ),
              border: Border.all(color: background, width: 2),
              boxShadow: [
                BoxShadow(color: primary.withOpacity(0.4), blurRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCardinalPoints(Sizes s, double compassSize) {
    final labels = [
      (TextLanguage().GetWord('ش'), Alignment.topCenter),
      (TextLanguage().GetWord('ج'), Alignment.bottomCenter),
      (TextLanguage().GetWord('غ'), Alignment.centerLeft),
      (TextLanguage().GetWord('ق'), Alignment.centerRight),
    ];

    return labels.map((item) {
      final isNorth = item.$1 == 'ش';
      return Align(
        alignment: item.$2,
        child: Padding(
          padding: EdgeInsets.all(s.GetWidth() * 3.5),
          child: Text(
            item.$1,
            style: TextStyle(
              fontSize: s.GetWidth() * 3.5,
              fontWeight: FontWeight.bold,
              color: isNorth ? primary : mutedFg,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildInfoSection(int qibla,Sizes s, double heading, double qiblaAngle) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${qibla}°',
              style: TextStyle(
                fontSize: s.GetWidth() * 10,
                fontWeight: FontWeight.bold,
                color: mutedFg.withOpacity(0.6),
                height: 1,
              ),
            ),
            SizedBox(width: s.GetWidth() * 2),
            Text(
              '/',
              style: TextStyle(
                fontSize: s.GetWidth() * 10,
                fontWeight: FontWeight.w300,
                color: border,
              ),
            ),
            SizedBox(width: s.GetWidth() * 2),
            Text(
              '${heading.toInt()}°',
              style: TextStyle(
                fontSize: s.GetWidth() * 13,
                fontWeight: FontWeight.bold,
                color: foreground,
                height: 1,
              ),
            ),
            SizedBox(width: s.GetWidth() * 1.5),
            Text(
              TextLanguage().GetWord("اتجاهك"),
              style: TextStyle(
                fontSize: s.GetWidth() * 4.5,
                fontWeight: FontWeight.w500,
                color: mutedFg,
              ),
            ),
          ],
        ),
        SizedBox(height: s.GetHeight() * 1.5),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: s.GetWidth() * 4,
            vertical: s.GetHeight() * 1,
          ),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded, size: s.GetWidth() * 4, color: primary),
              SizedBox(width: s.GetWidth() * 1.5),
              Text(
                TextLanguage().GetWord('مكة المكرمة'),
                style: TextStyle(
                  fontSize: s.GetWidth() * 3.5,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NeedlePainter extends CustomPainter {
  const _NeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final northPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFFf0e6d2), Color(0xFF8b7e66)],
      ).createShader(Rect.fromLTWH(cx - 6, 16, 12, cy - 16));

    canvas.drawPath(
      Path()
        ..moveTo(cx, 16)
        ..lineTo(cx + 6, cy)
        ..lineTo(cx - 6, cy)
        ..close(),
      northPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(cx, size.height - 16)
        ..lineTo(cx + 6, cy)
        ..lineTo(cx - 6, cy)
        ..close(),
      Paint()..color = const Color(0xFF7a7468).withOpacity(0.2),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedCirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashCount = 60;
    const dashAngle = (2 * pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final start = i * dashAngle;
        canvas.drawArc(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: radius,
          ),
          start,
          dashAngle * 0.6,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}