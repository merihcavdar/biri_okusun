import 'package:biri_okusun/data/database.dart';
import 'package:biri_okusun/utilities/disk.dart';
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
  int selectedVoiceIndex = 0;
  TextEditingController textControler = TextEditingController();
  List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.50];
  List<bool> toggleButtonValues = [false, false, true, false, false];
  List<String> options = ['0.5x', '0.75x', '1.0x', '1.25x', '1.50x'];
  final _myBox = Hive.box('myBox');
  EpubData epubData = EpubData();

  FlutterTts flutterTts = FlutterTts();

  String _selectedVoice = "";

  final _formKey = GlobalKey<FormState>();
  List<String> items = [];
  List<String> names = [];

  String selectedValue = "";
  late dynamic allTheVoices;

  List<Map<String, String>> voices = [];

  Future<void> configureTts() async {
    allTheVoices = await flutterTts.getVoices;
    voices = [];
    items = [];
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
    for (var i = 0; i < voices.length; i++) {
      items.add(voices[i]["item"]!);
      names.add(voices[i]["name"]!);
    }
    if (epubData.appData[0]["name"] == null) {
      epubData.appData[0]["name"] = names[0];
    }
    print(names);
    print(selectedVoiceIndex);

    await flutterTts.setLanguage('tr-TR');
    await flutterTts.setSpeechRate(
      epubData.appData[0]["speed"],
    );

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
    textControler.text =
        "Yükselme sınavlarına hazırlık kitaplarımız, tüm çalışanlarımıza bankacılık konuları ve Bankamız uygulamaları hakkında yol gösterici olmak, çalışanlarımızın teknik yetkinliklerini geliştirme çabalarını desteklemek amacı ile yayınlanmaktadır.";

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
          "voice": "Seslendirici 1",
          "speed": 1.0,
          "locale": "tr-TR",
        },
      );
      epubData.updateAppData();
    } else {
      epubData.loadAppData();
    }
    setState(
      () {
        _selectedVoice = epubData.appData[0]["voice"];
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
    String plainText = parseHtmlString(text);

    await flutterTts.speak(plainText).whenComplete(
      () {
        setState(
          () {},
        );
      },
    );
  }

  void stopSpeaking() async {
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
          title: const Text('Ayarlar'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            epubData.appData[0]["voice"] = _selectedVoice;
            epubData.updateAppData();
            Navigator.pop(context);
          },
          child: Icon(
            FontAwesomeIcons.floppyDisk,
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
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedVoice,
                    items: items.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(
                        () {
                          selectedVoiceIndex = items.indexOf(newValue!);
                          _selectedVoice = newValue;
                          epubData.appData[0]["name"] =
                              items[selectedVoiceIndex];
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
                        int index = options.indexOf(option);
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
                    ),
                  ),
                  TextField(
                    readOnly: true,
                    controller: textControler,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 6,
                    textAlign: TextAlign.justify,
                    onChanged: ((value) {}),
                    decoration: InputDecoration(
                      hintMaxLines: 1,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 10),
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
                  ElevatedButton(
                    onPressed: () {
                      speakText(textControler.text);
                    },
                    child: const Text("Test Et"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
