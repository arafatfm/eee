import 'package:eee/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'data.dart';

class MyCalendar extends StatefulWidget {
  const MyCalendar({super.key});

  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  final ValueNotifier<DateTime> _selectedDayNoti =
      ValueNotifier(DateTime.now());
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Calendar'),
      ),
      drawer: const SideBar(),
      body: Column(
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
                  _selectedDayNoti.value = focusedDay;
                },);
              },
              onHeaderTapped: (focusedDay) {
                setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDayNoti.value = DateTime.now();
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
            ),
          ),
        ],
      ),
    );
  }
}
