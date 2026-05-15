import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:prayer/Utils/Sizes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: const Border(
          top: BorderSide(color: Color(0xFFE3DED3), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.access_time_filled_rounded,
                    inactiveIcon: Icons.access_time_rounded,
                    label: 'Times',
                    context: context,
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.explore_rounded,
                    inactiveIcon: Icons.explore_outlined,
                    label: 'Qibla',
                    context: context,
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.settings_rounded,
                    inactiveIcon: Icons.settings_outlined,
                    label: 'Settings',
                    context: context,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData inactiveIcon,
    required String label,
    required BuildContext context,
  }) {
    final bool isActive = currentIndex == index;
    final Color primaryColor = const Color(0xFF8B7E66);
    final Color mutedColor = const Color(0xFF7A7468);
    final Sizes size = Sizes(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isActive)
                  Container(
                    width: size.GetHeight()*4.2,
                    height: size.GetHeight()*4.2,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                Icon(
                  isActive ? icon : inactiveIcon,
                  color: isActive ? primaryColor : mutedColor,
                ),
              ],
            ),
             SizedBox(height: size.GetHeight()*0.2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primaryColor : mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
