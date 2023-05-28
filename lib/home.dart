// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final ValueNotifier<DateTime> _selectedDay = ValueNotifier(DateTime.now());
  DateTime _focusedDay = DateTime.now();

  final stream = FirebaseFirestore.instance
      .collection('root')
      .doc('courses')
      .snapshots()
      .distinct();
  final double calendarHeight = 132;
  final double bottomNavHeight = 24;

  @override
  Widget build(BuildContext context) {
    print('$MyHome rebuild');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CourseView(),
            )),
      ),
      appBar: AppBar(
        title: const Text("Routine"),
        centerTitle: true,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: calendarHeight,
              child: StatefulBuilder(
                  builder: (context, setState) => TableCalendar(
                        focusedDay: _focusedDay,
                        firstDay: DateTime.utc(2020),
                        lastDay: DateTime.utc(2030),
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay.value, day),
                        onDaySelected: (selectedDay, focusedDay) =>
                            setState(() {
                          _selectedDay.value = selectedDay;
                          _focusedDay = focusedDay;
                        }),
                        calendarFormat: CalendarFormat.week,
                        availableCalendarFormats: const {
                          CalendarFormat.week: "Week"
                        },
                        daysOfWeekStyle: const DaysOfWeekStyle(
                            weekendStyle: TextStyle(color: Colors.red)),
                        weekendDays: const [DateTime.friday, DateTime.saturday],
                        calendarStyle: const CalendarStyle(
                          weekendTextStyle: TextStyle(color: Colors.red),
                        ),
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
                                  _selectedDay.value = DateTime.now();
                                }),
                              )
                            ],
                          ),
                        ),
                      )),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    calendarHeight -
                    bottomNavHeight,
              ),
              child: StreamBuilder(
                stream: stream,
                builder: (context, snapshot) {
                  print('$StreamBuilder rebuild');
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      heightFactor: 5,
                      child: CircularProgressIndicator(),
                    );
                  }
                  syncFromFF(snapshot);

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ValueListenableBuilder(
                        valueListenable: _selectedDay,
                        builder: (context, value, child) {
                          var eventList = getEvents(_selectedDay.value);
                          return ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: eventList.length,
                            itemBuilder: (context, index) {
                              var course = eventList[index];

                              return ListTile(
                                title: Text(course.name),
                                trailing: Text(course.duration),
                                onLongPress: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CourseView(viewId: course.name),
                                      ));
                                },
                                minVerticalPadding: 18,
                              );
                            },
                          );
                        }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List getEvents(DateTime day) {
    var list = List<CalendarEvent>.empty(growable: true);
    for (var course in courses) {
      for (var item in course.duration) {
        if (item.weekDay == DateFormat.EEEE().format(day)) {
          var start = item.startTime!.format(context).padLeft(8, '0');
          var end = item.endTime!.format(context).padLeft(8, '0');
          var duration = "$start ~ $end";
          var time = DateFormat('hh:mm a').parse(start);
          list.add(CalendarEvent(course.id, time, duration));
        }
      }
    }
    list.sort(
      (a, b) => a.time.compareTo(b.time),
    );
    return list;
  }

  void syncFromFF(var snapshot) {
    var list = List<Course>.empty(growable: true);
    if (snapshot.data == null) return;
    var data = snapshot.data!.data() as Map;
    for (var i = 0; i < data.length; i++) {
      list.add(Course.fromJson(data['Course $i']));
    }
    courses = list;
  }
}
