import 'dart:io' as io;
import 'package:biri_okusun/data/database.dart';
import 'package:biri_okusun/screens/epub_read_aloud.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as img;
import '../utilities/disk.dart';
import '../theme/theme_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.isDark});
  final bool isDark;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<String> items = [];
  String selectedValue = "";
  late dynamic allTheVoices;

  List<Map<String, String>> voices = [];
  FlutterTts flutterTts = FlutterTts();

  String setVoice = "Seslendirici 1";

  bool darkMode = false;
  final _myBox = Hive.box('myBox');
  EpubData epubData = EpubData();
  late String fileName;

  bool ifExists(String fileName) {
    for (var eachFile in epubData.bookList) {
      if (eachFile["fileName"] == fileName) {
        return true;
      }
    }
    return false;
  }

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

  Future<void> pickFile() async {
    io.Directory? downloadPath = await getDownloadsDirectory();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        initialDirectory: downloadPath!.path,
        allowMultiple: false,
        allowedExtensions: ["epub"],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        fileName = file.name;
        List fileDetails = [];
        fileDetails = await getEpubDetails(fileName);
        setState(
          () {
            if (!ifExists(fileName)) {
              epubData.bookList.add(
                {
                  "bookTitle": fileDetails[0],
                  "lastChapter": fileDetails[1],
                  "fileName": fileDetails[2],
                  "author": fileDetails[3],
                  "lastIndex": fileDetails[4],
                },
              );
              epubData.updateDatabase();
            } else {
              var snackBar = SnackBar(
                content:
                    Text('Seçtiğiniz $fileName zaten kitaplıkta yer alıyor.'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
        );
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (_myBox.get("EPUBDATA") == null) {
      epubData.createInitialData();
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
    configureTts().whenComplete(() {
      setState(
        () {},
      );
    });
    darkMode = widget.isDark;
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Biri Okusun',
                      style: TextStyle(
                        fontFamily: 'Alkatra',
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                      child: img.Image.asset(
                        'assets/images/biri_okusun.png',
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Ayarlar'),
                leading: const Icon(Icons.home),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  )
                      .then(
                    (value) {
                      setState(
                        () {},
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Hakkında'),
                leading: const Icon(Icons.info),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text(
            'Kitaplık',
            style: TextStyle(
              fontFamily: 'Alkatra',
              fontSize: 24.0,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
                darkMode = !darkMode;
                epubData.appData[0]["dark"] = darkMode;
                epubData.updateAppData();
              },
              icon: darkMode
                  ? const Icon(Icons.light_mode)
                  : const Icon(Icons.dark_mode),
            ),
            IconButton(
              onPressed: () {
                setState(
                  () {
                    epubData.bookList = [];
                    epubData.updateDatabase();
                  },
                );

                /*Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsPage()));
              */
              },
              icon: const Icon(FontAwesomeIcons.gear),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            pickFile();
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Icon(
            FontAwesomeIcons.plus,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: GridView.count(
          crossAxisCount: 2,
          children: List.generate(epubData.bookList.length, (index) {
            return Center(
              child: Slidable(
                key: ValueKey(
                  epubData.bookList[index]["fileName"],
                ),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  dismissible: DismissiblePane(
                    onDismissed: () {
                      setState(() {
                        epubData.deleteDatabase(index);
                      });
                    },
                  ),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext context) {
                        setState(
                          () {
                            epubData.deleteDatabase(index);
                          },
                        );
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Sil',
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => EpubReadAloud(
                          fileToLoad: epubData.bookList[index]["fileName"],
                          indexNo: index,
                        ),
                      ),
                    )
                        .then(
                      (value) {
                        setState(
                          () {},
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 500.0,
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(
                      left: 8.0,
                      top: 8.0,
                      bottom: 8.0,
                      right: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            epubData.bookList[index]["bookTitle"],
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Text(
                            epubData.bookList[index]["author"],
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            epubData.bookList[index]["lastChapter"],
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
