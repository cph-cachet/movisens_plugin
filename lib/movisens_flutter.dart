import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io' show Platform;

/// Custom Exception for the plugin,
/// thrown whenever the plugin is used on platforms other than Android
class MovisensException implements Exception {
  String _cause;
  MovisensException(this._cause);

  @override
  String toString() {
    return _cause;
  }
}

enum Gender { male, female }

enum SensorLocation {
  left_ankle,
  left_hip,
  left_thigh,
  left_upper_arm,
  left_wrist,
  right_ankle,
  right_hip,
  right_thigh,
  right_upper_arm,
  right_wrist,
  chest
}

class UserData {
  int weight, height, age;

  /// Weight in kg, height in cm, age in years
  Gender gender;

  /// Gender: male or female
  SensorLocation sensorLocation;

  /// Sensor placement on body
  String sensorAddress, sensorName;

  /// Sensor device addresss and name

  UserData(this.weight, this.height, this.gender, this.age, this.sensorLocation,
      this.sensorAddress, this.sensorName);

  Map<String, String> get asMap {
    return {
      'weight': '$weight',
      'height': '$height',
      'age': '$age',
      'gender': '$gender',
      'sensor_location': '$sensorLocation',
      'sensor_address': '$sensorAddress',
      'sensor_name': '$sensorName'
    };
  }
}

String timeStampHHMMSS(DateTime timeStamp) {
  return timeStamp.toIso8601String();
}

/// Keys for Movisens data points
const String TAP_MARKER = 'tap_marker',
    BATTERY_LEVEL = 'battery_level',
    TIMESTAMP= 'timestamp',
    STEP_COUNT = 'step_count',
    MET = 'met',
    MET_LEVEL = 'met_level',
    BODY_POSITION = 'body_position',
    MOVEMENT_ACCELERATION = 'movement_acceleration',
    CONNECTION_STATUS = 'connection_status',
    HR='hr',
    IS_HRV_VALID='is_hrv_valid',
    HRV='hrv';


/// Factory function for converting a generic object sent through the platform channel into a concrete [MovisensDataPoint] object.
String parseDataPoint(dynamic javaMap) {
  Map<String, dynamic> data = Map<String, dynamic>.from(javaMap);



  String _hr = data.containsKey(HR) ? data[HR] : null;
  String _isHrvValid = data.containsKey(IS_HRV_VALID) ? data[IS_HRV_VALID] : null;
  String _hrv = data.containsKey(HRV) ? data[HRV] : null;
  String _batteryLevel = data.containsKey(BATTERY_LEVEL) ? data[BATTERY_LEVEL] : null;
  String _tapMarker = data.containsKey(TAP_MARKER) ? data[TAP_MARKER] : null;
  String _stepCount = data.containsKey(STEP_COUNT) ? data[STEP_COUNT] : null;
  String _met = data.containsKey(MET) ? data[MET] : null;
  String _metLevel = data.containsKey(MET_LEVEL) ? data[MET_LEVEL] : null;
  String _bodyPosition = data.containsKey(BODY_POSITION) ? data[BODY_POSITION] : null;
  String _movementAcceleration = data.containsKey(MOVEMENT_ACCELERATION) ? data[MOVEMENT_ACCELERATION] : null;
  String _connectionStatus = data.containsKey(CONNECTION_STATUS) ? data[CONNECTION_STATUS] : null;

  print(_connectionStatus);

  if(_hr!=null) return  movisensHR(_hr);

  if(_hrv!=null) return movisensHRV(_hrv);

  if (_batteryLevel != null) {
    return  movisensBatteryLevel(_batteryLevel);
  }
  if (_tapMarker != null) {
    return movisensTapMarker(_tapMarker);
  }

  if (_stepCount != null) {
    return movisensStepCount(_stepCount);
  }

  if (_movementAcceleration != null) {
    return movisensMovementAcceleration(_movementAcceleration);
  }

  if (_bodyPosition != null) {
    return movisensBodyPosition(_bodyPosition);
  }

  if(_isHrvValid!=null) return  movisensIsHrvValid(_isHrvValid);

  if (_metLevel != null) {
    return  movisensMetLevel(_metLevel);
  }

  if (_met != null) {
    return movisensMet(_met);
  }
  if (_connectionStatus != null && _connectionStatus != 'null') {
    return MovisensStatus(_connectionStatus);
  }
  return null;
  }


/// Deviec connection status with timeStamp
String MovisensStatus(String connectionStatus) {
  String _connectionStatusJson;
  _connectionStatusJson =  connectionStatus.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-\_]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "ConnectionStatus="+_connectionStatusJson;

}

String movisensMet(String met) {
  String _metJson;
  _metJson =  met.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "Met="+_metJson;
}


/// Metabolic buffered level, holds met level values for a sedentary, light and moderate state.
String movisensMetLevel(String metLevel) {

  String _metLevelJson;
  _metLevelJson =  metLevel.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "MetLevel="+_metLevelJson;

}


/// Informs if Signal is ok for HRV calculation
String movisensIsHrvValid(String isHrvValid) {

  String _isHrvValidJson;
  _isHrvValidJson =  isHrvValid.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "IsHrvValid="+_isHrvValidJson;
}

/// Body the body position Json
String movisensBodyPosition(String bodyPosition) {

  String _bodyPositionJson;
  _bodyPositionJson =  bodyPosition.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "BodyPosition="+_bodyPositionJson;
}

/// Returns 3D movement Acceleration Json
String movisensMovementAcceleration(String movementAcceleration) {
  String _movementAccelerationJson;
  _movementAccelerationJson =  movementAcceleration.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "MovementAcceleration="+_movementAccelerationJson;
}


///StepCount Json
String movisensStepCount(String stepCount) {

  String _stepCountJson;
  _stepCountJson =  stepCount.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "StepCount="+_stepCountJson;
}

String movisensTapMarker(String tapMarker) {

  String _tapMarkerJson;
  _tapMarkerJson =  tapMarker.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "TapMarker="+_tapMarkerJson;
}

String movisensBatteryLevel(String batteryLevel) {

  String _batteryLevelJson;
  _batteryLevelJson =  batteryLevel.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "BatteryLevel="+_batteryLevelJson;
}

String movisensHR(String hr)
{

  String _hrJson =  hr.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "HR="+_hrJson;
}


String movisensHRV(String hrv)
{
  String _hrvJson;
  _hrvJson =  hrv.replaceAllMapped(
      new RegExp(r'([a-z\_]+)\=([a-z\d\s.\s\s:-]+)'), (g) => '"${g[1]}":"${g[2]}"');
  return "HRV="+_hrvJson;
}



/// The main plugin class which establishes a [MethodChannel] and an [EventChannel].
class Movisens {
  MethodChannel _methodChannel = MethodChannel('movisens.method_channel');
  EventChannel _eventChannel = EventChannel('movisens.event_channel');
  Stream<String> _movisensStream;
  UserData _userData;

  Movisens(this._userData);

  Stream<String> get movisensStream {
    if (Platform.isAndroid) {
      if (_movisensStream == null) {
        Map<String, dynamic> args = {'user_data': _userData.asMap};
        _methodChannel.invokeMethod('userData', args);
        _movisensStream =
            _eventChannel.receiveBroadcastStream().map(parseDataPoint);
      }
      return _movisensStream;
    }
    throw MovisensException('Movisens API exclusively available on Android!');
  }
}
