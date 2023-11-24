import 'package:biri_okusun/data/database.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;
  bool getDarkMode = false;

  final _myBox = Hive.box('myBox');
  EpubData epubData = EpubData();

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  ThemeData setInitialMode() {
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

    getDarkMode = epubData.appData[0]["dark"];

    if (getDarkMode) {
      return darkMode;
    } else {
      return lightMode;
    }
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
