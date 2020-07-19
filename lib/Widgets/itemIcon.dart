import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upflutter/Model/ListItem.dart';
import 'package:upflutter/Colors/upColors.dart';

class itemIcon extends StatelessWidget {
  List<String> _imgTypes = ["png", "jpg", "jpeg"];
  List<String> _txtTypes = ["txt", "doc", "docx", "log", "csv"];
  List<String> _pdfTypes = ["pdf"];
  List<String> _extTypes = ["xlsm", "xlsx", "xlsx", "xlt"];

  ListItem listItem;
  double height;

  String get _extension {
    return listItem.fileName.split(".").last;
  }

  Widget _getIcon() {
    String path;
    if (_imgTypes.contains(_extension)) {
      return Image.file(
        File(listItem.filePath),
        height: height,
        fit: BoxFit.cover,
      );
    }
    else if(_txtTypes.contains(_extension)){
      return Image.asset(
        "text.png",
        height: height,
        fit: BoxFit.cover,
      );
    }
    else if(_extTypes.contains(_extension)){
      return Image.asset(
        "excel.png",
        height: height,
        fit: BoxFit.cover,
      );
    }

    else if(_pdfTypes.contains(_extension)){
      return Image.asset(
        "pdf.png",
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      "file.png",
      height: height,
      fit: BoxFit.cover,
    );
  }

  itemIcon(this.listItem, this.height);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: height,
          width: height,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0), child: _getIcon()),
        ),
      ],
    );
  }
}
