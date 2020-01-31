
import 'package:flutter/cupertino.dart';
import 'package:romdoul/database/db_smell.dart';

class Smell {

  String name;
  String imgName;
  int selected;
  Color smellNameColor;

  Smell({this.name, this.imgName, this.smellNameColor, this.selected = 0});

  Map<String,dynamic> toJson() {
    Map<String, dynamic> m = new Map();
    m[DBSmell.name] = this.name;
    m[DBSmell.imgName] = this.imgName;
    m[DBSmell.selected] = this.selected;
    return m;
  }

  Smell.fromJson(Map<String, dynamic> map) {
    this.name = map[DBSmell.name];
    this.imgName = map[DBSmell.imgName];
    this.selected = map[DBSmell.selected];
  }

}