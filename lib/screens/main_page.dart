import 'dart:io' as io;
import 'package:biri_okusun/screens/read_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

List<Color> colorList = [
  Colors.pink,
  Colors.blue,
  Colors.green,
  Colors.amber,
  Colors.purple,
  Colors.brown
];

List<String> titleList = [
  'Ürünlerimiz',
  'Kredi',
  'Hukuk',
  'İstihbarat',
  'İthalat-İhracat',
  'Döviz'
];

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<io.Directory?> getDownloadPath() async {
    io.Directory? directory;
    try {
      if (io.Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = io.Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Cannot get download folder path");
    }
    return directory;
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
        print(result.files.single.path);
        print('File picked: ${file.name}');
        print('File path: ${file.path}');
        print('File size: ${file.size}');
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print('Error picking file: $e');
    }
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
                        child: Image.asset('assets/images/biri_okusun.png')),
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsPage()));
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
          children: List.generate(6, (index) {
            return Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ReadPage(),
                    ),
                  );
                },
                child: Container(
                  width: 180.0,
                  height: 300.0,
                  margin: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: colorList[index],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          titleList[index],
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        const Text(
                          '23.07.2023',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        )
                      ],
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
