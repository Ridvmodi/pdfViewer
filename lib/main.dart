import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:downloads_path_provider/downloads_path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String filePath, urlPath;
  TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<File> getFileFromStorage() async {
    filePath = await FilePicker.getFilePath(
        type: FileType.CUSTOM, fileExtension: 'pdf');
    File file = File(filePath);
    return file;
  }

  Future<File> getFileFromUrl(String url) async {
    try {
      var data = await http.get(url);
      var dataInBytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/temp.pdf");
      File urlFile = await file.writeAsBytes(dataInBytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error in Opening Url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Pdf Viewer"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Builder(
            builder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Enter Url Path to fetch file"),
                    controller: _editingController,
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    getFileFromUrl(_editingController.text).then((file) {
                      setState(() {
                        filePath = file.path;
                        print(filePath);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PdfViewPage(path: filePath, fromUrl: true,)));
                      });
                    });
                  },
                  child: Text("Open"),
                ),
                RaisedButton(
                    onPressed: () {
                      getFileFromStorage().then((file) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PdfViewPage(path: file.path, fromUrl: false,)));
                      });
                    },
                    child: Text("Find in Storage"),
                    color: Colors.amber)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PdfViewPage extends StatefulWidget {
  final String path;
  final bool fromUrl;
  const PdfViewPage({Key key, this.path, this.fromUrl}) : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  bool pdfReady = false;
  PDFViewController _pdfViewController;
  Future<Directory> getDownloadsDirectory() {
    Future<Directory> downloadsDirectory = DownloadsPathProvider.downloadsDirectory;
    return downloadsDirectory;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
       floatingActionButton: widget.fromUrl ? FloatingActionButton(
          onPressed: () async {
            var dir = await DownloadsPathProvider.downloadsDirectory;
            print("\n\n\nThe dir is" + dir.path);
          },
          backgroundColor: Colors.black,
          child: Icon(Icons.file_download,
          color: Colors.white,),
        ) : null,
        appBar: AppBar(
          title: Text("My Doccument"),
        ),
        body: Stack(
          children: <Widget>[
            PDFView(
              filePath: widget.path,
              autoSpacing: true,
              enableSwipe: true,
              pageSnap: true,
              swipeHorizontal: true,
              onError: (e) {
                print(e);
              },
              onRender: (_pages) {
                setState(() {
                  pdfReady = true;
                });
              },
              onViewCreated: (PDFViewController vc) {
                _pdfViewController = vc;
              },
            ),
            !pdfReady ? Center(child: CircularProgressIndicator()) : Offstage(),
          ],
        ));
  }
}
