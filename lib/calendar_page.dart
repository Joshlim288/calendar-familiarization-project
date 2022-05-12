import 'package:flutter/cupertino.dart';
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
  List<String> expandedEventIds = [];
  final DateFormat multiDayFormatter = DateFormat('dd E');
  final DateFormat dayNumFormatter = DateFormat('dd');
  final DateFormat dayTextFormatter = DateFormat('E');
  final DateFormat timeFormatter = DateFormat('hh:mm');
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
              markerDecoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _selectedEvents?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ExpansionTile(
                    leading: SizedBox(
                        width: 50,
                        child: (_selectedEvents![index].startTime.day != _selectedEvents![index].endTime.day)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(multiDayFormatter.format(_selectedEvents![index].startTime)),
                                  const Icon(Icons.arrow_downward),
                                  Text(multiDayFormatter.format(_selectedEvents![index].endTime)),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    dayNumFormatter.format(_selectedEvents![index].startTime),
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1.5,
                                  ),
                                  Text(
                                    dayTextFormatter.format(_selectedEvents![index].startTime),
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1.15,
                                  ),
                                ],
                              )),
                    title: Text(_selectedEvents![index].name),
                    subtitle: _selectedEvents![index].fullDay
                        ? const Text('Full Day')
                        : Text(
                            '${timeFormatter.format(_selectedEvents![index].startTime)} to ${timeFormatter.format(_selectedEvents![index].endTime)}',
                          ),
                    trailing: (expandedEventIds.contains(_selectedEvents![index].eventKey)) ? const Icon(Icons.arrow_drop_up_outlined) : const Icon(Icons.arrow_drop_down_outlined),
                    children: <Widget>[
                      ListTile(title: Text(_selectedEvents![index].comment)),
                    ],
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        String id = _selectedEvents![index].eventKey;
                        if (expandedEventIds.contains(id)) {
                          expandedEventIds.remove(id);
                        } else {
                          expandedEventIds.add(id);
                        }
                      });
                    },
                  ),
                );
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
