import 'package:romdoul/database/db_device.dart';

class Device {

  int id;
  String name;
  String devices_id;
  String smell1;
  String smell2;
  String smell3;
  String lightStatus;
  String lightColor;
  String duration;

  Device(this.name, this.devices_id,this.smell1,this.smell2,this.smell3,this.lightStatus,this.lightColor,this.duration);

  Device.fromDB(Map<String, dynamic> map) {
    this.name = map[DBDevice.name];
    this.devices_id = map[DBDevice.devices_id];
    this.smell1 = map[DBDevice.smell1];
    this.smell2 = map[DBDevice.smell2];
    this.smell3 = map[DBDevice.smell3];
    this.lightStatus = map[DBDevice.lightStatus];
    this.lightColor = map[DBDevice.lightColor];
    this.duration = map[DBDevice.duration];
  }

  Map<String, dynamic> toMapForDB() {
    var map = Map<String, dynamic>();
    map[DBDevice.name] = name;
    map[DBDevice.devices_id] = devices_id;
    map[DBDevice.smell1] = smell1;
    map[DBDevice.smell2] = smell2;
    map[DBDevice.smell3] = smell3;
    map[DBDevice.lightStatus] = lightStatus;
    map[DBDevice.lightColor] = lightColor;
    map[DBDevice.duration] = duration;
    return map;
  }

}

