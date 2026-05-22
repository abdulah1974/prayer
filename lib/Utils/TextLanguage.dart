import 'package:get_storage/get_storage.dart';
import '../lang/ArLanguage.dart';
import '../lang/EnLanguag.dart';

class TextLanguage {
  final storage = GetStorage();

  int get currentLanguageCode => storage.read('Language') ?? 1;

  void ChangeLanguge(num) async {
    await storage.write('Language', num);
  }

  dynamic GetWord(key) {
    if (currentLanguageCode == 1) {
      return ArLanguage[key];
    } else {
      return EnLanguag[key];
    }
  }
}