import 'dart:core';

class ListItem{
  String filePath;
  String fileName;
  String link;
  int startMilisecond;
  int endMilisecond;

  ListItem(this.filePath, this.fileName, this.startMilisecond, this.endMilisecond, this.link);

  factory ListItem.fromJson(Map<String, dynamic> json){
    ListItem item = ListItem(
      json['filePath'],
      json['fileName'],
      json['startMilisecond'],
      json['endMilisecond'],
      json['link'],
    );
    return item;
  }


  Map<String, dynamic> toJson(){
    return {
      'filePath' : filePath,
      'fileName' : fileName,
      'link' : link,
      'startMilisecond' : startMilisecond,
      'endMilisecond' : endMilisecond,
    };
  }
}