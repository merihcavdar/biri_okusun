import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/drop_list.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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
  double _speedValue = 1;
  double _pitchValue = 0;

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
                const DropList(
                    titleText: "Seslendiren",
                    hintText: "Seslendirici seçiniz",
                    items: ["Ayşe", "Gamze", "Kemal", "Harun"],
                    selectedItem: "Gamze"),
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
                SfSlider(
                  stepSize: .25,
                  min: 0.50,
                  max: 2,
                  value: _speedValue,
                  interval: 0.25,
                  showTicks: true,
                  showLabels: true,
                  enableTooltip: true,
                  minorTicksPerInterval: 0,
                  onChanged: (dynamic value) {
                    setState(() {
                      _speedValue = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 32.0,
                ),
                const Text(
                  'Ses Kalınlığı',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SfSlider(
                  stepSize: 5,
                  min: -20.0,
                  max: 20.0,
                  value: _pitchValue,
                  interval: 10,
                  showTicks: true,
                  showLabels: true,
                  enableTooltip: true,
                  minorTicksPerInterval: 1,
                  onChanged: (dynamic value) {
                    setState(() {
                      _pitchValue = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
