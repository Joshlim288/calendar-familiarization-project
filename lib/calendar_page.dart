import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'add_event_page.dart';
import 'event_model.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final Box<Event> box;
  late List<Event> eventList;
  final DateFormat dayFormatter = DateFormat('E, dd MMM');
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<Event>? _selectedEvents;

  @override
  void initState() {
    super.initState();
    // get the previously opened user box
    box = Hive.box<Event>('Events');
    eventList = box.values.toList();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return eventList
        .where(
          (Event event) => event.startTime.day <= day.day && day.day <= event.endTime.day && event.startTime.month <= day.month && day.month <= event.endTime.month && event.startTime.year <= day.year && day.year <= event.endTime.year,
        )
        .toList();
  }

  _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _getEventsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    eventList = box.values.toList();
    _onDaySelected(_selectedDay ?? DateTime.now(), _focusedDay);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2010),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (DateTime day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onPageChanged: (DateTime focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'month'},
            eventLoader: (DateTime day) {
              return _getEventsForDay(day);
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(color: Colors.deepOrangeAccent),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _selectedEvents?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_selectedEvents![index].name),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Event',
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (BuildContext context) => EventPage(
                    selectedDay: _selectedDay,
                  ),
                ),
              )
              .then((value) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
