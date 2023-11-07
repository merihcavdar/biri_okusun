import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class EpubReadAloud extends StatefulWidget {
  const EpubReadAloud({super.key});

  @override
  State<EpubReadAloud> createState() => _EpubReadAloudState();
}

enum TtsState { playing, stopped, paused, continued }

class _EpubReadAloudState extends State<EpubReadAloud> {
  late EpubController _epubReaderController;

  FlutterTts flutterTts = FlutterTts();

  Future<void> configureTts() async {
    await flutterTts.setLanguage('tr-TR');
    await flutterTts.setSpeechRate(1.5);
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
    _epubReaderController = EpubController(
      document: EpubDocument.openAsset('assets/epubs/ithalat-ihracat.epub'),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _epubReaderController.dispose();
  }

  String _parseHtmlString(String? htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement!.text;

    return parsedString;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: EpubViewActualChapter(
            controller: _epubReaderController,
            builder: (chapterValue) => Text(
              chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
              textAlign: TextAlign.start,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.headphones),
              color: Colors.white,
              onPressed: () async {
                String htmlContent = _parseHtmlString(_epubReaderController
                        .currentValue?.chapter?.HtmlContent)
                    .trim();
                print(htmlContent);

                speakText(htmlContent);
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
                onPressed: () {
                  _showCurrentEpubCfi(context);
                }),
          ],
        ),
        drawer: Drawer(
          child: EpubViewTableOfContents(controller: _epubReaderController),
        ),
        body: EpubView(
          builders: EpubViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(),
            chapterDividerBuilder: (_) => const Divider(),
          ),
          controller: _epubReaderController,
        ),
      );

  void _showCurrentEpubCfi(context) {
    final cfi = _epubReaderController.generateEpubCfi();

    if (cfi != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cfi),
          action: SnackBarAction(
            label: 'GO',
            onPressed: () {
              _epubReaderController.gotoEpubCfi(cfi);
            },
          ),
        ),
      );
    }
  }
}
