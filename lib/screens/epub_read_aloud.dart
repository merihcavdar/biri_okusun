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
  int loopCount = 1;
  final List<String> items = [];
  late dynamic allTheVoices;

  List<Map<String, String>> voices = [];

  TtsState ttsState = TtsState.stopped;
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

    allTheVoices = await flutterTts.getVoices;
    int i = 1;
    for (var voice in allTheVoices) {
      if (voice["locale"] == "tr-TR") {
        voices.add(
          {
            "name": voice["name"],
            "locale": voice["locale"],
            "item": "Seslendirici $i"
          },
        );
        i++;
      }
    }
    String voiceName = "";
    for (var voice in voices) {
      voiceName = voice["name"]!;
      if (voice["item"] == epubData.appData[0]["voice"]) {
        await flutterTts.setVoice(
          {"name": voiceName, "locale": "tr-TR"},
        );
      }
    }
  }

  void speakText(String text) async {
    await flutterTts.awaitSpeakCompletion(true);
    String plainText = parseHtmlString(text);
    int count = plainText.length;
    print("length of text: $count");
    int max = 4000;
    loopCount = count ~/ max;
    print("loopcount value: $loopCount");

    for (var i = 0; i <= loopCount; i++) {
      if (i != loopCount) {
        await flutterTts.speak(
          plainText.substring(i * max, (i + 1) * max),
        );
      } else {
        int end = (count - ((i * max)) + (i * max));
        await flutterTts.speak(
          plainText.substring(i * max, end),
        );
      }
    }
  }

  void stopSpeaking() async {
    await flutterTts.awaitSpeakCompletion(false);
    await flutterTts.stop();
  }

  @override
  void initState() {
    super.initState();
    if (_myBox.get("EPUBDATA") == null) {
      epubData.createInitialData();
      epubData.updateDatabase();
    } else {
      epubData.loadData();
    }

    if (_myBox.get("APPDATA") == null) {
      epubData.createAppData();
      epubData.appData.add(
        {
          "dark": false,
          "voice": "Seslendirici 1",
          "speed": 1.0,
        },
      );
      epubData.updateAppData();
    } else {
      epubData.loadAppData();
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
    int num = (epubBook.Chapters?.elementAt(chapterIndex)
                .HtmlContent
                .toString()
                .indexOf("</title>") ??
            0) +
        8;

    setState(
      () {
        chapterContent = epubBook.Chapters?.elementAt(chapterIndex)
            .HtmlContent
            ?.replaceRange(0, num, " ");
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
      epubData.bookList[widget.indexNo]["lastIndex"] = chapterIndex;
      epubData.bookList[widget.indexNo]["lastChapter"] =
          chapters.elementAt(chapterIndex);
      epubData.updateDatabase();
    }
    int num = (epubBook.Chapters?.elementAt(chapterIndex)
                .HtmlContent
                .toString()
                .indexOf("</title>") ??
            0) +
        8;

    setState(
      () {
        chapterContent = epubBook.Chapters?.elementAt(chapterIndex)
            .HtmlContent
            ?.replaceRange(0, num, " ");
      },
    );
  }

  Future<void> prevChapter() async {
    if (chapterIndex > 0) {
      chapterIndex--;
      epubData.bookList[widget.indexNo]["lastIndex"] = chapterIndex;
      epubData.bookList[widget.indexNo]["lastChapter"] =
          chapters.elementAt(chapterIndex);
      epubData.updateDatabase();
    }
    int num = (epubBook.Chapters?.elementAt(chapterIndex)
                .HtmlContent
                .toString()
                .indexOf("</title>") ??
            0) +
        8;
    setState(() {
      chapterContent = epubBook.Chapters?.elementAt(chapterIndex)
          .HtmlContent
          ?.replaceRange(0, num, " ");
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
                    epubData.bookList[widget.indexNo]["lastIndex"] = index;
                    epubData.bookList[widget.indexNo]["lastChapter"] =
                        chapters.elementAt(chapterIndex);
                    epubData.updateDatabase();
                    int num = (epubBook.Chapters?.elementAt(index)
                                .HtmlContent
                                .toString()
                                .indexOf("</title>") ??
                            0) +
                        8;
                    setState(
                      () {
                        chapterContent = epubBook.Chapters?.elementAt(index)
                            .HtmlContent
                            ?.replaceRange(0, num, " ");
                        chapterIndex = index;
                      },
                    );
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
              setState(
                () {
                  readingAloud = false;
                },
              );
            } else {
              speakText(chapterContent!);
              flutterTts.setCompletionHandler(() {
                setState(() {
                  nextChapter();
                  speakText(chapterContent!);
                });
              });
              setState(
                () {
                  readingAloud = true;
                },
              );
            }
          },
          child: readingAloud
              ? Icon(
                  Icons.stop_circle_outlined,
                  color: Theme.of(context).colorScheme.primary,
                )
              : Icon(
                  Icons.headphones,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
        body: SingleChildScrollView(
          child: HtmlWidget(chapterContent!),
        ),
      );
}
