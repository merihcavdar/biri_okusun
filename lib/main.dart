import 'package:biri_okusun/data/database.dart';
import 'package:biri_okusun/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'screens/main_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('myBox');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  final _myBox = Hive.box('myBox');
  EpubData epubData = EpubData();

  @override
  void initState() {
    super.initState();

    if (_myBox.get("APPDATA") == null) {
      epubData.createAppData();
      epubData.appData.add(
        {
          "dark": false,
          "name": "",
          "locale": "tr-TR",
          "seslendirici": "Seslendirici 1",
          "speed": 0.75,
        },
      );
      epubData.updateAppData();
    } else {
      epubData.loadAppData();
    }
    isDark = epubData.appData[0]["dark"];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).setInitialMode(),
      debugShowCheckedModeBanner: false,
      home: MainPage(
        isDark: isDark,
      ),
    );
  }
}
