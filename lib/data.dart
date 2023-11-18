// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NavigationService {
  static var navigatorKey = GlobalKey<NavigatorState>();
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
  // String myId = "$Period";
  String? weekDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String getStartTime() {
    var context = NavigationService.navigatorKey.currentContext;
    return (startTime == null)
        ? ""
        : startTime!.format(context!).padLeft(8, '0');
  }

  String getEndTime() {
    var context = NavigationService.navigatorKey.currentContext;
    return (endTime == null) ? "" : endTime!.format(context!).padLeft(8, '0');
  }

  Period({
    this.weekDay,
    this.startTime,
    this.endTime,
  });

  Map<String, String> toJson() => {
        'startTime': getStartTime(),
        'endTime': getEndTime(),
        'weekDay': weekDay!,
      };

  static TimeOfDay timeFrom(String? str) {
    var time = DateFormat('hh:mm a').parse(str!);
    return TimeOfDay.fromDateTime(time);
  }

  static Period fromJson(Map<String, dynamic> json) => Period(
        weekDay: json['weekDay'],
        startTime: timeFrom(json['startTime']),
        endTime: timeFrom(json['endTime']),
      );
}

class CalendarEvent {
  String name;
  DateTime time;
  String duration;

  CalendarEvent({
    required this.name,
    required this.time,
    required this.duration,
  });
}
