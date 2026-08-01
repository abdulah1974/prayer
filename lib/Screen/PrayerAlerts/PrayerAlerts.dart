import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Widget/IslamicPatternPainter.dart';
import 'PrayerAlertsProvider.dart';
import 'package:flutter_svg/flutter_svg.dart';
class PrayerAlerts extends StatelessWidget {
  const PrayerAlerts({super.key});

  static const Color backgroundColor = Color(0xFFFBF9F4);
  static const Color foregroundColor = Color(0xFF3D3A33);
  static const Color cardColor = Color(0xE6FFFFFF);
  static const Color primaryColor = Color(0xFF8B7E66);
  static const Color mutedForegroundColor = Color(0xFF7A7468);
  static const Color borderColor = Color(0xFFE3DED3);

  static final prayers = [
    ('الفجر', Icons.wb_twilight_rounded),
    ('الضهر', Icons.wb_sunny_rounded),
    ('العصر', Icons.cloud_rounded),
    ('المغرب', Icons.wb_twilight_rounded),
    ('العشاء', Icons.nights_stay_rounded),
  ];

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes(context).GetWidth() * 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: Sizes(context).GetHeight() * 2),
                  Consumer<PrayerAlertsProvider>(
                    builder: (context, provider, _) {
                      return Column(
                        children: prayers.map((p) {
                          final name = p.$1;
                          final selected = provider.alerts[name] ?? AlertType.sound;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PrayerAlertRow(
                              prayerName: TextLanguage().GetWord(name) ?? name,
                              iconPath: provider.getPrayerIcon(name),
                              selected: selected,
                              onChanged: (type) => provider.setAlert(name, type),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: Sizes(context).GetHeight() * 4), // مسافة أسفل آمنة
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                width: Sizes(context).GetWidth() * 11.5,
                height: Sizes(context).GetWidth() * 11.5,
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
              TextLanguage().GetWord('تنبيهات الصلاة'),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PrayerAlertRow extends StatelessWidget {
  final String prayerName;
  final String iconPath;
  final AlertType selected;
  final ValueChanged<AlertType> onChanged;

  const PrayerAlertRow({
    super.key,
    required this.prayerName,
    required this.iconPath,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3DED3)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: Sizes(context).GetWidth()*10,
                height: Sizes(context).GetWidth()*10,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E1D1).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: Sizes(context).GetWidth()*6,
                    height: Sizes(context).GetWidth()*6,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF5C5446),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                prayerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF2D2A24),
                ),
              ),
            ],
          ),
          _ToggleGroup(selected: selected, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ToggleGroup extends StatelessWidget {
  final AlertType selected;
  final ValueChanged<AlertType> onChanged;

  const _ToggleGroup({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDE4).withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3DED3)),
      ),
      child: Row(
        children: [
          _ToggleButton(
            icon: Icons.volume_up_rounded,
            isActive: selected == AlertType.sound,
            activeColor: const Color(0xFF8B7E66),
            onTap: () => onChanged(AlertType.sound),
          ),
          _ToggleButton(
            icon: Icons.notifications_off_rounded,
            isActive: selected == AlertType.off,
            activeColor: const Color(0xFF9E5F5F),
            onTap: () => onChanged(AlertType.off),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? const [BoxShadow(color: Color(0x1A000000), blurRadius: 3)]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? activeColor : const Color(0xFF7A7468),
        ),
      ),
    );
  }
}