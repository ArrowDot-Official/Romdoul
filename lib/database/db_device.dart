import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:romdoul/models/device.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBDevice {

  static const deviceTable = 'device';
  static const id = 'id';
  static const name = 'name';
  static const devices_id = "devices_id";
  static const smell1 = "smell1";
  static const smell2 = "smell2";
  static const smell3 = "smell3";
  static const lightStatus = "light_status";
  static const lightColor = "light_color";
  static const duration = "duration";

  String message = "";

  static final DBDevice _instance = DBDevice._();
  static Database _database;
  DBDevice._();
  factory DBDevice() {
    return _instance;
  }
  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await init();

    return _database;
  }

  Future<void> _onCreate(Database db, int version) async {
    final todoSql = '''CREATE TABLE IF NOT EXISTS $deviceTable
    (
      $id INTEGER PRIMARY KEY,
      $name TEXT,
      $devices_id TEXT,
      $smell1 TEXT,
      $smell2 TEXT,
      $smell3 TEXT,
      $lightStatus TEXT,
      $lightColor TEXT,
      $duration TEXT
    )''';
    await db.execute(todoSql);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
    // Drop older table if existed
    db.execute("DROP TABLE IF EXISTS " + deviceTable);

    // Create tables again
    _onCreate(db, newVersion);
  }

  Future<Database> init() async {
    var database;
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String dbPath = join(directory.path, 'valve.db');
      database = openDatabase(
          dbPath, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
    } catch (e) {
      print("INIT " + e.toString());
    }
    return database;
  }

  Future<bool> checkExist(String devices_id) async {
    try {
      message = "";
      var client = await db;
      List<Device> list = List();

      final List<Map<String, dynamic>> map = await client.query(deviceTable,where: "devices_id = ?", whereArgs: [devices_id]);

      if (map.length > 0) {
        message = "Device exists";
        return true;
      }
      return false;


    } catch (e) {
      message = e.toString();
      print(message);
      return null;
    }
  }

  // ------------- CRUD ----------------- //

  Future<List<Device>> getAllDevice({String where, List<dynamic> whereArgs}) async {
    try {
      message = "";
      var client = await db;
      List<Device> list = List();

      final List<Map<String, dynamic>> maps = await client.query(deviceTable,where: where, whereArgs: whereArgs);

      maps.forEach((_) => list.add( Device.fromDB(_)) );

//      for (final n in maps) {
//        list.add(Device.fromDB(n));
//      }

      message = "Device exists";
      return list;
    } catch (e) {
      message = e.toString();
      print(message);
      return null;
    }
  }

  Future<Device> getDevice(String devicesId) async {
    List<Device> devices = await getAllDevice();
    List<Device> list = List();
    for (final n in devices) {
      if (n.devices_id == devicesId) {
        list.add(n);
      }
    }
    return list.first;
  }

  Future<int> addDevice(Device device) async {
    try {
      message = "";
      var client = await db;
      int result = await client.insert(deviceTable, device.toMapForDB(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (result > 0) {
        message = "Valve is created";
      } else {
        message = "Valve is not created";
      }
      return result;
    } catch (e) {
      message = "Problem happen when creating new device";
      print(e.toString() + " Problem happen when creating new device");
      return null;
    }
  }

  Future<void> remove(Device device) async {
    try {
      message = "";
      var client = await db;
      return client.delete(deviceTable, where: 'devices_id = ?', whereArgs: [device.devices_id]);
    } catch (e) {
      message = e.toString();
      print(message);
      return null;
    }
  }

  Future<void> removeDevice(int id) async {
    try {
      message = "";
      var client = await db;
      message = "Item removed";
      return client.delete(deviceTable, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      message = e.toString();
      print(message);
      return null;
    }
  }

  Future<int> updateDevice(Device device) async {
    try {
      message = "";
      var client = await db;
      return client.update(deviceTable, device.toMapForDB(), where: 'devices_id = ?', whereArgs: [device.devices_id], conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      message = e.toString();
      print(message);
      return null;
    }
  }

}