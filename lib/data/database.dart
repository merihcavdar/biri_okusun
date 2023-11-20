import 'package:hive_flutter/hive_flutter.dart';

class EpubData {
  late List<dynamic> bookList;
  late List<dynamic> appData;

  final _myBox = Hive.box('myBox');

  void createAppData() {
    appData = [];
  }

  void loadAppData() {
    appData = _myBox.get("APPDATA");
  }

  void updateAppData() {
    _myBox.put("APPDATA", appData);
  }

  void createInitialData() {
    bookList = [];
  }

  void loadData() {
    bookList = _myBox.get("EPUBDATA");
  }

  void updateDatabase() {
    _myBox.put("EPUBDATA", bookList);
  }

  void deleteDatabase(int index) {
    bookList.removeAt(index);
    _myBox.put("EPUBDATA", bookList);
  }
}
