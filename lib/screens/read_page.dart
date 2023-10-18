import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

class ReadPage extends StatefulWidget {
  const ReadPage({super.key});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

enum TtsState { playing, stopped, paused, continued }

class _ReadPageState extends State<ReadPage> {
  bool loading = false;
  Dio dio = Dio();
  String filePath = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Biri Okusun'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  VocsyEpub.setConfig(
                    themeColor: Theme.of(context).primaryColor,
                    identifier: "iosBook",
                    scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                    allowSharing: true,
                    enableTts: true,
                    nightMode: true,
                  );

                  // get current locator
                  VocsyEpub.locatorStream.listen((locator) {});

                  VocsyEpub.open(
                    filePath,
                    lastLocation: EpubLocator.fromJson(
                      {
                        "bookId": "2239",
                        "href": "/OEBPS/ch06.xhtml",
                        "created": 1539934158390,
                        "locations": {
                          "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
                        }
                      },
                    ),
                  );
                },
                child: const Text('Open Online E-pub'),
              ),
              ElevatedButton(
                onPressed: () async {
                  VocsyEpub.setConfig(
                    themeColor: Theme.of(context).primaryColor,
                    identifier: "iosBook",
                    scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                    allowSharing: true,
                    enableTts: true,
                    nightMode: true,
                  );
                  // get current locator
                  VocsyEpub.locatorStream.listen((locator) {});
                  await VocsyEpub.openAsset(
                    'assets/epubs/hukuk_tkr_2023.epub',
                    lastLocation: EpubLocator.fromJson({
                      "bookId": "2239",
                      "href": "/ops/section-0001.xhtml",
                      "created": 1539934158390,
                      "locations": {
                        "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
                      }
                    }),
                  );
                },
                child: const Text('Open Assets E-pub'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
