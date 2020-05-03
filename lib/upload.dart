import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share/share.dart';
import 'package:upflutter/Widgets/button.dart';
import 'dart:convert';
import 'main.dart';

class UploadPage extends State<MyHomePage> {
  final Color primary = Color(0xff181A1B);
  final Color primaryTwo = Color(0xff434755);

  File file;
  String selectedFile = "No file selected";
  int progressInt;
  double progressDouble;
  String key;
  String link;
  final url = "http://192.168.1.24:8090/";

  bool uploading = false;
  bool uploaded = false;

  final uploader = FlutterUploader();

  /// Receive file from other apps
  @override
  void initState() {
    super.initState();
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        file = new File(value[0].path);
        selectedFile = path.basename(file.path);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: primary,
            title: Text(widget.title, style: TextStyle(color: Colors.white))),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Text(
                    '$selectedFile',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Button(onPressed: selectFile, icon: Icons.add),
                      Button(onPressed: uploadFile, icon: Icons.file_upload),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Visibility(
                        visible: uploading,
                        child: Column(
                          children: <Widget>[
                            Text(
                              '$progressInt %',
                              style: TextStyle(color: Colors.white),
                            ),
                            LinearProgressIndicator(value: progressDouble),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: uploaded,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(10),
                              child: Text(
                                '$link',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Button(onPressed: shareLink, icon: Icons.share),
                                Button(
                                    onPressed: copyToClipboard,
                                    icon: Icons.content_copy),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: primaryTwo);
  }

  /// selecting file
  Future<void> selectFile() async {
    file = await FilePicker.getFile();
    setState(() {
      uploaded = false;
      uploading = false;
      selectedFile = path.basename(file.path);
    });
  }

  /// Upload file
  Future<void> uploadFile() async {
    setState(() {
      uploading = true;
    });
    uploader.progress.listen((progress) {
      setState(() {
        progressInt = progress.progress;
        progressDouble = progressInt.toDouble() / 100;
      });
    });
    await uploader.enqueue(
        url: url + "api/upload",
        files: [FileItem(filename: "", savedDir: file.path, fieldname: "file")],
        method: UploadMethod.POST,
        showNotification: true,
        tag: "upload");
    uploader.result.listen((result) {
      setState(() {
        uploaded = true;
        Map<String, dynamic> json = jsonDecode(result.response);
        key = json["key"];
        link = url + "u/" + key;
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

  /// Copy link to clipboard
  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: link));
    Fluttertoast.showToast(
        msg: "Link coppied to clipboard",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  /// Share link to other apps
  void shareLink() {
    Share.share(link);
  }
}
