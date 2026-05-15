import 'package:flutter/material.dart';

import '../../Widget/IslamicPatternPainter.dart';
import 'TimeProvider.dart';
import 'package:provider/provider.dart';
import 'Widget/HomeHeader.dart';
class Time extends StatelessWidget {
  const Time({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (providerContext) {
          final provider = TimeProvider();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.initTimeData(providerContext);
          });
          return provider;
        },
        builder: (context, child) {

          final navProvider = Provider.of<TimeProvider>(context);
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: IslamicPatternPainter(), // تأكد من استدعاء الكلاس الصحيح
                    ),
                  ),
                ),
                Column(
                  children: [
                     HomeHeader(location:navProvider.currentAddress, hijriDate: navProvider.hijriDate,greeting: navProvider.greeting),
                  ],
                ),
              ],
             ),
            );
          }
    );
  }
}
