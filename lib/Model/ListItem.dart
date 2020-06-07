import 'dart:core';

class ListItem{
  String fileName;
  String link;
  int startMilisecond;
  int endMilisecond;

  ListItem(this.fileName, this.startMilisecond, this.endMilisecond, this.link);

  factory ListItem.fromJson(Map<String, dynamic> json){
    ListItem item = ListItem(
      json['fileName'],
      json['startMilisecond'],
      json['endMilisecond'],
      json['link'],
    );
    return item;
  }


  Map<String, dynamic> toJson(){
    return {
      'fileName' : fileName,
      'link' : link,
      'startMilisecond' : startMilisecond,
      'endMilisecond' : endMilisecond,
    };
  }
}