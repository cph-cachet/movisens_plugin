import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movisens_flutter/movisens_flutter.dart';
import 'file_io.dart';

ThemeData darkTheme = ThemeData(
  // Define the default Brightness and Colors
  brightness: Brightness.dark,
  primaryColor: Colors.lightBlue[800],
  accentColor: Colors.cyan[600],

  // Define the default Font Family
  fontFamily: 'Montserrat',

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  ),
);

void main() => runApp(MovisensApp());

class MovisensApp extends StatefulWidget {
  @override
  _MovisensAppState createState() => _MovisensAppState();
}

class _MovisensAppState extends State<MovisensApp> {
  Movisens _movisens;
  StreamSubscription<String> _subscription;
  LogManager logManager = new LogManager();
  List<String> movisensEvents = [];
  String address = 'unknown', name = 'unknown';
  int weight, height, age;

  @override
  void initState() {
    super.initState();
    startListening();
  }

  void onData(String d) {

    print(" onData_flutter: "+ "$d");
    setState(() {
      movisensEvents.add(d);
      logManager.writeLog('$d');
    });
  }

  void stopListening() {
    _subscription.cancel();
  }

  void startListening() {

    //address = '88:6B:0F:82:1D:33';// move4

    address = '88:6B:0F:CD:E7:F2';// ECG4

    name = 'Sensor 02655';
    weight = 100;
    height = 180;
    age = 25;

    UserData userData = new UserData(
        weight, height, Gender.male, age, SensorLocation.chest, address, name);

    _movisens = new Movisens(userData);

    try {
      _subscription = _movisens.movisensStream.listen(onData);
    } on MovisensException catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movisens Log App',
      theme: darkTheme,
      home: Scaffold(
        body: ListView.builder(
            itemCount: this.movisensEvents.length,
            itemBuilder: (context, index) => this._buildRow(index)),
      ),
    );
  }

  _buildRow(int index) {
    String d = movisensEvents[index];
    return new Container(
        child: new ListTile(
          leading: Icon(_getIcon(d)),
          title: new Text(
            d.toString(),
            style: TextStyle(fontSize: 12),
          ),
        ),
        decoration:
            new BoxDecoration(border: new Border(bottom: new BorderSide())));
  }

  IconData _getIcon(String d) {
   if (d.contains("TapMarker")) return Icons.touch_app;
    if (d .contains("MovementAcceleration")) return Icons.arrow_downward;
   if (d.contains("BodyPosition")) return Icons.accessibility;
    if (d.contains("Met")) return Icons.cached;
    if (d.contains("StepCount")) return Icons.directions_walk;
    if (d.contains("BatteryLevel")) return Icons.battery_charging_full;
    if (d.contains("ConnectionStatus")) return Icons.bluetooth_connected;
    else
      return Icons.device_unknown;
  }
}
