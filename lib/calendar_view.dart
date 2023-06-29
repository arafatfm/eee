import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eee/event_view.dart';
import 'package:eee/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'data.dart';

class MyCalendar extends StatefulWidget {
  const MyCalendar({super.key});

  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  List eventDB = List.empty(growable: true);

  final ValueNotifier<DateTime> _selectedDayNotifier =
      ValueNotifier(DateTime.now());

  late final ValueNotifier changeNotifier;

  @override
  void initState() {
    super.initState();
    changeNotifier = ValueNotifier(eventDB.length);
  }

  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final stream =
      FirebaseFirestore.instance.collection('events').snapshots().distinct();
  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Calendar'),
      ),
      drawer: const SideBar(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventView(
              date: _selectedDayNotifier.value,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: changeNotifier,
            builder: (context, value, child) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2030),
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDayNotifier.value, day),
                    onDaySelected: (selectedDay, focusedDay) => setState(() {
                      _selectedDayNotifier.value = selectedDay;
                      _focusedDay = focusedDay;
                    }),
                    eventLoader: _getEventsForDay,
                    calendarFormat: _calendarFormat,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                      CalendarFormat.week: 'Week',
                    },
                    onFormatChanged: (format) =>
                        setState(() => _calendarFormat = format),
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                        _selectedDayNotifier.value = focusedDay;
                      },);
                    },
                    onHeaderTapped: (focusedDay) {
                      setState(() {
                        _focusedDay = DateTime.now();
                        _selectedDayNotifier.value = DateTime.now();
                      },);
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonShowsNext: false,
                      leftChevronVisible: false,
                      rightChevronVisible: false,
                      headerMargin: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    weekendDays: weekendDays,
                    calendarStyle: const CalendarStyle(
                      markersMaxCount: 1,
                      weekendTextStyle: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    // calendarBuilders: CalendarBuilders(
                    //   outsideBuilder: (context, day, focusedDay) {
                    //     TextStyle? decor;
                    //     if (weekendDays.contains(day.weekday)) {
                    //       decor = const TextStyle(
                    //         color: Colors.red,
                    //       );
                    //     }
                    //     return Center(
                    //       child: Text(
                    //         day.day.toString(),
                    //         style: decor,
                    //       ),
                    //     );
                    //   },
                    //   //   headerTitleBuilder: (context, day) => Row(
                    //   //     children: [
                    //   //       Expanded(
                    //   //         child: Text(
                    //   //           DateFormat.yMMM().format(DateTime.now()),
                    //   //           style: const TextStyle(
                    //   //             fontSize: 18,
                    //   //           ),
                    //   //         ),
                    //   //       ),
                    //   //       TextButton(
                    //   //         child: const Text("Today"),
                    //   //         onPressed: () => setState(() {
                    //   //           _focusedDay = DateTime.now();
                    //   //           _selectedDayNoti.value = DateTime.now();
                    //   //         }),
                    //   //       )
                    //   //     ],
                    //   //   ),
                    // ),
                  );
                }
              );
            }
          ),
          StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  heightFactor: 5,
                  child: CircularProgressIndicator(),
                );
              }
              syncEvents(snapshot);
              
              return ValueListenableBuilder(
                valueListenable: _selectedDayNotifier,
                builder: (context, selectedDay, child) {

                  var list = _getEventsForDay(selectedDay);
                  
                  return Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            
                            return ListTile(
                              title: Text(list[index]['name']),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void syncEvents(snapshot) {
    var list = List.empty(growable: true);
    var qDocSnapshots = snapshot.data!.docs;
    for(var qDocSnapshot in qDocSnapshots) {
      list.add(qDocSnapshot.data());
    }
    eventDB = list;
    Future.delayed(const Duration(), () {
      changeNotifier.value = eventDB.length;
    },);
  }

  List _getEventsForDay(DateTime day) {
    List list = List.empty(growable: true);
    for(var event in eventDB) {
      if(event['date'] == DateFormat('yyyy-MM-d').format(day)) {
        list.add(event);
      }
    }
    return list;
  }

  @override
  void dispose() {
    _selectedDayNotifier.dispose();
    changeNotifier.dispose();
    super.dispose();
  }
}
