import 'dart:io' as io;
import 'package:biri_okusun/data/database.dart';
import 'package:biri_okusun/screens/read_page.dart';
import 'package:epub_parser/epub_parser.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as img;

List<Color> colorList = [
  Colors.green.shade100,
  Colors.blue.shade100,
  Colors.grey.shade100,
  Colors.blueGrey.shade100,
  Colors.amber.shade100,
  Colors.purple.shade100,
];

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _myBox = Hive.box('myBox');
  EpubData epubData = EpubData();

  Future<io.Directory?> getDownloadPath() async {
    io.Directory? directory;
    try {
      if (io.Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = io.Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Cannot get download folder path");
    }
    return directory;
  }

  bool ifExists(String fileName) {
    for (var eachFile in epubData.bookList) {
      if (eachFile["fileName"] == fileName) {
        return false;
      }
    }
    return true;
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
        String fileName = file.name;
        setState(() {
          if (ifExists(fileName)) {
            epubData.bookList.add({
              "fileName": fileName,
              "bookTitle": "Lorem",
              "lastChapter": "Ipsum"
            });
          } else {
            var snackBar = const SnackBar(
                content: Text('Seçtiğiniz kitap zaten kitaplıkta yer alıyor.'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  void initState() {
    if (_myBox.get("EPUBDATA") == null) {
      epubData.createInitialData();
    } else {
      epubData.loadData();
    }
    print(epubData.bookList);
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
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
                      child: img.Image.asset('assets/images/biri_okusun.png'),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Seçenekler'),
                leading: const Icon(Icons.home),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
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
                setState(() {
                  epubData.bookList = [];
                  epubData.updateDatabase();
                });

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
          child: const Icon(
            FontAwesomeIcons.plus,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: 2,
          // Generate 100 widgets that display their index in the List.
          children: List.generate(epubData.bookList.length, (index) {
            return Center(
              child: Slidable(
                key: ValueKey(epubData.bookList[index]["fileName"]),

                // The start action pane is the one at the left or the top side.
                startActionPane: ActionPane(
                  // A motion is a widget used to control how the pane animates.
                  motion: const ScrollMotion(),

                  // A pane can dismiss the Slidable.
                  dismissible: DismissiblePane(onDismissed: () {
                    setState(() {
                      epubData.deleteDatabase(index);
                    });
                    print(epubData.bookList);
                  }),

                  // All actions are defined in the children parameter.
                  children: [
                    // A SlidableAction can have an icon and/or a label.
                    SlidableAction(
                      onPressed: (BuildContext context) {
                        setState(() {
                          epubData.bookList.removeAt(index);
                          epubData.updateDatabase();
                        });
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Sil',
                    ),
                  ],
                ),

                // The end action pane is the one at the right or the bottom side.

                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ReadPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 300.0,
                    margin: const EdgeInsets.only(
                      left: 8.0,
                      top: 8.0,
                      bottom: 8.0,
                      right: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: colorList[index],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            epubData.bookList[index]["bookTitle"] ?? "nope",
                            //titleList[index],
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Text(
                            epubData.bookList[index]["lastChapter"] ?? "",
                            style: const TextStyle(
                              fontSize: 14.0,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            epubData.bookList[index]["fileName"] ?? "",
                            style: const TextStyle(
                              fontSize: 10.0,
                            ),
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
