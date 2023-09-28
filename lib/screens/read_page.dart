import 'dart:typed_data';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:epub_view/epub_view.dart';

late EpubController _epubController;

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
    _epubController = EpubController(
      document: EpubDocument.openAsset('assets/epubs/hukuk_tkr_2023.epub'),
      // Set start point
      epubCfi: "epubcfi(/6/0[null]!/4/8)",
    );

    //_epubController.gotoEpubCfi('epubcfi(/6/0/4/20)');
  }

  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;
  var cfi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: _epubController,
          builder: (chapterValue) => Text(
            chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
            textAlign: TextAlign.start,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              cfi = _epubController.generateEpubCfi();

              print(cfi);
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(controller: _epubController),
      ),
      body: EpubView(controller: _epubController),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _epubController.gotoEpubCfi(cfi);
          // print(_epubController.currentValue?.chapter?.HtmlContent);
          print(_epubController.currentValue?.chapter?.Title);

//          _speak();
        },
        child: const Icon(FontAwesomeIcons.microphone),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak() async {
    setState(() {
      _newVoiceText = 'merhaba, merhaba, merhaba, merhaba, merhaba';
    });
    await flutterTts.speak(_newVoiceText!);
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }
}
