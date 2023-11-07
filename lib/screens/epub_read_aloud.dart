import 'dart:io' as io;
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:epub_parser/epub_parser.dart' as eparser;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

var coverImage;

class EpubReadAloud extends StatefulWidget {
  const EpubReadAloud({super.key});

  @override
  State<EpubReadAloud> createState() => _EpubReadAloudState();
}

enum TtsState { playing, stopped, paused, continued }

class _EpubReadAloudState extends State<EpubReadAloud> {
  FlutterTts flutterTts = FlutterTts();

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
    String fileName = '/assets/epubs/kredi_yeni.epub';
    String fullPath = path.join(io.Directory.current.path, fileName);
    var targetFile = io.File(fullPath);
    List<int> bytes = await targetFile.readAsBytes();
    eparser.EpubBook epubBook = await eparser.EpubReader.readBook(bytes);
    String? title = epubBook.Title;
    String? author = epubBook.Author;

// Enumerating chapters
    epubBook.Chapters?.forEach((eparser.EpubChapter chapter) {
      // Title of chapter
      String? chapterTitle = chapter.Title;

      // HTML content of current chapter
      String? chapterHtmlContent = chapter.HtmlContent;

      // Nested chapters
      List<eparser.EpubChapter>? subChapters = chapter.SubChapters;
      print(chapterTitle);
      print(chapterHtmlContent);
      print(subChapters);
    });

// CONTENT

// Book's content (HTML files, stylesheets, images, fonts, etc.)
    eparser.EpubContent? bookContent = epubBook.Content;

// HTML & CSS

// All XHTML files in the book (file name is the key)
    Map<String, eparser.EpubTextContentFile>? htmlFiles = bookContent?.Html;

// Entire HTML content of the book
    htmlFiles?.values.forEach((eparser.EpubTextContentFile htmlFile) {
      String? htmlContent = htmlFile.Content;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
      body: Center(
        child: Image(image: coverImage),
      ));
}
