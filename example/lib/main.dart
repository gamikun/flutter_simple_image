import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:simple_image/simple_image.dart' as eimagen;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool _imageLoaded = false;
  String _originalPath;
  String _imagePath;

  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = "algo";
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    _loadImage();
  }

  void _loadImage() async {
    final path = await getApplicationDocumentsDirectory();
    final filename = "${path.path}/hola.jpg";
    final file = File(filename);
    final exists = await file.exists();

    if (!exists) {
      final url = "https://farm8.staticflickr.com/7821/40546935033_546d0568f9_k_d.jpg";
      //final url = "https://farm8.staticflickr.com/7821/40546935033_bbfcf046ca_o_d.jpg";
      // "https://farm8.staticflickr.com/7884/46633780454_8860d61283_k_d.jpg"
      final response = await http.get(url);
      await file.writeAsBytes(response.bodyBytes);
    }

    setState(() {
      _imageLoaded = true;
      _originalPath = filename;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
              child: _imagePath != null
                  ? Image.file(File(_imagePath))
                  : null
          ),
          floatingActionButton: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("dart:image"),
                onPressed: () {
                  print("${new DateTime.now()} Leyendo del disco");
                  final bytes = File(_originalPath).readAsBytesSync();
                  print("${new DateTime.now()} Decodificando imagen");
                  image.decodeImage(bytes);
                  print("${new DateTime.now()} Imagen decodificada");
                },
              ),
              RaisedButton(
                child: Text("flutter:native"),
                onPressed: () async {
                  if (_imageLoaded) {
                    final docsPath = await getApplicationDocumentsDirectory();
                    await eimagen.resizeAndSave(
                        sourceFile: _originalPath,
                        targetFile: "${docsPath.path}/algo.jpg",
                        targetRect: new Rect.fromLTWH(0, 0, 512, 512),
                        quality: 80
                    );
                    setState(() {
                      _imagePath = "${docsPath.path}/algo.jpg";
                    });
                    print("${new DateTime.now()} Imagen decodificada");
                  } else {
                    print("Image was not loaded yet");
                  }
                },
              )
            ],
          )
      ),
    );
  }
}
