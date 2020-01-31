import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:romdoul/database/db_device.dart';
import 'package:romdoul/database/db_smell.dart';
import 'package:romdoul/models/device.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:romdoul/models/smell.dart';
import 'package:romdoul/pages/option_page.dart';
import 'package:toast/toast.dart';

import 'package:romdoul/result_status.dart';

import '../api.dart';
import '../models/device.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _id;
  String result;

  TextEditingController _idController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();

  DBDevice _dbDevice = DBDevice();
  DBSmell _dbSmell = DBSmell();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _idController.dispose();
    _nameController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateDevices();
  }

  @override
  Widget build(BuildContext context) {
    _updateDevices();
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[

              // Top Card
              Card(
                elevation: 5,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Image.asset("images/logo.png"),
                    ),
                  ),
                ),
              ),

              // Body Part
              _body(context),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _idController.clear();
            _nameController.clear();
            showDialog(context: context, child: AlertDialog(

              title: Text("Create New Device"),
              content: Container(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: _scanQR,
                          child: Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.pink[100]
                            ),
                            child: Center(child: Text("SCAN", style: TextStyle(fontSize: 15),)),
                          ),
                        ),

                      ],
                    ),

                    TextFormField(
                      controller: _idController,
                      enabled: false,
                      decoration: InputDecoration(
                          icon: Icon(Icons.enhanced_encryption),
                          hintText: "Device ID *"
                      ),
                    ),

                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                          icon: Icon(Icons.text_format),
                          hintText: "Device name *"
                      ),
                    )

                  ],
                ),
              ),
              actions: <Widget>[

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.pink[100]
                    ),
                    child: Center(child: Text("CANCEL", style: TextStyle(fontSize: 15),)),
                  ),
                ),

                InkWell(
                  onTap: () async {
                    // TODO: Create device
                    if (_idController.text.trim().isNotEmpty && _nameController.text.trim().isNotEmpty) {


                      if (!(await API.checkDeviceExistence(_idController.text))) {
                        Toast.show(ResultStatus.ID_UNAVAILABLE,
                            context, gravity: Toast.BOTTOM,
                            duration: Toast.LENGTH_LONG);
                        return;
                      }

                      if (await _dbDevice.checkExist(_idController.text.trim())) {
                        Toast.show(ResultStatus.DEVICE_EXISTS,
                            context, gravity: Toast.BOTTOM,
                            duration: Toast.LENGTH_LONG);
                        return;
                      }


                      Device dev = await API.getDeviceWithId(_idController.text);

                      print("DEV ===> " + dev.toMapForDB().toString());

                      int result = await _dbDevice.addDevice(new Device(_nameController.text, _idController.text, dev.smell1, dev.smell2, dev.smell3, dev.lightStatus, dev.lightColor, dev.duration));
                      if (result > 0) {
                        await _dbSmell.addSmellsForDevice(_idController.text, new Smell(name: "Apple", imgName: "APPLE.png"));
                        await _dbSmell.addSmellsForDevice(_idController.text, new Smell(name: "Banana", imgName: "BANANA.png"));
                        await _dbSmell.addSmellsForDevice(_idController.text, new Smell(name: "Blueberry", imgName: "BLUBERRY.png"));
                      }
                      Toast.show(result > 0 ? "Device added" : "Error Occured",
                          context, gravity: Toast.BOTTOM,
                          duration: Toast.LENGTH_LONG);
                      _idController.clear();
                      _nameController.clear();
                      Navigator.pop(context);
                      setState(() {

                      });

                    } else {
                      Toast.show("Please Input all the required information",
                          context, gravity: Toast.BOTTOM,
                          duration: Toast.LENGTH_LONG);
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.pink[100]
                    ),
                    child: Center(child: Text("SAVE", style: TextStyle(fontSize: 15),)),
                  ),
                )

              ],
            ));
          },
          backgroundColor: Colors.pink[100],
          elevation: 10,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _alertDialogAddEdit(BuildContext context, String title, Function done) {
    return AlertDialog(

      title: Text(title),
      content: Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            InkWell(
              onTap: _scanQR,
              child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.pink[100]
                ),
                child: Center(child: Text("SCAN", style: TextStyle(fontSize: 15),)),
              ),
            ),

            TextFormField(
              controller: _idController,
              enabled: false,
              decoration: InputDecoration(
                  icon: Icon(Icons.enhanced_encryption),
                  hintText: "Device ID *"
              ),
            ),

            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                  icon: Icon(Icons.text_format),
                  hintText: "Device name *"
              ),
            )

          ],
        ),
      ),
      actions: <Widget>[

        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 50,
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.pink[100]
            ),
            child: Center(child: Text("CANCEL", style: TextStyle(fontSize: 15),)),
          ),
        ),

        InkWell(
          onTap: () async {
            done();
          },
          child: Container(
            height: 50,
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.pink[100]
            ),
            child: Center(child: Text("SAVE", style: TextStyle(fontSize: 15),)),
          ),
        )

      ],
    );
  }

  Future<void> _updateDevices() async {
    List<Device> list = await _dbDevice.getAllDevice();
    list.forEach((_) async {
      if ((await API.checkDeviceExistence(_.devices_id))) {
        Device d = await API.getDeviceWithId(_.devices_id);
        d.name = _.name;
        await _dbDevice.updateDevice(d);
      }
    });
  }

  // Body widget
  Widget _body(BuildContext context) {

    var topPosition = 20.0;
    var topLeftPosition = 20.0;

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Container(
        width: MediaQuery.of(context).size.width - topLeftPosition * 2,
        height: MediaQuery.of(context).size.height - 150,
        child: FutureBuilder<List<Device>>(
          future: _dbDevice.getAllDevice(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return LiquidPullToRefresh(
                color: Colors.pink[100],
                onRefresh: _updateDevices,
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Device device = snapshot.data[index];
                    return Dismissible(
                      key: Key(device.devices_id),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) async {
                        showDialog(context: context, child: AlertDialog(
                          title: Text("Are you sure you want to delete this device ?"),
                          actions: <Widget>[

                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 50,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.pink[100]
                                ),
                                child: Center(child: Text("CANCEL", style: TextStyle(fontSize: 15),)),
                              ),
                            ),

                            InkWell(
                              onTap: () async {
                                await _dbDevice.remove(device);
                                await _dbSmell.removeSmellForDevice(device);
                                Toast.show("Device removed", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
                                setState(() {

                                });

                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 50,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.red
                                ),
                                child: Center(child: Text("DELETE", style: TextStyle(fontSize: 15),)),
                              ),
                            )

                          ],
                        ));
                        setState(() {
                          snapshot.data.removeAt(index);
                        });
                      },
                      child: _listViewBody(context, snapshot.data[index])
                    );
                  },
                ),
              );
            }
            print(snapshot.data);
            return Container(
              child: Center(
                  child: CircularProgressIndicator()
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _listViewBody(BuildContext context, Device device) {

    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          // VIEW
          onTap: () async {
//            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: OptionPage(device: device,)));
            if (!(await API.checkDeviceExistence(device.devices_id))) {
              Toast.show("This device no longer exists", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              return;
            }

            Navigator.push(context, MaterialPageRoute(builder: (_) => OptionPage(device: device)));
          },

          // EDIT
          onLongPress: () {
            // TODO: Edit Device
            _idController.text = device.devices_id;
            _nameController.text = device.name ?? "";

            showDialog(context: context, child: _alertDialogAddEdit(context, device.name ?? "", () async {
              // TODO: Update Device Info
              device.name = _nameController.text;
              int result = await _dbDevice.updateDevice(device);
              Toast.show(result > 0 ? "Device Updated" : result.toString(), context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

              print("OKAY");
              _idController.clear();
              _nameController.clear();
              Navigator.pop(context);
              setState(() {

              });
            }));
          },
          child: Container(
            height: 50,
            child: ListTile(
                leading: Text(device.name ?? "", style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic), textAlign: TextAlign.left,),
                trailing: InkWell(
                  onTap: () {
                    showDialog(context: context, child: AlertDialog(
                      title: Text("Are you sure you want to delete this device ?"),
                      actions: <Widget>[

                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.pink[100]
                            ),
                            child: Center(child: Text("CANCEL", style: TextStyle(fontSize: 15),)),
                          ),
                        ),

                        InkWell(
                          onTap: () async {
                            await _dbDevice.remove(device);
                            await _dbSmell.removeSmellForDevice(device);
                            Toast.show("Device removed", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
                            setState(() {

                            });

                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.red
                            ),
                            child: Center(child: Text("DELETE", style: TextStyle(fontSize: 15),)),
                          ),
                        )

                      ],
                    ));

                  },
                  child: Icon(Icons.delete, color: Colors.red, size: 30,),
                )
            ),
          ),
        ),
      ),
    );
  }

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
        _id = result;
        _idController.text = _id;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          Toast.show("Camera permission was denied", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      } else {
        setState(() {
          Toast.show("Unknown Error $ex", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      }
    } on FormatException {
      setState(() {
        Toast.show("You pressed the back button before scanning anything", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });
    } catch (ex) {
      setState(() {
        Toast.show("Unknown Error $ex", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        print(ex.toString());
      });
    }
    print(result);
  }
}