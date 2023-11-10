import 'dart:async';
import 'package:biri_okusun/utilities/disk.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class EpubReadAloud extends StatefulWidget {
  const EpubReadAloud({super.key, required this.fileToLoad});
  final String fileToLoad;

  @override
  State<EpubReadAloud> createState() => _EpubReadAloudState();
}

enum TtsState { playing, stopped, paused, continued }

class _EpubReadAloudState extends State<EpubReadAloud> {
  FlutterTts flutterTts = FlutterTts();
  List chapters = [];

  Future<void> configureTts() async {
    await flutterTts.setLanguage('tr-TR');
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
  }

  void speakText(String text) async {
    await flutterTts.speak(text);
  }

  void stopSpeaking() async {
    await flutterTts.stop();
  }

  @override
  void initState() {
    configureTts();
    loadEPub();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadEPub() async {
    chapters = await getEpubChapters(widget.fileToLoad);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: Drawer(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(chapters[index]),
                onTap: () {},
              );
            },
            itemCount: chapters.length,
            padding: EdgeInsets.zero,
          ),
        ),
        appBar: AppBar(
          title: const Text("hello"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.headphones),
              color: Colors.white,
              onPressed: () async {
                //String htmlContent = _parseHtmlString().trim();
                speakText("ben merih");
                //print(_epubReaderController.currentValue?.chapter?.Title);
                /* for (var i in _epubReaderController.tableOfContents()) {
                  print(i.title);
                  print(i.startIndex);
                }
                */

                //print(_epubReaderController.generateEpubCfi());
                //_epubReaderController
                //     .gotoEpubCfi('epubcfi(/6/22[chapter05]!/4/2)');
              },
            ),
            IconButton(
                icon: const Icon(Icons.save_alt),
                color: Colors.white,
                onPressed: () {}),
          ],
        ),
        body: const Center(
          child: Text("merih"),
        ),
      );
}
