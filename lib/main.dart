import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class FriendDataClass {
  late String lag;
  late String sml;
  late bool isExists;
  late int width;
  late int height;

  FriendDataClass(this.lag, this.sml, this.isExists, this.width, this.height);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '🐈'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _selectedLargeImageDirectory;
  String? _selectedSmallImageDirectory;
  List<FileSystemEntity> _files = [];
  List<FriendDataClass> _photos = [];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Row(
            children: [
              const Text("元画像dir: "),
              // SizedBox(width: 100, child: TextField()),
              Text(_selectedLargeImageDirectory.toString()),
              ElevatedButton(
                onPressed: () {
                  _pickDirectory(onDirectoryPicked: (String directoryPath) {
                    setState(() {
                      _selectedLargeImageDirectory = directoryPath;
                    });
                  });
                },
                child: const Text('ディレクトリ選択'),
              )
            ],
          ),
          Row(
            children: [
              const Text("縮小画像dir: "),
              Text(_selectedSmallImageDirectory.toString()),
              ElevatedButton(
                onPressed: () {
                  _pickDirectory(onDirectoryPicked: (String directoryPath) {
                    setState(() {
                      _selectedSmallImageDirectory = directoryPath;
                    });
                  });
                },
                child: const Text('ディレクトリ選択'),
              )
            ],
          ),
          ElevatedButton(onPressed: _loadFiles, child: const Text("ディレクトリ読出")),
          ElevatedButton(onPressed: _generateHtml, child: const Text("HTML生成")),
          _selectedLargeImageDirectory != null
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'No.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          '元画像',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          '縮小画像',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          Expanded(
            child: _files.isNotEmpty
                ? ListView.builder(
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            color: _photos[index].isExists
                                ? Colors.blue
                                : Colors.red,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text('${index + 1}'),
                                ),
                                Expanded(
                                  flex: 5,
                                  // child: Text(_files[index].path.split('/').last),
                                  child:
                                      Text(_getPath2Name(_photos[index].lag)),
                                ),
                                Expanded(
                                  flex: 5,
                                  // child: Text(_files[index].path.split('/').last),
                                  child:
                                      Text(_getPath2Name(_photos[index].sml)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      "(${_photos[index].width}, ${_photos[index].height})"),
                                ),
                              ],
                            ),
                          ));
                    },
                  )
                : const Center(child: Text('No directory selected')),
          ),
        ],
      ),
    );
  }

  // ディレクトリ選択
  Future<void> _pickDirectory(
      {required Function(String) onDirectoryPicked}) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      onDirectoryPicked(selectedDirectory);
    }
  }

  // ディレクトリの読み取り
  Future<void> _loadFiles() async {
    if (_selectedLargeImageDirectory == null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("確認"),
              content: const Text("元画像ディレクトリを選択してください"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"))
              ],
            );
          });
      return;
    }
    if (_selectedSmallImageDirectory == null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("確認"),
              content: const Text("縮小画像ディレクトリを選択してください"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"))
              ],
            );
          });
      return;
    }

    // 元画像ディレクトリから画像一覧を取得
    final rawDirectories = Directory(_selectedLargeImageDirectory!);
    final List<FileSystemEntity> rawEntities = rawDirectories
        .listSync()
        .where((entity) => entity is File && _isImageFile(entity.path))
        .toList();

    final smlDirectories = Directory(_selectedSmallImageDirectory!);

    // ソート
    rawEntities.sort(
        (a, b) => a.path.split('/').last.compareTo(b.path.split('/').last));

    List<FriendDataClass> photos = [];
    // 縮小画像ディレクトリを確認
    for (var lPath in rawEntities) {
      // 拡張子つきファイル名
      String lImageNameWithExt = lPath.path.split('/').last;
      // 拡張子なしファイル名
      String lImageName = lImageNameWithExt
          .split(".")
          .reversed
          .skip(1)
          .toList()
          .reversed
          .join(".");

      List<MapEntry<int, FileSystemEntity>> matches = smlDirectories
          .listSync()
          .asMap()
          .entries
          .where((entry) => entry.value.path.contains(lImageName))
          .toList();

      String smlName =
          matches.isEmpty ? "File Not Found" : matches.first.value.path;

      int width = 0;
      int height = 0;
      if (matches.isNotEmpty) {
        final File file = File(matches.first.value.path);
        final Uint8List data = await file.readAsBytes();
        final ui.Image image =
            await decodeImageFromList(data.buffer.asUint8List());
        width = image.width;
        height = image.height;
      }

      FriendDataClass dt = FriendDataClass(
          lPath.path, smlName, matches.isNotEmpty, width, height);

      photos.add(dt);
    }

    setState(() {
      _files = rawEntities;
      _photos = photos;
    });
  }

  // フルパスからhtml用パスを生成する
  String _getPath2Name(String path) {
    var split = path.split('/');
    return split.length > 1
        ? '${split[split.length - 2]}/${split[split.length - 1]}'
        : split.last;
  }

  // パス先が画像拡張子か判定する
  bool _isImageFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'JPG' ||
        extension == 'JPEG';
  }

  Future<void> _generateHtml() async {
    String body = "";
    for (var entry in _photos.asMap().entries) {
      body = body +
          '　　<a href="./${_getPath2Name(entry.value.lag)}">' +
          '<img src="./${_getPath2Name(entry.value.sml)}" width="${entry.value.width}" height="${entry.value.height}"></a>　　';
      if ( entry.key %2 == 1){
        body += "<br/>\n";
      }
    }
    String ? savePath = await FilePicker.platform.saveFile(
      dialogTitle: "save name",
      fileName: "out.txt"
    );
    if (savePath != null){
      await writeToFile(savePath, body);
    }



  }

  Future<void> writeToFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
    print('File written: $filePath');
  }
}
