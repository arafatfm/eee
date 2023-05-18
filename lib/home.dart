import 'package:eee/course_view.dart';
import 'package:eee/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseView(),
              )).then((value) => setState(() {}))),
      appBar: AppBar(
        title: const Text("Routine"),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) => setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            }),
            calendarFormat: CalendarFormat.week,
            availableCalendarFormats: const {CalendarFormat.week: "Week"},
            daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.red)),
            weekendDays: const [DateTime.friday, DateTime.saturday],
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) => Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat.yMMM().format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TextButton(
                    child: const Text("Today"),
                    onPressed: () => setState(() {
                      _focusedDay = DateTime.now();
                      _selectedDay = DateTime.now();
                    }),
                  )
                ],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: getEvents(_selectedDay).length,
            itemBuilder: (context, index) {
              var course = getEvents(_selectedDay)[index];
              return ListTile(
                title: Text(course.name),
                trailing: Text(course.duration),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseView.a(course.name),
                      )).then((value) => setState(() {}));
                },
              );
            },
          )
        ],
      ),
    );
  }

  List getEvents(DateTime day) {
    var list = List<CalendarEvent>.empty(growable: true);
    for (var course in courses) {
      for (var item in course.duration) {
        if (item.weekDay == DateFormat.EEEE().format(day)) {
          var time = DateFormat('hh:mm a').parse(item.startTime);
          var duration = "${item.startTime} ~ ${item.endTime}";
          list.add(CalendarEvent(course.id, time, duration));
        }
      }
    }
    list.sort(
      (a, b) => a.time.compareTo(b.time),
    );
    return list;
  }
}
