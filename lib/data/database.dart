import 'package:hive_flutter/hive_flutter.dart';

class EpubData {
  late List<dynamic> bookList;

  final _myBox = Hive.box('myBox');

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
