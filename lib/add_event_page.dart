import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'event_model.dart';

class EventPage extends StatefulWidget {
  const EventPage({
    Key? key,
    required this.selectedDay,
    this.editEventKey,
    required this.eventBox,
  }) : super(key: key);

  final DateTime? selectedDay;
  final String? editEventKey;
  final Box<Event> eventBox;

  @override
  State<StatefulWidget> createState() => EventPageState();
}

class EventPageState extends State<EventPage> {
  late bool fullDay;
  DateTime? startDateTime;
  DateTime? endDateTime;
  late String bottomButtonString;
  final DateFormat dayFormatter = DateFormat('E, dd MMM');
  final DateFormat timeFormatter = DateFormat('HH:mm');
  final TextEditingController nameController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editEventKey == null) {
      // creating new event
      fullDay = false;
      startDateTime = widget.selectedDay;
      endDateTime = widget.selectedDay?.add(const Duration(hours: 1));
      bottomButtonString = 'SUBMIT';
    } else {
      // editing existing event
      final Event eventToEdit = widget.eventBox.get(widget.editEventKey)!;
      fullDay = eventToEdit.fullDay;
      startDateTime = eventToEdit.startTime;
      endDateTime = eventToEdit.endTime;
      nameController.text = eventToEdit.name;
      commentController.text = eventToEdit.comment;
      bottomButtonString = 'SAVE';
    }
  }

  void selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? startDateTime! : endDateTime!;
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != initialDate) {
      // date has been changed
      setState(() {
        // carry over only year, month and day for new date
        if (isStart) {
          if (selected.isBefore(endDateTime!)) {
            // Check startDate before endDate
            startDateTime = DateTime(selected.year, selected.month, selected.day, startDateTime!.hour, startDateTime!.minute);
            return;
          }
        } else {
          if (selected.isAfter(startDateTime!)) {
            endDateTime = DateTime(selected.year, selected.month, selected.day, endDateTime!.hour, endDateTime!.minute);
            return;
          }
        }
        Fluttertoast.showToast(
          msg: 'End Date must be after Start Date', // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.BOTTOM, // location
        );
      });
    }
  }

  void selectTime(BuildContext context, bool isStart) async {
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

  String generateRandomString(int length) {
    final Random _random = Random();
    const String _availableChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final String randomString = List<String>.generate(length, (int index) => _availableChars[_random.nextInt(_availableChars.length)]).join();

    return randomString;
  }

  void submitEvent() {
    // initial implementation of unique key generation, may want to improve
    String key;
    if (widget.editEventKey != null) {
      key = widget.editEventKey!;
    } else {
      // not editing, generate new key
      do {
        key = generateRandomString(16);
      } while (widget.eventBox.keys.contains(key));
    }
    final String name = nameController.text.isNotEmpty ? nameController.text : 'New Event';
    final String comment = commentController.text.isNotEmpty ? commentController.text : '-';
    final Event newEvent = Event(fullDay: fullDay, startTime: startDateTime!, comment: comment, name: name, endTime: endDateTime!, eventKey: key);
    widget.eventBox.put(key, newEvent);
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
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
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
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          children: [
                            TextButton(
                              child: Text(dayFormatter.format(startDateTime!)),
                              onPressed: () {
                                selectDate(context, true);
                              },
                            ),
                            if (!fullDay)
                              TextButton(
                                child: Text(timeFormatter.format(startDateTime!)),
                                onPressed: () {
                                  selectTime(context, true);
                                },
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_right),
                      Column(
                        children: [
                          TextButton(
                            child: Text(dayFormatter.format(endDateTime!)),
                            onPressed: () {
                              selectDate(context, false);
                            },
                          ),
                          if (!fullDay)
                            TextButton(
                              child: Text(timeFormatter.format(endDateTime!)),
                              onPressed: () {
                                selectTime(context, false);
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
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 10,
                  controller: commentController,
                  decoration: const InputDecoration(
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
              onPressed: submitEvent,
              child: Text(bottomButtonString),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    commentController.dispose();
    super.dispose();
  }
}
