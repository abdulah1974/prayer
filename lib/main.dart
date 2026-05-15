import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayer/Screen/Location/Location.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   // final selectedIndex = ref.watch(language_riverpod);
    final languages = ['en','ar'];
    final language = languages[1];
    return MaterialApp(
      title: 'Sakina',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      locale: language == 'ar' ? const Locale('ar') : const Locale('en'),
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
        // يمكنك تغيير الخط هنا إذا قمت بإضافة خطوط عربية مثل 'Amiri'
      ),
      home: const MyHomePage(title: 'Sakina'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    LanguageInit();
    super.initState();
  }
  void LanguageInit() async {
    final storage = GetStorage();
    await storage.writeIfNull('Language', 1);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Location(title: "title")
    );
  }
}