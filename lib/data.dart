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
  List<Period> duration;
  
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

  factory Course.fromJson(Map <String, dynamic> json) {   //changed static type, don't know what factory does
    var list = List<Period>.empty(growable: true);
    for (var i = 0; i < json['duration'].length; i++) {
      list.add(Period.fromJson(json['duration']['Period $i']));
    }
    return Course(
      id: json['id'],
      credit: json['credit'],
      duration: list,
    );
  }
}

final List weekDays = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
];

final List<int> weekendDays = [
  DateTime.friday,
  DateTime.saturday,
];

class Period {
  String myId = "$Period";
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

  Period({
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

  static Period fromJson(Map <String, dynamic> json) => Period(
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
