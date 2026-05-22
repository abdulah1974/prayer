import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // تأكد من إضافة مكتبة provider في pubspec.yaml
import '../../Widget/CustomBottomNavBar.dart';
import '../Qibla/Qibla.dart';
import '../Setting/Setting.dart';
import '../Time/Time.dart';
import 'BottomNavBarProvider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
       create: (_) => BottomNavBarProvider(),
       builder: (context, child) {
         final navProvider = Provider.of<BottomNavBarProvider>(context);
         return Scaffold(
           body: IndexedStack(
             index: navProvider.currentIndex,
             children: const [
               Center(child: Time()),
               Center(child: Qibla()),
               Center(child: Setting()),
             ],
           ),
           bottomNavigationBar: CustomBottomNavBar(
             currentIndex: navProvider.currentIndex,
             onTap: (index) {
               // استدعاء دالة التغيير من الـ Provider
               navProvider.changeIndex(index);
             },
           ),
         );
       }
    );
  }
}