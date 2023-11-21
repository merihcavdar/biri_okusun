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
  final _myBox = Hive.box('myBox');
  EpubData epubData = EpubData();

  FlutterTts flutterTts = FlutterTts();

  String _selectedVoice = "Seslendirici 1";

  final _formKey = GlobalKey<FormState>();
  final List<String> items = [];
  String selectedValue = "";
  late dynamic allTheVoices;

  List<Map<String, String>> voices = [];

  Future<void> configureTts() async {
    await flutterTts.setLanguage('tr-TR');
    await flutterTts.setSpeechRate(1.0);
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
    for (var i = 0; i < voices.length; i++) {
      items.add(voices[i]["item"]!);
    }
  }

  @override
  void initState() {
    super.initState();
    configureTts().whenComplete(
      () {
        setState(() {});
      },
    );
    if (_myBox.get("APPDATA") == null) {
      epubData.createAppData();
      epubData.appData.add({
        "dark": false,
        "voice": "",
        "speed": 1.0,
      });
      epubData.updateAppData();
    } else {
      epubData.loadAppData();
    }
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                        _selectedVoice = newValue!;
                      },
                    );
                    print(_selectedVoice);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
