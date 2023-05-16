import 'package:eee/course_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CourseView(),
          )
        ).then((value) => setState((){}))
      ),
        appBar: AppBar(
          title: const Text("Routine"),
        ),
        body: Container(
          child: TableCalendar(
            focusedDay: _focusedDay, 
            firstDay: DateTime.utc(2020), 
            lastDay: DateTime.utc(2030),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) => setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            }),
            calendarFormat: CalendarFormat.week,
            availableCalendarFormats: const {
              CalendarFormat.week: "Week"
            },
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red)
            ),
            weekendDays: const [DateTime.friday, DateTime.saturday],
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) => Container(
                child: Row(
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
            
          ),
        ),
    );
  }
}