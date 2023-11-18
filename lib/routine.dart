// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eee/course_view.dart';
import 'package:eee/data.dart';
import 'package:eee/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

final coursesStream =
    FirebaseFirestore.instance.collection('courses').snapshots().distinct();    //one stream cannot be used by multiple streambuilders

class Routine extends StatefulWidget {
  const Routine({super.key});

  @override
  State<Routine> createState() => _RoutineState();
}

class _RoutineState extends State<Routine> {
  final ValueNotifier<DateTime> _selectedDayNoti =
      ValueNotifier(DateTime.now());
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    print('$Routine rebuild');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed('/course'),
      ),
      appBar: AppBar(
        title: const Text("Routine"),
        centerTitle: true,
      ),
      drawer: const SideBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            StatefulBuilder(
              builder: (context, setState) => TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDayNoti.value, day),
                onDaySelected: (selectedDay, focusedDay) => setState(() {
                  _selectedDayNoti.value = selectedDay;
                  _focusedDay = focusedDay;
                }),
                headerVisible: false,
                daysOfWeekHeight: 20,
                availableGestures: AvailableGestures.none,
                calendarFormat: CalendarFormat.week,
                availableCalendarFormats: const {CalendarFormat.week: "Week"},
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                weekendDays: weekendDays,
                calendarStyle: const CalendarStyle(
                  weekendTextStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  outsideBuilder: (context, day, focusedDay) {
                    TextStyle? decor;
                    if (weekendDays.contains(day.weekday)) {
                      decor = const TextStyle(
                        color: Colors.red,
                      );
                    }
                    return Center(
                      child: Text(
                        day.day.toString(),
                        style: decor,
                      ),
                    );
                  },
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: coursesStream,
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
                    if (!snapshot.hasData) {
                      return const Text('No data');
                    }
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ValueListenableBuilder(
                          valueListenable: _selectedDayNoti,
                          builder: (context, value, child) {
                            return ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: getWeekly(snapshot).length,
                              itemBuilder: (context, index) {
                                CalendarEvent course =
                                    getWeekly(snapshot)[index];

                                return ListTile(
                                  title: Text(course.name),
                                  trailing: Text(course.duration),
                                  onLongPress: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CourseView(ref: course.name),
                                        ));
                                  },
                                  // minVerticalPadding: 18,
                                );
                              },
                            );
                          }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CalendarEvent> getWeekly(AsyncSnapshot snapshot) {
    List<CalendarEvent> list = List.empty(growable: true);
    for (QueryDocumentSnapshot docSnapshot in snapshot.data!.docs) {
      for (var time in docSnapshot['time']) {
        if (time['weekDay'] ==
            DateFormat.EEEE().format(_selectedDayNoti.value)) {
          var start = time['startTime'];
          var end = time['endTime'];
          list.add(CalendarEvent(
            name: docSnapshot['id'],
            duration: "$start ~ $end",
            time: DateFormat('hh:mm a').parse(start),
          ));
        }
      }
    }
    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  @override
  void dispose() {
    _selectedDayNoti.dispose();
    super.dispose();
  }
}
