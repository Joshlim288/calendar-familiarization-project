import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'event_model.dart';

class EventPage extends StatefulWidget {
  EventPage({
    Key? key,
    required this.selectedDay,
  }) : super(key: key);

  final DateTime? selectedDay;

  @override
  State<StatefulWidget> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool fullDay = false;
  DateTime? startDateTime;
  DateTime? endDateTime;
  String title = 'New Event';
  String comment = '-';
  final DateFormat dayFormatter = DateFormat('E, dd MMM');
  final DateFormat timeFormatter = DateFormat('HH:mm');

  @override
  void initState() {
    startDateTime = widget.selectedDay;
    endDateTime = widget.selectedDay?.add(const Duration(hours: 1));
  }

  void _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: startDateTime!,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != startDateTime!) {
      setState(() {
        // multi-day events not yet implemented
        startDateTime = DateTime(selected.year, selected.month, selected.day, startDateTime!.hour, startDateTime!.minute);
        endDateTime = DateTime(selected.year, selected.month, selected.day, endDateTime!.hour, endDateTime!.minute);
      });
    }
  }

  void _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay selectedTime = isStart ? TimeOfDay.fromDateTime(startDateTime!) : TimeOfDay.fromDateTime(endDateTime!);
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        final DateTime selectedDateTime;
        if (isStart) {
          selectedDateTime = DateTime(startDateTime!.year, startDateTime!.month, startDateTime!.day, timeOfDay.hour, timeOfDay.minute);
          if (selectedDateTime.isBefore(endDateTime!)) {
            startDateTime = selectedDateTime;
          } else {
            Fluttertoast.showToast(
              msg: 'Start Time must be before End Time', // message
              toastLength: Toast.LENGTH_SHORT, // length
              gravity: ToastGravity.BOTTOM, // location
            );
          }
        } else {
          selectedDateTime = DateTime(endDateTime!.year, endDateTime!.month, endDateTime!.day, timeOfDay.hour, timeOfDay.minute);
          if (selectedDateTime.isAfter(startDateTime!)) {
            endDateTime = selectedDateTime;
          } else {
            Fluttertoast.showToast(
              msg: 'End Time must be after Start Time', // message
              toastLength: Toast.LENGTH_SHORT, // length
              gravity: ToastGravity.BOTTOM, // location
            );
          }
        }
      });
    }
  }

  void _submitEvent() {
    final Box<List<Event>?> eventBox = Hive.box('Events');
    final List<Event> eventList = eventBox.get(dayFormatter.format(startDateTime!)) ?? <Event>[];
    eventList.add(Event(name: title, endTime: endDateTime!, startTime: startDateTime!, fullDay: fullDay, comment: comment));
    eventBox.put(dayFormatter.format(startDateTime!), eventList);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Event'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Name:',
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter event name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Full day:',
                      ),
                    ),
                    Switch(
                      value: fullDay,
                      onChanged: (bool? value) {
                        setState(() {
                          fullDay = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Date:',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.black38), borderRadius: const BorderRadius.all(Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          TextButton(
                            child: Text(dayFormatter.format(startDateTime!)),
                            onPressed: () {
                              _selectDate(context);
                            },
                          ),
                          if (!fullDay)
                            TextButton(
                              child: Text(timeFormatter.format(startDateTime!)),
                              onPressed: () {
                                _selectTime(context, true);
                              },
                            ),
                        ],
                      ),
                      const Icon(Icons.arrow_right),
                      Column(
                        children: [
                          TextButton(
                            child: Text(dayFormatter.format(endDateTime!)),
                            onPressed: () {
                              _selectDate(context);
                            },
                          ),
                          if (!fullDay)
                            TextButton(
                              child: Text(timeFormatter.format(endDateTime!)),
                              onPressed: () {
                                _selectTime(context, false);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text('Comment:'),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a comment',
                  ),
                ),
              )
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onPressed: _submitEvent,
              child: const Text('SUBMIT'),
            ),
          ),
        ),
      ),
    );
  }
}
