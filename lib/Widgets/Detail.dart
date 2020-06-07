import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:upflutter/Model/ListItem.dart';

class Detail extends StatelessWidget {
  final Color primary = Color(0xff456990);
  final Color primaryTwo = Color(0xff434755);
  final Color green = Color(0xff49BEAA);

  Detail({@required this.item});

  ListItem item;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          decoration: BoxDecoration(
            color: primary,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryTwo.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                    width: 35,
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                    child: QrImage(
                      data: item.link,
                      gapless: true,
                      version: QrVersions.auto,
                      size: 250.0,
                      foregroundColor: green,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 20, 0, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: Icon(
                            Icons.insert_drive_file,
                            color: primaryTwo,
                            size: 45,
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  item.fileName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: Text(
                                    item.link,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: SizedBox(
                            height: 45,
                            width: 4,
                            child: Center(
                              child: Opacity(
                                opacity: 0.5,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                                  width: 4,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                          color: Color(0xff2E4C6D), width: 2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: shareLink,
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Icon(
                                  Icons.share,
                                  color: Colors.white,
                                )),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ))),
    );
  }

  /// Share link to other apps
  void shareLink() {
    Share.share(item.link);
  }
}
