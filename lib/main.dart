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

  Future<void> getDarkBool() async {
    isDark = epubData.appData[0]["dark"];
  }

  @override
  void initState() {
    super.initState();
    if (_myBox.get("EPUBDATA") == null) {
      epubData.createInitialData();
    } else {
      epubData.loadData();
    }

    if (_myBox.get("APPDATA") == null) {
      epubData.createAppData();
      epubData.appData.add(
        {
          "dark": false,
          "voice": "Seslendirici 1",
          "speed": 1.0,
          "locale": "tr-TR",
        },
      );
      epubData.updateAppData();
    } else {
      epubData.loadAppData();
    }
    getDarkBool().whenComplete(
      () {
        setState(
          () {},
        );
      },
    );
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
