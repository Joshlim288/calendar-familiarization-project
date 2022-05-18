import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sizer/sizer.dart';
import 'package:temp/calendar_page.dart';

import 'event_model.dart';

void main() async {
  // Initialize Hive before running application
  await Hive.initFlutter();
  final Directory applicationDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(applicationDocumentDir.path);
  Hive.registerAdapter(EventAdapter());

  // Box must be opened and passed along to allow for mocking of the box during integration testing
  final Box<Event> eventBox = await Hive.openBox<Event>('Events');

  runApp(MyApp(eventBox: eventBox));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.eventBox}) : super(key: key);
  final Box<Event> eventBox;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      // To allow for relative sizes
      builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
        return MaterialApp(
          title: 'Calendar Demo App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(title: 'Calendar Demo HomePage', box: eventBox),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.box}) : super(key: key);
  final String title;
  final Box<Event> box;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Menu', style: TextStyle(color: Colors.white)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => CalendarPage(box: widget.box)),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(
          'home page',
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
