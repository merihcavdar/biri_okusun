import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/drop_list.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  FlutterTts flutterTts = FlutterTts();

  final _formKey = GlobalKey<FormState>();
  final List<String> items = [];
  String selectedValue = "";
  late List<String> allTheVoices;

  Future<void> configureTts() async {
    await flutterTts.setLanguage('tr-TR');
    await flutterTts.setSpeechRate(1.0);
    allTheVoices = await flutterTts.getVoices;
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    configureTts().whenComplete(() {
      setState(() {});
    });
    print(allTheVoices);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(FontAwesomeIcons.floppyDisk),
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
                DropList(
                    titleText: "Seslendiren",
                    hintText: "Seslendirici seçiniz",
                    //items: ["Gamze", "Mehmet"],
                    items: allTheVoices.toList(),
                    selectedItem: ""),
                const SizedBox(
                  height: 22.0,
                ),
                const Text(
                  'Okuma Hızı',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 32.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
