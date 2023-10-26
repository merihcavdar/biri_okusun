import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:epub_kitty_lib/epub_kitty_lib.dart';
import 'package:path_provider/path_provider.dart';

class ReadPage extends StatefulWidget {
  const ReadPage({super.key});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

enum TtsState { playing, stopped, paused, continued }

class _ReadPageState extends State<ReadPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Biri Okusun'),
        ),
        body: Center(
          child: CupertinoButton(
            color: Colors.blue,
            onPressed: () async {
              Directory appDocDir = await getApplicationDocumentsDirectory();
              print('$appDocDir');

              String androidBookPath =
                  'file:///android_asset/PhysicsSyllabus.epub';
              EpubKitty.setConfig(
                identifier: "iosBook",
                themeColor: const Color(0xff32a852),
                scrollDirection: EKScrollDirection.horizontal,
                allowSharing: true,
                shouldHideNavigationOnTap: false,
              );

              EpubKitty.open(androidBookPath);
            },
            child: const Text('Open Epub',
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
        ),
      ),
    );
  }
}
