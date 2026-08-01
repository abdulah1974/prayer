import 'package:flutter/material.dart';
import 'package:prayer/Utils/TextLanguage.dart';
import '../../Utils/Sizes.dart';
import '../../Widget/IslamicPatternPainter.dart';
import '../Language/Language.dart';
import '../Language/LanguageProvider.dart';
import 'package:provider/provider.dart';
import '../PrayerAlerts/PrayerAlerts.dart';
class Setting extends StatelessWidget {
  const Setting({super.key});

  static const Color backgroundColor = Color(0xFFFBF9F4);
  static const Color foregroundColor = Color(0xFF3D3A33);
  static const Color cardColor = Color(
      0xE6FFFFFF); // أبيض مع شفافية بسيطة backdrop-blur
  static const Color primaryColor = Color(0xFF8B7E66);
  static const Color mutedForegroundColor = Color(0xFF7A7468);
  static const Color borderColor = Color(0xFFE3DED3);
  static const Color secondaryColor = Color(0xFFE8E1D1);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();
    final language = TextLanguage();
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: IslamicPatternPainter()),
            ),
          ),
          SafeArea(
            child: Container(
              padding:  EdgeInsets.symmetric(horizontal: Sizes(context).GetWidth()*4),
              child: Column(
                children: [
                  // الهيدر (Header Section)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:  [
                      Text(
                        TextLanguage().GetWord('الإعدادات'),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Sizes(context).GetHeight()*2),
                  Expanded(
                    child: ListView(
                      physics:NeverScrollableScrollPhysics(),
                      children: [
                         Padding(
                          padding: EdgeInsets.only(bottom: Sizes(context).GetHeight()*1),
                          child: Text(
                            TextLanguage().GetWord("عام"),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: mutedForegroundColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor.withOpacity(
                                0.6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // خيار اللغة (Language)
                              _buildSettingTile(
                                icon: Icons.language,
                                title:TextLanguage().GetWord('لغة'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children:  [
                                    Text(
                                      language.currentLanguageCode == 1 ? 'العربية' : 'English',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        color: mutedForegroundColor,
                                      ),
                                    ),
                                    Icon(Icons.chevron_right,
                                        color: mutedForegroundColor, size: 18),
                                  ],
                                ),
                                showBorder: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, a1, a2) => LanguageScreen(),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                              ),
                               /*
                              // خيار سياسة الخصوصية (Privacy Policy)
                              _buildSettingTile(
                                icon: Icons.security,
                                title: 'Privacy Policy',
                                trailing: const Icon(Icons.chevron_right,
                                    color: mutedForegroundColor, size: 18),
                                showBorder: false,
                                onTap: () {
                                  // أضف هنا وظيفة فتح سياسة الخصوصية
                                },
                              ),

                                */
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor.withOpacity(
                                0.6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // خيار اللغة (Language)
                              _buildSettingTile(
                                icon: Icons.alarm_outlined,
                                title:TextLanguage().GetWord('تنبيهات الصلاة'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children:  [
                                    Icon(Icons.chevron_right,
                                        color: mutedForegroundColor, size: 18),
                                  ],
                                ),
                                showBorder: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, a1, a2) => PrayerAlerts(),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                              ),
                              /*
                              // خيار سياسة الخصوصية (Privacy Policy)
                              _buildSettingTile(
                                icon: Icons.security,
                                title: 'Privacy Policy',
                                trailing: const Icon(Icons.chevron_right,
                                    color: mutedForegroundColor, size: 18),
                                showBorder: false,
                                onTap: () {
                                  // أضف هنا وظيفة فتح سياسة الخصوصية
                                },
                              ),

                                */
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),


    );
  }

  // ودجت مخصصة لبناء خيارات الإعدادات (List Tiles) داخل الكارد
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    required bool showBorder,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: showBorder
              ? const Border(bottom: BorderSide(color: Color(0x33E3DED3)))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: mutedForegroundColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}