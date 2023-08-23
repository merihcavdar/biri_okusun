import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/drop_list.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> items = [
    'Kemal',
    'Ayşe',
    'Fatma',
  ];
  String selectedValue = "Kemal";

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
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DropList(
                    titleText: "Seslendiren",
                    hintText: "Seslendirici seçiniz",
                    items: ["Ayşe", "Gamze", "Kemal", "Harun"],
                    selectedItem: "Gamze"),
                DropList(
                    titleText: "Okuma Hızı",
                    hintText: "Hız seçiniz",
                    items: ["0.50x", "0.75x", "1.0x", "1.5x", "1.75x", "2.0x"],
                    selectedItem: "1.0x"),
                DropList(
                    titleText: "Ses Kalınlığı",
                    hintText: "Kalınlık seçiniz",
                    items: ["-20", "-10", "-5", "0", "5", "10", "20"],
                    selectedItem: "0")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
