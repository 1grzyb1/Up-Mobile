import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:upflutter/Model/ListItem.dart';

// ignore: must_be_immutable
class HistoryItem extends StatelessWidget {
  ListItem listItem;

  double get percentTime {
    if (listItem == null) return 0;
    var current = new DateTime.now().millisecondsSinceEpoch;
    return (listItem.endMilisecond-current)/(listItem.endMilisecond-listItem.startMilisecond);
  }

  String get timeLeft{
    if (listItem == null) return "";
    var current = new DateTime.now().millisecondsSinceEpoch;
    double minutes = ((listItem.endMilisecond-current)/60000);
    if(minutes > 60) return ((listItem.endMilisecond-current)/3600000).round().toString()+"h left";
    return minutes.round().toString() + "min left";
  }

  Color backgroundColor = Color(0xff2E4C6D);
  Color valueColor = Color(0xff49DCB1);
  final Color primaryTwo = Color(0xff434755);

  HistoryItem({@required this.listItem});

  String get _name{
    if(listItem.fileName == null) return "";
    if(listItem.fileName.length < 20) return listItem.fileName;
    return listItem.fileName.substring(0, 19)+"...";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      _name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Text(
                        listItem.link,
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
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    timeLeft,
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.all(0),
                        width: 70,
                        animation: true,
                        lineHeight: 5.0,
                        animationDuration: 0,
                        percent: percentTime,
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        backgroundColor: primaryTwo,
                        progressColor: valueColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
  }
}
