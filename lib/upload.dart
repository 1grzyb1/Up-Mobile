import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upflutter/Model/ListItem.dart';
import 'package:upflutter/Widgets/HistoryItem.dart';
import 'package:upflutter/Widgets/UploadItem.dart';
import 'dart:convert';
import 'Widgets/Detail.dart';
import 'main.dart';

class UploadPage extends State<MyHomePage> {
  final Color primary = Color(0xff456990);
  final Color primaryDark = Color(0xff3c5c80);
  final Color primaryTwo = Color(0xff3d546e);
  final Color green = Color(0xff49BEAA);

  File file;
  String selectedFile;
  double progress;
  String key;
  String link;
  List<ListItem> historyItems = new List<ListItem>();
  SharedPreferences prefs;
  final url = "http://192.168.1.22:8090/";
  final uploader = FlutterUploader();

  /// Initialize app
  @override
  void initState() {
    super.initState();
    // Init history
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      prefs = sp;
      setState(() {
        List<dynamic> map = jsonDecode(prefs.get("history"));
        historyItems.clear();
        map.forEach((value) {
          historyItems.add(ListItem.fromJson(value));
        });
      });
    });
    // clean of outdated files
    new Timer.periodic(
        Duration(seconds: 1),
        (Timer t) => setState(() {
              if (historyItems.first.endMilisecond <=
                  DateTime.now().millisecondsSinceEpoch)
                historyItems.removeAt(0);
            }));
    // recive file from other apps
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        file = new File(value[0].path);
        selectedFile = path.basename(file.path);
        uploadFile(file);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UP - file hosting",
            style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold),),
        backgroundColor: primaryDark,
      ),
        floatingActionButton: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
          child: FloatingActionButton(
            backgroundColor: primaryTwo,
            child: Icon(
              Icons.add,
              color: green,
            ),
            onPressed: selectFile,
          ),
        ),
        body: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                UploadItem(
                  progress: progress,
                  fileName: selectedFile,
                  onCancel: cancel,
                ),
                Visibility(
                  visible: historyItems.length == 0,
                  child: Opacity(
                    opacity: 0.4,
                    child: Text(
                      "NO ITEMS IN HISTORY",
                      style: TextStyle(
                          color: primaryTwo,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: historyItems.length,
                      itemBuilder: (BuildContext context, int i) {
                        return InkWell(
                            focusColor: primaryTwo,
                            onTap: () => showShare(historyItems[i]),
                            child: HistoryItem(listItem: historyItems[i]));
                      }),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: primary);
  }

  void showShare(ListItem item) {
    showModalBottomSheet<void>(
        backgroundColor: Color(0x00000000),
        context: context,
        builder: (BuildContext context) {
          return Detail(
            item: item,
          );
        });
  }

  /// selecting file
  Future<void> selectFile() async {
    file = await FilePicker.getFile();
    setState(() {
      selectedFile = path.basename(file.path);
    });
    uploadFile(file);
  }

  /// Upload file
  Future<void> uploadFile(File fileToUpload) async {
    // Listen to progress of upload
    uploader.progress.listen((progress) {
      setState(() {
        this.progress = progress.progress.toDouble() / 100;
      });
    });
    await uploader.enqueue(
      url: url + "api/upload",
      files: [
        FileItem(filename: "", savedDir: fileToUpload.path, fieldname: "file")
      ],
      method: UploadMethod.POST,
      showNotification: true,
      tag: "upload",
    );
    // listen to result of upload
    uploader.result.listen((result) {
      setState(() async {
        Map<String, dynamic> json = jsonDecode(result.response);
        key = json["key"];
        link = url + "u/" + key;
        if (selectedFile != null) {
          ListItem historyItem = new ListItem(selectedFile,
              DateTime.now().millisecondsSinceEpoch, json["toDelete"], link);
          historyItems.add(historyItem);
        }
        selectedFile = null;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("history", jsonEncode(historyItems));
      });
    }, onError: (ex, stacktrace) {
      Fluttertoast.showToast(
          msg: "Something went wrong :/",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  /// Cancel uploading
  void cancel() {
    uploader.cancelAll();
    selectedFile = null;
  }
}
