import 'dart:async';
import 'dart:io' as io;
import 'package:biri_okusun/utilities/disk.dart';
import 'package:epub_parser/epub_parser.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:biri_okusun/data/database.dart';
import 'package:path/path.dart' as path;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EpubReadAloud extends StatefulWidget {
  const EpubReadAloud({
    super.key,
    required this.fileToLoad,
    required this.indexNo,
  });
  final String fileToLoad;
  final int indexNo;

  @override
  State<EpubReadAloud> createState() => _EpubReadAloudState();
}

enum TtsState { playing, stopped, paused, continued }

class _EpubReadAloudState extends State<EpubReadAloud> {
  // ignore: unused_field
  final _myBox = Hive.box('myBox');
  EpubData epubData = EpubData();
  EpubBook epubBook = EpubBook();

  int chapterIndex = 0;
  bool readingAloud = false;
  String? chapterContent = "";

  List fileDetails = [];
  FlutterTts flutterTts = FlutterTts();
  List<String> chapters = [];

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
    super.initState();
    if (_myBox.get("EPUBDATA") == null) {
      epubData.createInitialData();
    } else {
      epubData.loadData();
    }
    chapterIndex = epubData.bookList[widget.indexNo]["lastIndex"];
    configureTts();

    getEpub().whenComplete(() {
      setState(() {});
    });
    loadEpub().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> loadEpub() async {
    fileDetails = await getEpubDetails(widget.fileToLoad);
    chapters = await getEpubChapters(widget.fileToLoad);
  }

  Future<void> getEpub() async {
    io.Directory? downloadDirectory = await getDownloadPath();
    String fullPath = path.join(downloadDirectory!.path, widget.fileToLoad);
    var targetFile = io.File(fullPath);
    List<int> bytes = await targetFile.readAsBytes();
    epubBook = await EpubReader.readBook(bytes);
    setState(
      () {
        chapterContent = epubBook.Chapters?.elementAt(chapterIndex).HtmlContent;
      },
    );
    /*epubBook.Chapters?.forEach(
        (EpubChapter chapter) {
          String? chapterTitle = chapter.Title;
          print(chapterTitle);
          String? chapterHtmlContent = chapter.HtmlContent;
          List<EpubChapter>? subChapters = chapter.SubChapters;
        },
      );
      */
  }

  Future<void> nextChapter() async {
    if (chapterIndex < epubBook.Chapters!.length) {
      chapterIndex++;
    }
    setState(() {
      chapterContent = epubBook.Chapters?.elementAt(chapterIndex).HtmlContent;
    });
  }

  Future<void> prevChapter() async {
    if (chapterIndex > 0) {
      chapterIndex--;
    }
    setState(() {
      chapterContent = epubBook.Chapters?.elementAt(chapterIndex).HtmlContent;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: SafeArea(
          child: Drawer(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(chapters[index]),
                  onTap: () {
                    stopSpeaking();
                    readingAloud = false;
                    Navigator.of(context).pop();
                    epubData.bookList[index]["lastIndex"] = index;
                    epubData.updateDatabase();
                    setState(() {
                      chapterIndex = index;
                      chapterContent =
                          epubBook.Chapters?.elementAt(index).HtmlContent;
                    });
                  },
                );
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        appBar: AppBar(
          title: Text(epubData.bookList[widget.indexNo]["bookTitle"]),
          actions: <Widget>[
            IconButton(
              icon: const Icon(FontAwesomeIcons.arrowLeft),
              //icon: const Icon(Icons.skip_previous),
              color: Colors.white,
              onPressed: () {
                setState(
                  () {
                    prevChapter();
                  },
                );
              },
            ),
            IconButton(
                icon: const Icon(FontAwesomeIcons.arrowRight),
                color: Colors.white,
                onPressed: () {
                  nextChapter();
                }),
            IconButton(
                icon: const Icon(Icons.close),
                //icon: const Icon(Icons.exit_to_app_outlined),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (readingAloud) {
              stopSpeaking();
              setState(() {
                readingAloud = false;
              });
            } else {
              speakText(chapterContent!);
              setState(() {
                readingAloud = true;
              });
            }
          },
          child: readingAloud
              ? const Icon(Icons.stop_circle_outlined)
              : const Icon(Icons.headphones),
        ),
        body: SingleChildScrollView(
          child: HtmlWidget(chapterContent!),
        ),
      );
}
