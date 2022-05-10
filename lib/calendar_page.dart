import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: TableCalendar(
          firstDay: DateTime(DateTime.now().year, DateTime.now().month),
          lastDay: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
          focusedDay: DateTime.now(),
        ),
      ),
    );
  }
}
