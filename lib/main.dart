import 'package:flutter/material.dart';
import 'screens/main_page.dart';

void main() async {
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
