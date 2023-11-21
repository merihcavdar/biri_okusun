import 'package:biri_okusun/data/database.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;
  bool getDarkMode = false;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  ThemeData setInitialMode() {
    final _myBox = Hive.box('myBox');
    EpubData epubData = EpubData();

    if (_myBox.get("APPDATA") == null) {
      epubData.createAppData();
      epubData.appData.add({
        "dark": false,
        "voice": "",
        "speed": 1.0,
      });
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
