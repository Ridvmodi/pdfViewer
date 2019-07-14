import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;


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

  getFileFromStorage() async {
    filePath = await FilePicker.getFilePath(type: FileType.CUSTOM, fileExtension: 'pdf');
    print(filePath);
    Navigator.push(context, MaterialPageRoute(builder: (context) => PdfViewPage(path: filePath)));
  }

  Future<File> getFileFromUrl(String url) async {
    try {
      var data = await http.get(url);
      var dataInBytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/temp.pdf");
      File urlFile = await file.writeAsBytes(dataInBytes);
      return urlFile;
    } catch(e) {
      throw Exception("Error in Opening Url");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(filePath);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: Text("Pdf Viewer"),),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter Url Path to fetch file"
                  ),
                  controller: _editingController,
                ),
              ),
              RaisedButton(
                onPressed: () {
                  getFileFromUrl(_editingController.text).then((file) {
                    setState(() {
                     filePath = file.path; 
                     print(filePath);
                     Navigator.push(context, MaterialPageRoute(builder: (context) => PdfViewPage(path: filePath)));
                    });
                  });
                },
                child: Text("Open"),
              ),
              RaisedButton(
                onPressed: () {
                  getFileFromStorage();
                },
                child: Text("Find in Storage"),
                color: Colors.amber
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PdfViewPage extends StatefulWidget {

  final String path;

  const PdfViewPage({Key key, this.path}) : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {

  bool pdfReady = false;
  PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          !pdfReady ? Center(child: CircularProgressIndicator() ) : Offstage()
        ],
      )
    );
  }
}