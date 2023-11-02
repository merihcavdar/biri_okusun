import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:epubx/epubx.dart';

late EpubBook epubBook;

class ReadPage extends StatefulWidget {
  const ReadPage({super.key});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

enum TtsState { playing, stopped, paused, continued }

class _ReadPageState extends State<ReadPage> {
  bool loading = false;
  String filePath = "";

  void loadFile() async {
    String fileName = 'assets/epubs/hukuk_tkr_2023.epub';
    String fullPath = path.join(Directory.current.path, fileName);
    var targetFile = File(fullPath);
    List<int> bytes = await targetFile.readAsBytes();

    epubBook = await EpubReader.readBook(bytes);

// COMMON PROPERTIES

// Book's title
    String? title = epubBook.Title;

// Book's authors (comma separated list)
    String? author = epubBook.Author;

// Book's authors (list of authors names)
    List<String?>? authors = epubBook.AuthorList;

// Book's cover image (null if there is no cover)

// CHAPTERS

// Enumerating chapters

    epubBook.Chapters?.forEach((EpubChapter chapter) {
      // Title of chapter
      String? chapterTitle = chapter.Title;

      // HTML content of current chapter
      String? chapterHtmlContent = chapter.HtmlContent;

      // Nested chapters
      List<EpubChapter?>? subChapters = chapter.SubChapters;
    });

// CONTENT

// Book's content (HTML files, stylesheets, images, fonts, etc.)
    EpubContent? bookContent = epubBook.Content;

// IMAGES

// All images in the book (file name is the key)
    Map<String, EpubByteContentFile>? images = bookContent?.Images;

    EpubByteContentFile? firstImage = images?.values.first;

// Content type (e.g. EpubContentType.IMAGE_JPEG, EpubContentType.IMAGE_PNG)
    EpubContentType? contentType = firstImage?.ContentType;

// MIME type (e.g. "image/jpeg", "image/png")
    String? mimeContentType = firstImage?.ContentMimeType;

// HTML & CSS

// All XHTML files in the book (file name is the key)
    Map<String, EpubTextContentFile>? htmlFiles = bookContent?.Html;

// All CSS files in the book (file name is the key)
    Map<String, EpubTextContentFile>? cssFiles = bookContent?.Css;

// Entire HTML content of the book
    htmlFiles?.values.forEach((EpubTextContentFile htmlFile) {
      String? htmlContent = htmlFile.Content;
    });

// All CSS content in the book
    cssFiles?.values.forEach((EpubTextContentFile cssFile) {
      String? cssContent = cssFile.Content;
    });

// OTHER CONTENT

// All fonts in the book (file name is the key)
    Map<String, EpubByteContentFile>? fonts = bookContent?.Fonts;

// All files in the book (including HTML, CSS, images, fonts, and other types of files)
    Map<String, EpubContentFile>? allFiles = bookContent?.AllFiles;

// ACCESSING RAW SCHEMA INFORMATION

// EPUB OPF data
    EpubPackage? package = epubBook.Schema?.Package;

// EPUB NCX data
    EpubNavigation? navigation = epubBook.Schema?.Navigation;

// Enumerating NCX metadata
    navigation?.Head?.Metadata?.forEach((EpubNavigationHeadMeta meta) {
      String? metadataItemName = meta.Name;
      String? metadataItemContent = meta.Content;
    });
  }

  @override
  void initState() {
    super.initState();
    loadFile();
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
          child: 
          ),
        ),
      ),
    );
  }
}
