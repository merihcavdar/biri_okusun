import 'package:flutter/material.dart';
import 'screens/main_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 0)
class Epub {
  @HiveField(0)
  late String fileName;

  @HiveField(1)
  late String bookTitle;

  @HiveField(2)
  late String bookAuthor;
}

void main() async {
  await Hive.initFlutter();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.pink,
          fontFamily: 'Ubuntu',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              fontSize: 18.0,
            ),
          )),
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}
