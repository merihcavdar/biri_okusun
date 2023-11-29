import 'dart:io';

import 'package:biri_okusun/data/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double defaultSpeed;
  bool testButtonVisible = true;

  int selectedVoiceIndex = 0;
  TextEditingController textControler = TextEditingController();
  List<double> speeds = [];

  List<bool> toggleButtonValues = [false, false, false, false, false];
  List<String> options = ['0.5x', '0.75x', '1.0x', '1.25x', '1.50x'];
  final _myBox = Hive.box('myBox');
  EpubData epubData = EpubData();

  FlutterTts flutterTts = FlutterTts();

  String _selectedVoice = "";

  final _formKey = GlobalKey<FormState>();

  List<String> seslendiriciler = [];
  List<String> names = [];

  String selectedValue = "";

  late List<dynamic> allTheVoices;

  List<Map<String, String>> voices = [];

  Future<void> getVoiceData() async {
    allTheVoices = await flutterTts.getVoices;
    voices = [];
    seslendiriciler = [];
    int i = 1;
    for (var voice in allTheVoices) {
      if (voice["locale"] == "tr-TR") {
        voices.add(
          {
            "name": voice["name"],
            "locale": voice["locale"],
            "seslendirici": "Seslendirici $i"
          },
        );
        i++;
      }
    }

    for (var i = 0; i < voices.length; i++) {
      seslendiriciler.add(voices[i]["seslendirici"]!);
      names.add(voices[i]["name"]!);
    }
    if (epubData.appData[0]["name"] == "") {
      epubData.appData[0]["name"] = names[0];
      epubData.updateAppData();
    }
    setState(
      () {
        for (var i = 0; i < toggleButtonValues.length; i++) {
          toggleButtonValues[i] = false;
        }
        toggleButtonValues[speeds.indexOf(epubData.appData[0]["speed"])] = true;
      },
    );
  }

  Future<void> configureTts() async {
    await flutterTts.setLanguage('tr-TR');
    await flutterTts.setSpeechRate(
      epubData.appData[0]["speed"],
    );
    await flutterTts.setVolume(1.0);

    await flutterTts.setVoice(
      {
        "name": epubData.appData[0]["name"],
        "locale": epubData.appData[0]["locale"],
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      speeds = [
        0.25,
        0.50,
        0.75,
        1.0,
        1.25,
      ];
    } else if (Platform.isIOS) {
      speeds = [
        0.10,
        0.20,
        0.35,
        0.50,
        0.75,
      ];
    }
    if (Platform.isAndroid) {
      defaultSpeed = 0.5;
    } else if (Platform.isIOS) {
      defaultSpeed = 0.2;
    }
    flutterTts.awaitSpeakCompletion(true);
    flutterTts.setCompletionHandler(
      () {
        setState(
          () {
            testButtonVisible = true;
          },
        );
      },
    );
    textControler.text =
        "Yükselme sınavlarına hazırlık kitaplarımız, tüm çalışanlarımıza bankacılık konuları ve Bankamız uygulamaları hakkında yol gösterici olmak, çalışanlarımızın teknik yetkinliklerini geliştirme çabalarını desteklemek amacı ile yayınlanmaktadır.";
    getVoiceData().whenComplete(
      () {
        setState(
          () {},
        );
      },
    );
    configureTts().whenComplete(
      () {
        setState(() {});
      },
    );
    if (_myBox.get("APPDATA") == null) {
      epubData.createAppData();
      epubData.appData.add(
        {
          "dark": false,
          "name": "",
          "voice": "Seslendirici 1",
          "locale": "tr-TR",
          "speed": defaultSpeed,
        },
      );
      epubData.updateAppData();
    } else {
      epubData.loadAppData();
    }
    setState(
      () {
        _selectedVoice = epubData.appData[0]["seslendirici"];
      },
    );
  }

  void speakText(String text) async {
    await flutterTts.awaitSpeakCompletion(true).whenComplete(
      () {
        setState(
          () {},
        );
      },
    );
    await flutterTts.speak(text).whenComplete(
      () {
        setState(
          () {},
        );
      },
    );
  }

  void stopSpeaking() async {
    setState(
      () {
        testButtonVisible = true;
      },
    );
    await flutterTts.stop().whenComplete(
      () {
        setState(
          () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Ayarlar',
            style: TextStyle(
              fontFamily: 'Alkatra',
              fontSize: 24.0,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            stopSpeaking();
            epubData.appData[0]["seslendirici"] = _selectedVoice;

            epubData.updateAppData();
            Navigator.pop(context);
          },
          child: Icon(
            FontAwesomeIcons.solidFloppyDisk,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(
              12.0,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Seslendirici seçiniz:",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedVoice,
                    items: seslendiriciler.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(
                        () {
                          selectedVoiceIndex =
                              seslendiriciler.indexOf(newValue!);
                          _selectedVoice = newValue;
                          epubData.appData[0]["seslendirici"] =
                              seslendiriciler[selectedVoiceIndex];
                          epubData.appData[0]["name"] =
                              names[selectedVoiceIndex];
                          epubData.updateAppData();
                          configureTts();
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  Text(
                    "Konuşma hızı seçiniz:",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  ToggleButtons(
                    isSelected: toggleButtonValues,
                    onPressed: (int index) {
                      setState(
                        () {
                          for (int i = 0; i < toggleButtonValues.length; i++) {
                            toggleButtonValues[i] = false;
                          }
                          toggleButtonValues[index] = true;
                        },
                      );
                      epubData.appData[0]["speed"] = speeds[index];
                      epubData.updateAppData();
                      configureTts();
                    },
                    children: options.map(
                      (option) {
                        return Text(option);
                      },
                    ).toList(),
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Text(
                    "Örnek metin",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  TextField(
                    style: const TextStyle(
                      //color: Theme.of(context).colorScheme.primary,
                      color: Colors.black,
                    ),
                    readOnly: true,
                    controller: textControler,
                    //keyboardType: TextInputType.multiline,
                    //textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 6,
                    textAlign: TextAlign.justify,
                    onChanged: ((value) {}),
                    decoration: InputDecoration(
                      hintMaxLines: 1,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 10,
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 0.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Colors.black26,
                          width: 0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  testButtonVisible
                      ? ElevatedButton(
                          onPressed: () {
                            if (testButtonVisible) {
                              speakText(textControler.text);
                              testButtonVisible = !testButtonVisible;
                            }
                          },
                          child: const Text("Test Et"),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
