import 'package:flutter/material.dart';
import 'package:prayer/Utils/TextLanguage.dart';
import 'package:provider/provider.dart';
import 'package:prayer/Utils/Sizes.dart';
import '../../Widget/IslamicPatternPainter.dart';
import 'LanguageProvider.dart';
class LanguageScreen extends StatelessWidget {
  static const Color backgroundColor = Color(0xFFFBF9F4);
  static const Color foregroundColor = Color(0xFF3D3A33);
  static const Color cardColor = Color(0xE6FFFFFF);
  static const Color primaryColor = Color(0xFF8B7E66);
  static const Color mutedForegroundColor = Color(0xFF7A7468);
  static const Color borderColor = Color(0xFFE3DED3);

  final List<Map<String, dynamic>> _languages = const [
    {'code': 0, 'name': 'English'},
    {'code': 1, 'name': 'العربية'},
  ];

  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes(context).GetWidth() * 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                   SizedBox(height: Sizes(context).GetHeight() * 2),
                  Expanded(
                    child: ListView(
                      children: [
                         Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            TextLanguage().GetWord("اللغات المتاحة"),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: mutedForegroundColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        _buildLanguageCard(context, provider),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: Sizes(context).GetWidth()*11.5,
            height: Sizes(context).GetWidth()*11.5,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: primaryColor,
              size: 16,
            ),
          ),
        ),
         Text(
          TextLanguage().GetWord('لغة'),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard(BuildContext context, LanguageProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_languages.length, (index) {
          final lang = _languages[index];
          final bool isSelected = lang['code'] == provider.currentLanguage;
          final bool isLast = index == _languages.length - 1;

          return _buildLanguageTile(
            context: context,
            languageName: lang['name'] as String,
            isSelected: isSelected,
            showBorder: !isLast,
            onTap: () => provider.changeLanguage(lang['code'] as int),
          );
        }),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String languageName,
    required bool isSelected,
    required bool showBorder,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.6) : Colors.transparent,
          borderRadius: isSelected ? BorderRadius.circular(24) : null,
          border: showBorder && !isSelected
              ? const Border(bottom: BorderSide(color: Color(0x33E3DED3)))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  color: isSelected
                      ? primaryColor
                      : mutedForegroundColor.withOpacity(0.7),
                  size: 22,
                ),
                SizedBox(width: Sizes(context).GetWidth() * 2),
                Text(
                  languageName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: foregroundColor,
                  ),
                ),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : borderColor,
                  width: 2,
                ),
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}