class Course {
  String id;
  String name;
  int credit;
  Course(this.name, this.id, this.credit);
}

class Duration {
  DateTime start;
  DateTime end;
  Duration(this.start, this.end);
}

class Courses {
  Course course;
  List<Duration> duration;
  Courses(this.course, this.duration);
}

const List weekDays = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday"
];

class ListViewItem {
  String textStartTime = "";
  String textEndTime = "";
  Object? dropdownValue;
}