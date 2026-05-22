import 'package:flutter/cupertino.dart';
import '../../Utils/TextLanguage.dart';
class LanguageProvider extends ChangeNotifier {
  final _textLanguage = TextLanguage();

  int get currentLanguage => _textLanguage.currentLanguageCode;

  void changeLanguage(int langCode) {
    _textLanguage.ChangeLanguge(langCode);
    notifyListeners();
  }
}