import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:romdoul/database/db_device.dart';
import 'package:romdoul/models/device.dart';

class API {

  static Future<bool> checkDeviceExistence(String deviceID) async {
    var url = "http://api.arrowdot.io/romdoul/action?devices_id=$deviceID";
    try {
      var response = await http.get(url);
      var result = response.body;
      var resultJson = jsonDecode(result);
      print(resultJson is Map<String, dynamic>);
      if (resultJson is Map) {
        return false;
      } else {
        return true;
      }
    } catch (err) {
      print("ERROR checking device ==> " + err.toString());
      return false;
    }
  }

  static Future<Device> getDeviceWithId(String id) async {
    var url = "http://api.arrowdot.io/romdoul/action?devices_id=$id";
    try {
      var response = await http.get(url);
      print(response.body);
      var result = jsonDecode(response.body)[0];

      print(result);

      return Device.fromDB(result);
    } catch (err) {
      print("Error server-client communication : " + err.toString());
      return null;
    }
  }

  static Future<http.Response> updateDevice(Map<String, dynamic> map) async {

    var devicesId = map[DBDevice.devices_id];
    print(devicesId);
    var url = "http://api.arrowdot.io/romdoul/action?devices_id=$devicesId";
    print(url);
    var response = await http.put(url, body: jsonEncode(map));
    return response;

  }

}