import 'dart:io';

import 'package:path/path.dart';
import 'package:romdoul/models/device.dart';
import 'package:romdoul/models/smell.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBSmell {

  static const smellTable = 'smell';
  static const id = 'id';
  static const devices_id = "devices_id";
  static const name = "name";
  static const imgName = "imgName";
  static const selected = "selected";

  String message = "";

  static final DBSmell _instance = DBSmell._();
  static Database _database;
  DBSmell._();

  factory DBSmell() {
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
    final todoSql = '''CREATE TABLE IF NOT EXISTS $smellTable
    (
      $id INTEGER PRIMARY KEY,
      $devices_id TEXT,
      $name TEXT,
      $imgName TEXT,
      $selected INTEGER
    )''';
    await db.execute(todoSql);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
    // Drop older table if existed
    db.execute("DROP TABLE IF EXISTS " + smellTable);

    // Create tables again
    _onCreate(db, newVersion);
  }

  Future<Database> init() async {
    var database;
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String dbPath = join(directory.path, 'smell.db');
      database = openDatabase(
          dbPath, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
    } catch (e) {
      print("INIT " + e.toString());
    }
    return database;
  }

  // ------------- CRUD ----------------- //

  Future<void> addSmellsForDevice(String deviceId, Smell smell) async {
    var jsonData = {
      name: smell.name,
      imgName: smell.imgName,
      devices_id: deviceId
    };
    await addSmell(jsonData);
  }

  Future<List<Smell>> get3SmellsForDevice(String deviceId) async {
    List<Smell> list = new List();
    var client = await db;

    final List<Map<String, dynamic>> maps = await client.query(smellTable,where: "$devices_id = ?", whereArgs: [deviceId]);

    maps.forEach((_) {
      print(_);
      list.add(Smell.fromJson(_));
    });

    list.forEach((_) => print("SMELL NAME " + _.name));

    return list;
  }

  Future<int> addSmell(Map<String, dynamic> smellJson) async {
    try {
      message = "";
      var client = await db;
      int result = await client.insert(smellTable, smellJson,
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

  Future<void> removeSmellForDevice(Device device) async {
    try {
      message = "";
      var client = await db;
      return client.delete(smellTable, where: '$devices_id = ?', whereArgs: [device.devices_id]);
    } catch (e) {
      message = e.toString();
      print(message);
      return null;
    }
  }

  Future<int> updateSmell(Device device, Smell smell, int iden) async {
    try {
      message = "";
      var jsonSmell = {
        name: smell.name,
        imgName: smell.imgName
      };

      var client = await db;
      return client.update(smellTable, jsonSmell, where: '$devices_id = ? AND $id = ?', whereArgs: [device.devices_id, iden], conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      message = e.toString();
      print(message);
      return null;
    }
  }

}