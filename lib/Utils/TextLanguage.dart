import 'package:get_storage/get_storage.dart';
import '../lang/ArLanguage.dart';
import '../lang/EnLanguag.dart';
class TextLanguage {
  final storage = GetStorage();
  late int Language;
  int Templanguage = 0;
  void ChangeLanguge(num) async {
    await storage.write('Language', num);
  }

  dynamic GetWord(key) {
    Language = storage.read("Language");
    if (Language == 1) {
      return ArLanguage[key];
    } else {
      return EnLanguag[key];
    }
  }
}