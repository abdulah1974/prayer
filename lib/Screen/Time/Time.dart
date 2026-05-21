import 'package:flutter/material.dart';
import 'package:prayer/Utils/Sizes.dart';
import 'package:prayer/Utils/TextLanguage.dart';

import '../../Widget/IslamicPatternPainter.dart';
import 'TimeProvider.dart';
import 'package:provider/provider.dart';
import 'Widget/HomeHeader.dart';
import 'Widget/NextPrayerHeroCard.dart';
import 'Widget/TodayPrayersList.dart';
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
            body:SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: IslamicPatternPainter(),
                      ),
                    ),
                  ),
                  Container(
                    padding:  EdgeInsets.symmetric(horizontal: Sizes(context).GetWidth()*4),
                    child: Column(
                      children: [
                        HomeHeader(location:navProvider.currentAddress, hijriDate: navProvider.hijriDate,greeting: navProvider.greeting),
                        SizedBox(height: Sizes(context).GetHeight()*2),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: Sizes(context).GetHeight()*1),
                            child: Column(
                              children:  [
                                NextPrayerHeroCard(
                                  prayerName:navProvider.nextPrayerName,
                                  prayerTime:navProvider.nextPrayerTime,
                                  timeRemaining:navProvider.timeRemaining,
                                ),
                                SizedBox(height: Sizes(context).GetHeight()*2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    //Today's Prayers
                                    Text(
                                      TextLanguage().GetWord("الصلاة اليوم"),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3d3a33),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Sizes(context).GetHeight()*2),
                                // Fajr - Passed
                                ...navProvider.prayerList.map((prayer) {
                                  return Column(
                                    children: [
                                      TodayPrayersList(
                                        icon: _getPrayerIcon(prayer['nameKey'] as String),
                                        name: prayer['nameAr'] as String,
                                        subtitle: prayer['nameKey'] as String,
                                        time: prayer['timeStr'] as String,
                                        state: prayer['state'] as PrayerState,
                                      ),
                                      SizedBox(height: Sizes(context).GetHeight() * 2),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            );
          }
    );
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'الفجر':   return Icons.wb_twilight;
      case 'الضهر':   return Icons.wb_sunny_outlined;
      case 'العصر':   return Icons.wb_sunny;
      case 'المغرب':  return Icons.wb_cloudy_outlined;
      case 'العشاء':  return Icons.nightlight_outlined;
      default:        return Icons.access_time;
    }
  }
}
