import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:romdoul/api.dart';
import 'package:romdoul/database/db_device.dart';
import 'package:romdoul/database/db_smell.dart';
import 'package:romdoul/models/device.dart';
import 'package:romdoul/models/smell.dart';
import 'package:toast/toast.dart';

class OptionPage extends StatefulWidget {
  final Device device;
  const OptionPage({Key key, @required this.device}) : super(key: key);
  @override
  _OptionPageState createState() => _OptionPageState();
}

class DurationOption {
  final String label;
  final int value;
  Color bgColor;
  DurationOption({this.label, this.value, this.bgColor});
}

class _OptionPageState extends State<OptionPage> {

  DBDevice _dbDevice = new DBDevice();
  DBSmell _dbSmell = new DBSmell();

  List<Smell> smells = [];
  List<Smell> allSmells = [];

  List<DurationOption> durations = [];

  int selectedValue;
  Color selectedColor = Colors.pink[100];
  Color nonSelectedColor = Colors.grey;

  Color pickerColor;
  Smell selectedSmell;
  int smellIndex;

  Future<List<Smell>> _load3Smell() async {
    smells = await _dbSmell.get3SmellsForDevice(widget.device.devices_id);
    smells[0].smellNameColor = (widget.device.smell1 == "ON") ? selectedColor : Colors.black;
    smells[1].smellNameColor = (widget.device.smell2 == "ON") ? selectedColor : Colors.black;
    smells[2].smellNameColor = (widget.device.smell3 == "ON") ? selectedColor : Colors.black;

    smells[0].selected = (widget.device.smell1 == "ON") ? 1 : 0;
    smells[1].selected = (widget.device.smell2 == "ON") ? 1 : 0;
    smells[2].selected = (widget.device.smell3 == "ON") ? 1 : 0;

    smells.forEach((_) {
      if (_.selected == 1) {
        selectedSmell = _;
      }
    });

    smellIndex = widget.device.smell1 == "ON" ? 1 : (widget.device.smell2 == "ON" ? 2 : 3);
    print("SMELL LOADED : " + smells[0].imgName);
    return smells;
  }

  _loadAllSmell() {
    allSmells.add(new Smell(name: "Apple", imgName: "APPLE.png"));
    allSmells.add(new Smell(name: "Banana", imgName: "BANANA.png"));
    allSmells.add(new Smell(name: "Blueberry", imgName: "BLUBERRY.png"));
    allSmells.add(new Smell(name: "Buble gum", imgName: "BUBLE GYM.png"));
    allSmells.add(new Smell(name: "Chocolate", imgName: "CHOCOLATE.png"));
    allSmells.add(new Smell(name: "Chompey", imgName: "CHOMPEY.png"));
    allSmells.add(new Smell(name: "Coconut", imgName: "COCONUTE.png"));
    allSmells.add(new Smell(name: "Grape", imgName: "GRAPE.png"));
    allSmells.add(new Smell(name: "Jasmin", imgName: "JASMIN.png"));
    allSmells.add(new Smell(name: "Kiwi", imgName: "KIWI.png"));
    allSmells.add(new Smell(name: "Lavender", imgName: "LAVENDER.png"));
    allSmells.add(new Smell(name: "Lyly", imgName: "LYLY.png"));
    allSmells.add(new Smell(name: "Melon", imgName: "MELON.png"));
    allSmells.add(new Smell(name: "Orange", imgName: "ORANGE.png"));
    allSmells.add(new Smell(name: "Orchid", imgName: "ORCHID.png"));
    allSmells.add(new Smell(name: "Peach", imgName: "PEACHE1.png"));
    allSmells.add(new Smell(name: "Pineapple", imgName: "PINEAPPLE.png"));
    allSmells.add(new Smell(name: "Rose", imgName: "ROSE1.png"));
    allSmells.add(new Smell(name: "Sakura", imgName: "SAKURA1.png"));
    allSmells.add(new Smell(name: "Strawberry", imgName: "STRAWBERRY1.png"));
    allSmells.add(new Smell(name: "Sunflower", imgName: "SUNFLOWER1.png"));
    allSmells.add(new Smell(name: "Watermelon", imgName: "WATERMELON.png"));
    print(widget.device.id);
  }

  _loadDuration() {
    durations.add((new DurationOption(label: "15 minutes", value: 15, bgColor: nonSelectedColor)));
    durations.add((new DurationOption(label: "30 minutes", value: 30, bgColor: nonSelectedColor)));
    durations.add((new DurationOption(label: "45 minutes", value: 45, bgColor: nonSelectedColor)));
    durations.add((new DurationOption(label: "60 minutes", value: 60, bgColor: nonSelectedColor)));
    durations.add((new DurationOption(label: "NEVER", value: 0, bgColor: nonSelectedColor)));
    selectedValue = int.parse(widget.device.duration);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print(widget.device.toMapForDB());

    pickerColor = Color(int.parse(widget.device.lightColor.replaceAll("#", "0xff")));

    _load3Smell();
    _loadAllSmell();
    _loadDuration();
    _toggleRadioBox();

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }

  Widget _body(BuildContext context) {

    var topLeftPosition = 20.0;

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Container(
          width: MediaQuery.of(context).size.width - topLeftPosition * 2,
          height: MediaQuery.of(context).size.height - 150,
          child: ListView(
            children: <Widget>[
              _smellWidget(context),
              _durationWidget(context),
              _lightSelection(context),
            ],
          )
      ),
    );
  }

  Widget _smellWidget(BuildContext context) {
    return Card(
      elevation: 5,
      child: Center(
        child: Container(
          height: 150,
          child: FutureBuilder<List<Smell>>(
            future: _load3Smell(),
            builder: (context, snap) {
              if (snap.data != null && snap.hasData) {
                return Center(
                  child: GridView.builder(
                    physics: ClampingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                    itemCount: smells.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          //TODO: Select Smell
                          if (selectedSmell == smells[index]) {
                            selectedSmell = null;
                            smellIndex = 0;
                          } else {
                            selectedSmell = smells[index];
                            smellIndex = index + 1;
                          }
                          _toggleSmell();

                          widget.device.smell1 = (smellIndex == 1) ? "ON" : "OFF";
                          widget.device.smell2 = (smellIndex == 2) ? "ON" : "OFF";
                          widget.device.smell3 = (smellIndex == 3) ? "ON" : "OFF";

                          var update = await API.updateDevice(widget.device.toMapForDB());
                          print(update.body);

                          _dbDevice.updateDevice(widget.device);

                          Toast.show("Smell is updated", context, gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
                          setState(() {

                          });
                        },
                        onLongPress: () {
                          _loadSmellSelection(context, index);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset("images/${smells[index].imgName}", width: 50, height: 50,),
                            Text(smells[index].name, style: TextStyle(color: smells[index].smellNameColor),)
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          )
        ),
      ),
    );
  }

  Widget _durationWidget(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        height: 100,
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView.builder(
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: durations.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () async {
                        // TODO: TOGGLE DURATION

                        print(durations[index].label);

                        widget.device.duration = durations[index].value.toString();
                        var update = await API.updateDevice(widget.device.toMapForDB());
                        print(update.body);

                        _dbDevice.updateDevice(widget.device);

                        Toast.show("Duration is updated", context, gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

                        setState(() {
                          selectedValue = durations[index].value;
                          _toggleRadioBox();
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          color: durations[index].bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(durations[index].label, style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                  );
                },
              )
          ),
        ),
      ),
    );
  }

  Widget _lightSelection(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {
                      //TODO: TOGGLE LIGHT STATUS

                      widget.device.lightStatus = widget.device.lightStatus == "OFF" ? "ON" : "OFF";

                      var update = await API.updateDevice(widget.device.toMapForDB());
                      print(update.body);

                      _dbDevice.updateDevice(widget.device);

                      Toast.show("Light is updated", context, gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
                      setState(() {

                      });
                    },
                    child: Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                        color: widget.device.lightStatus == "ON" ? Colors.pink[100] : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text("Light Status : ${widget.device.lightStatus}", style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ),
                ),

                ColorPicker(
                  displayThumbColor: false,
                  paletteType: PaletteType.hsl,
                  pickerColor: pickerColor,
                  onColorChanged: _changeColor,
                  enableLabel: true,
                  pickerAreaHeightPercent: 0.8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _changeColor(Color color) async {

    widget.device.lightColor = _convertToHex(color);

    var update = await API.updateDevice(widget.device.toMapForDB());
    print(update.body);

    _dbDevice.updateDevice(widget.device);

    Toast.show("Light Color is updated", context, gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    setState(() => pickerColor = color);
  }

  _toggleRadioBox() {
    durations.forEach((d) {
      setState(() {
        d.bgColor = (d.value == selectedValue) ? selectedColor : nonSelectedColor;
      });
    });
  }

  _toggleSmell() {
    smells.forEach((s) {
      setState(() {
        s.smellNameColor = (s == selectedSmell) ? selectedColor : Colors.black;
      });
    });
  }

  _loadSmellSelection(BuildContext context, int ind)  {
    return showDialog(context: context, child: AlertDialog(
      title: Text("Choose any smell you like"),
      content: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height:  MediaQuery.of(context).size.height - 230,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: allSmells.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell (
                      onTap: () async {
                        var temp = smells[ind];
                        smells[ind] = allSmells[index];
                        if (selectedSmell == temp) {
                          selectedSmell = smells[ind];
                        }

                        print("This is smell from selected: " + smells[ind].name ?? "VALUE NULL");

                        int result = await _dbSmell.updateSmell(widget.device, smells[ind], ind+1);
                        print("RESULT : " + result.toString());

                        _toggleSmell();
                        setState(() {

                        });
                        Navigator.pop(context);
                      },
                      child: Image.asset("images/${allSmells[index].imgName}", width: 50, height: 50)
                  ),
                  Text(allSmells[index].name, style: TextStyle(fontSize: 12),)
                ],
              );
            },
          ),
        ),
      ),
      actions: <Widget>[
        InkWell(
          child:InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.pink[100]
              ),
              child: Center(child: Text("CANCEL", style: TextStyle(fontSize: 15),)),
            ),
          ),
        )
      ],
    ));
  }

  String _convertToHex(Color color) {
    var co = color.toString().replaceAll("Color(", "");
    var col = co.replaceAll(")", "");
    var finCol = col.replaceAll("0x", "#");
    return finCol;
  }

}