// ignore_for_file: avoid_print


import 'package:cloud_firestore/cloud_firestore.dart';

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
  String startTime;
  String endTime;

  Duration({
    this.weekDay,
    this.startTime = '',
    this.endTime = '',
  });

  Map toJson() => {
    'startTime' : startTime,
    'endTime' : endTime,
    'weekDay' : weekDay,
  };

  static Duration fromJson(Map <String, dynamic> json) => Duration(
    weekDay: json['weekDay'],
    startTime: json['startTime'],
    endTime: json['endTime'],
  );
}

class CalendarEvent {
  String name;
  DateTime time;
  String duration;

  CalendarEvent(this.name, this.time, this.duration);
}

List<Course> courses = List<Course>.empty(growable: true);
