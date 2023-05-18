class Course {
  late String code;
  String id;
  int credit;
  List<Duration> duration;
  Course(this.id, this.credit, this.duration) {
    code = id.replaceAll(RegExp(r'[^0-9]'),'');
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
  String startTime = "";
  String endTime = "";
  String? weekDay;
}

class CalendarEvent {
  String name;
  DateTime time;
  String duration;

  CalendarEvent(this.name, this.time, this.duration);
}
var courses = List<Course>.empty(growable: true);