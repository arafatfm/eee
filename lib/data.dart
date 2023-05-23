// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NavigationService {
  static var navigatorKey = GlobalKey<NavigatorState>();
}

class Course {
  String myId = "$Course";
  late String code;
  String id;
  int credit;
  List<Duration> duration;
  
  Course({
    required this.id,
    required this.credit,
    required this.duration,
  }) {
    code = id.replaceAll(RegExp(r'[^0-9]'), '');
  }
  
  Map toJson() => {
    'id' : id,
    'credit' : credit,
    'code' : code,
        'duration': {
          for (var i = 0; i < duration.length; i++)
            '${duration[i].myId} $i': duration[i].toJson()
        }
  };

  static fromJson(Map <String, dynamic> json) {
    var list = List<Duration>.empty(growable: true);
    for (var i = 0; i < json['duration'].length; i++) {
      list.add(Duration.fromJson(json['duration']['Duration $i']));
    }
    return Course(
      id: json['id'],
      credit: json['credit'],
      duration: list,
    );
  }
}

const List weekDays = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday"
];

class Duration {
  String myId = "$Duration";
  String? weekDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  getStartTime() {
    var context = NavigationService.navigatorKey.currentContext;
    return (startTime==null) ? "" : startTime!.format(context!).padLeft(8, '');
  }

  getEndTime() {
    var context = NavigationService.navigatorKey.currentContext;
    return (endTime==null) ? "" : endTime!.format(context!).padLeft(8, '');
  }

  Duration({
    this.weekDay,
    this.startTime,
    this.endTime,
  });

  Map toJson() => {
    'startTime' : getStartTime(),
    'endTime' : getEndTime(),
    'weekDay' : weekDay,
  };

  static timeFrom(String str) {
    var time = DateFormat('hh:mm a').parse(str);
    return TimeOfDay.fromDateTime(time);
  }

  static Duration fromJson(Map <String, dynamic> json) => Duration(
    weekDay: json['weekDay'],
    startTime: timeFrom(json['startTime']),
    endTime: timeFrom(json['endTime']),
  );
}

class CalendarEvent {
  String name;
  DateTime time;
  String duration;

  CalendarEvent(this.name, this.time, this.duration);
}

List<Course> courses = List<Course>.empty(growable: true);
