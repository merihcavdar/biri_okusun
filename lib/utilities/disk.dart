// ignore_for_file: unused_local_variable
import 'dart:io';
import 'dart:io' as io;
import 'package:biri_okusun/data/database.dart';
import 'package:epub_parser/epub_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';

final _myBox = Hive.box('myBox');
EpubData epubData = EpubData();

Future<Directory?> getDownloadPath() async {
  Directory? directory;
  try {
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = Directory('/storage/emulated/0/Download');
      // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
      // ignore: avoid_slow_async_io
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    }
  } catch (err) {
    debugPrint("Cannot get download folder path");
  }
  return directory;
}

Future<List> getEpubDetails(String fileToLoad) async {
  List<dynamic> epubDetails = [];

  var status = await Permission.storage.status;
  if (status.isDenied) {
    if (await Permission.storage.request().isGranted) {
      io.Directory? downloadDirectory = await getDownloadPath();
      String fullPath = path.join(downloadDirectory!.path, fileToLoad);
      var targetFile = io.File(fullPath);
      List<int> bytes = await targetFile.readAsBytes();
      EpubBook epubBook = await EpubReader.readBook(bytes);

      String? lastChapter = epubBook.Chapters?.elementAt(0).Title;

      epubDetails.add(epubBook.Title);
      epubDetails.add(lastChapter ?? "");
      epubDetails.add(fileToLoad);
      epubDetails.add(epubBook.Author);
      epubDetails.add(0);
    }
  } else {
    io.Directory? downloadDirectory = await getDownloadPath();
    String fullPath = path.join(downloadDirectory!.path, fileToLoad);
    var targetFile = io.File(fullPath);
    List<int> bytes = await targetFile.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);

    String? lastChapter = epubBook.Chapters?.elementAt(0).Title;

    epubDetails.add(epubBook.Title);
    epubDetails.add(lastChapter ?? "");
    epubDetails.add(fileToLoad);
    epubDetails.add(epubBook.Author);
  }
  return epubDetails;
}

Future<void> readEPUBFile(String epubFilePath) async {
  try {
    final bytes = await File(epubFilePath).readAsBytes();
    final epubBook = await EpubReader.readBook(bytes);

    for (var chapter in epubBook.Chapters!) {
      FlutterTts flutterTts = FlutterTts();
      await flutterTts.speak(chapter.ContentFileName!);
    }
  } catch (e) {
    print("Error reading EPUB file: $e");
  }
}

Future<List<String>> getEpubChapters(String fileToLoad) async {
  List<String> chapters = [];

  var status = await Permission.storage.status;
  if (status.isDenied) {
    if (await Permission.storage.request().isGranted) {
      io.Directory? downloadDirectory = await getDownloadPath();
      String fullPath = path.join(downloadDirectory!.path, fileToLoad);
      var targetFile = io.File(fullPath);
      List<int> bytes = await targetFile.readAsBytes();
      EpubBook epubBook = await EpubReader.readBook(bytes);

      epubBook.Chapters?.forEach(
        (EpubChapter chapter) {
          String? chapterTitle = chapter.Title;
          chapters.add(chapterTitle!.toString());
        },
      );
    }
  } else {
    io.Directory? downloadDirectory = await getDownloadPath();
    String fullPath = path.join(downloadDirectory!.path, fileToLoad);
    var targetFile = io.File(fullPath);
    List<int> bytes = await targetFile.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);

    epubBook.Chapters?.forEach(
      (EpubChapter chapter) {
        String? chapterTitle = chapter.Title;
        chapters.add(chapterTitle!.toString());
      },
    );
  }
  return chapters;
}
