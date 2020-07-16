import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:path_provider/path_provider.dart';
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

  File currentFile;
  double progress;
  String key;
  String link;
  List<ListItem> historyItems = new List<ListItem>();
  List<File> queItems = new List<File>();
  SharedPreferences prefs;
  final url = "https://up.snet.ovh/";
  final uploader = FlutterUploader();
  StreamSubscription resultSubsription;
  StreamSubscription _intentDataStreamSubscription;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  String get _fileName {
    if(currentFile == null) return null;
    return currentFile.path.split("/").last;
  }

  /// Initialize app
  @override
  void initState() {
    super.initState();
    // Init notification settings
    initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings();
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
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
              while (historyItems.first.endMilisecond <=
                  DateTime.now().millisecondsSinceEpoch)
                historyItems.removeAt(0);
            }));
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        currentFile = new File(value[0].path);
        uploadFile(currentFile);
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        currentFile = new File(value[0].path);
        uploadFile(currentFile);
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((value) {
      setState(() async {
        if (value == null) return;
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        currentFile = new File('$tempPath/file.txt');
        currentFile.writeAsString(value);
        uploadFile(currentFile, delAfter: true);
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() async {
        if (value == null) return;
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        currentFile = new File('$tempPath/file.txt');
        currentFile.writeAsString(value);
        uploadFile(currentFile, delAfter: true);
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "UP - file hosting",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
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
        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                Visibility(
                  visible: currentFile != null,
                  child: UploadItem(
                    progress: progress,
                    fileName: _fileName,
                    onCancel: cancel,
                  ),
                ),
                Visibility(
                  visible: historyItems.length == 0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Opacity(
                        opacity: 0.4,
                        child: Text(
                          'Click "+" to upload file',
                          style: TextStyle(
                              color: Color(0xff06203d),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                )
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return UploadItem(
                    progress: 0,
                    fileName: queItems[i].path.split("/").last,
                    onCancel: () {
                      queItems.removeAt(i);
                    },
                  );
                },
                childCount: queItems.length,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                return InkWell(
                    focusColor: primaryTwo,
                    onTap: () =>
                        showShare(historyItems[historyItems.length - i - 1]),
                    child: HistoryItem(
                        listItem: historyItems[historyItems.length - i - 1]));
              }, childCount: historyItems.length),
            )
          ],
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
    File file = await FilePicker.getFile();
    addFile(file);
  }

  /// Add file to waiting que
  void addFile(File file) {
    if (currentFile == null) {
      currentFile=file;
      uploadFile(file);
      return;
    }
    queItems.add(file);
  }

  /// Upload next file in que
  void uploadNext() {
    resultSubsription.cancel();
    if (queItems.length == 0) return;
    setState(() {
      currentFile=queItems[0];
      queItems.removeAt(0);
    });
    uploadFile(currentFile);
  }

  /// Upload file
  Future<void> uploadFile(File fileToUpload, {bool delAfter = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Listen to progress of upload
    uploader.progress.listen((progress) {
      setState(() {
        this.progress = progress.progress.toDouble() / 100;
      });
    });
    String path = fileToUpload.path;
    await uploader.enqueue(
      url: url + "api/upload",
      files: [
        FileItem(
            filename: path.split("/").last,
            savedDir:
                path.substring(0, path.length - path.split("/").last.length),
            fieldname: "file")
      ],
      method: UploadMethod.POST,
      showNotification: false,
      tag: "upload",
    );
    // listen to result of upload
    resultSubsription = uploader.result.listen((result) {
        Map<String, dynamic> json = jsonDecode(result.response);
        key = json["key"];
        link = url + "u/" + key;
        if (currentFile != null) {
          ListItem historyItem = new ListItem(_fileName,
              DateTime.now().millisecondsSinceEpoch, json["toDelete"], link);
          historyItems.add(historyItem);
        }
        notification("Uploaded", _fileName, link);
        currentFile = null;
        prefs.setString("history", jsonEncode(historyItems));
        if (delAfter) currentFile.delete();
        uploadNext();
        return;
    }, onError: (ex, stacktrace) {
      Fluttertoast.showToast(
          msg: "Something went wrong :/",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      resultSubsription.cancel();
      return;
    });
  }

  /// Cancel uploading
  void cancel() {
    currentFile = null;
    uploader.cancelAll();
  }

  /// Show notification
  Future notification(String title, String body, String link) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: link,
    );
  }

  /// Handle notification response
  Future onSelectNotification(String payload) async {}
}
