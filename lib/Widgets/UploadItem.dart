import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UploadItem extends StatelessWidget {
  UploadItem({@required this.progress, @required this.fileName, @required this.onCancel});

  double  progress;
  String fileName;
  VoidCallback onCancel;
  double get percentProgress{
    if(progress == null) return 0;
    return (progress*100).roundToDouble();
  }
  bool get isVisible {
    return fileName != null;
  }
  Color backgroundColor = Color(0xff2E4C6D);
  Animation<Color> valueColor = AlwaysStoppedAnimation<Color>(Color(0xff49DCB1));
  final Color primaryTwo = Color(0xff434755);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 20, 0, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: <Widget>[
                SizedBox(
                  width: 45,
                  height: 45,
                  child: CircularProgressIndicator(
                    backgroundColor: backgroundColor,
                    valueColor: valueColor,
                    value: progress,
                  ),
                ),
                Positioned.fill(
                  child: Icon(
                    Icons.insert_drive_file,
                    color: primaryTwo,
                  ),
                )
              ],
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "$fileName",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Text(
                        "Uploading $percentProgress%",
                        style: TextStyle(
                          fontSize: 14,
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
                          left: BorderSide(color: Color(0xff2E4C6D), width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onCancel,
                child: Center(
                  child: Icon(
                    Icons.cancel,
                    color: Color(0xffEF767A),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
