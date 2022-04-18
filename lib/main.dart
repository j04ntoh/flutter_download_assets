import 'dart:io';

import 'package:download_assets/download_assets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Download Assets'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DownloadAssetsController downloadAssetsController = DownloadAssetsController();
  String message = "Press the download button to start the download";
  bool downloaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    await downloadAssetsController.init();
    downloaded = await downloadAssetsController.assetsDirAlreadyExists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(message),
            if (downloaded)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File("${downloadAssetsController.assetsDir}/dart.jpeg")),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            if (downloaded)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File("${downloadAssetsController.assetsDir}/flutter.png")),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _downloadAssets,
            tooltip: 'Increment',
            child: const Icon(Icons.arrow_downward),
          ),
          const SizedBox(
            width: 25,
          ),
          FloatingActionButton(
            onPressed: _refresh,
            tooltip: 'Refresh',
            child: const Icon(Icons.refresh),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future _refresh() async {
    await downloadAssetsController.clearAssets();
    await _downloadAssets();
  }

  Future _downloadAssets() async {
    bool assetsDownloaded = await downloadAssetsController.assetsDirAlreadyExists();

    if (assetsDownloaded) {
      setState(() {
        message = "Click in refresh button to force download";
        debugPrint(message);
      });
      return;
    }

    try {
      await downloadAssetsController.startDownload(
        assetsUrl: "https://github.com/edjostenes/download_assets/raw/master/assets.zip",
        onProgress: (progressValue) {
          downloaded = false;
          setState(() {
            if (progressValue < 100) {
              message = "Downloading - ${progressValue.toStringAsFixed(2)}";
              debugPrint(message);
            } else {
              message = "Download completed\nClick in refresh button to force download";
              debugPrint(message);
              downloaded = true;
            }
          });
        },
      );
    } on DownloadAssetsException catch (e) {
      debugPrint(e.toString());
      setState(() {
        downloaded = false;
        message = "Error: ${e.toString()}";
      });
    }
  }
}
