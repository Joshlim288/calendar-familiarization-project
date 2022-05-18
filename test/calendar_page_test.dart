import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:temp/add_event_page.dart';
import 'package:temp/calendar_page.dart';
import 'package:temp/event_model.dart';

import 'test_utils.dart';

// Run all tests with `flutter test`, or `flutter run -t .\test\calendar_page_test.dart` to see the tests run on a simulator
// To see the coverage, run with option --coverage and run `perl %GENHTML% coverage/lcov.info -o coverage/html` in cmd terminal
void main() {
  Widget? calendarPageMaterialApp;
  Box<Event>? mockHiveBox;

  // Initializing Hive and setting up mock Hive box for testing
  setUp(() async {
    try {
      await Hive.initFlutter();
      final Directory applicationDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      Hive.init(applicationDocumentDir.path);
      Hive.registerAdapter(EventAdapter());
      // mock box to simulate data
      mockHiveBox = await Hive.openBox<Event>('MockEventsCalendarPage'); // do not touch real data
    } catch (e) {
      //Hive already initialized
    }
    mockHiveBox!.clear(); // clear data before start of each test
    calendarPageMaterialApp = MaterialApp(home: CalendarPage(box: mockHiveBox!));
  });

  group('Testing calendar widget', () {
    testWidgets('Check today highlighted', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(calendarPageMaterialApp!);
      final String day = DateTime.now().day.toString();
      final Text dayText = tester.widget<Text>(find.text(day).first);
      await tester.pumpAndSettle();
      expect(dayText.style?.color, const Color(0xfffafafa)); // check day is white (selected)
    });
  });

  group('Testing add event', () {
    testWidgets('Check open add event page', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(calendarPageMaterialApp!);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(EventPage), findsOneWidget);
    });

    testWidgets('Test edit event', (WidgetTester tester) async {
      // tests involving updating data must use a new event, to not interfere with other tests, since they are async
      final Event editTestEvent = Event(
        comment: 'Edit Test comment',
        fullDay: false,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        name: 'Edit Test Event',
        eventKey: 'EditTestKey',
      );
      // Check edit page info filled out
      mockHiveBox!.put('EditTestKey', editTestEvent);
      await tester.pumpWidget(calendarPageMaterialApp!);
      final CalendarPageState calendarPageState = tester.state(find.byType(CalendarPage));
      calendarPageState.loadData();
      await tester.tap(find.text(editTestEvent.name));
      await tester.pumpAndSettle();
      expect(find.text('Edit Test comment'), findsOneWidget);
      await tester.ensureVisible(find.byIcon(Icons.edit_calendar_outlined));
      await tester.tap(find.byIcon(Icons.edit_calendar_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(EventPage), findsOneWidget);
      expect(find.text(editTestEvent.name), findsOneWidget);

      // Check editing event
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      eventPageState.nameController.text = 'Edited Test Event';
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.text('Edited Test Event'), findsOneWidget);
      expect(find.text('Edit Test Event'), findsNothing);
    });
  });

  group('Testing helper functions', () {
    testWidgets('Test loadData', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(calendarPageMaterialApp!);
      final CalendarPageState calendarPageState = tester.state(find.byType(CalendarPage));
      calendarPageState.loadData();
      // tests involving updating events must use a new event, to not interfere with other tests, since they are async
      final Event testEventLoadData = Event(
        comment: 'LoadData Test comment',
        fullDay: false,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        name: 'LoadData Test Event',
        eventKey: 'LoadData TestKey',
      );
      // check list does not contain this event at first
      expect(calendarPageState.eventList.contains(testEventLoadData), false);
      // put testEventLoadData, check updated
      mockHiveBox!.put('LoadData TestKey', testEventLoadData);
      calendarPageState.loadData();
      expect(calendarPageState.eventList.contains(testEventLoadData), true);
      // remove after test done
      mockHiveBox!.delete('LoadData TestKey');
    });

    testWidgets('Test getEventsForDay', (WidgetTester tester) async {
      setScreenSize(tester);
      mockHiveBox!.put('TestKey', testEvent);
      await tester.pumpWidget(calendarPageMaterialApp!);
      final CalendarPageState calendarPageState = tester.state(find.byType(CalendarPage));
      calendarPageState.loadData();
      final List<Event> eventList = calendarPageState.getEventsForDay(DateTime.now());
      expect(eventList.contains(testEvent), true);
    });

    testWidgets('Test onDaySelected', (WidgetTester tester) async {
      setScreenSize(tester);
      mockHiveBox!.put('TestKey', testEvent);
      await tester.pumpWidget(calendarPageMaterialApp!);
      final CalendarPageState calendarPageState = tester.state(find.byType(CalendarPage));
      calendarPageState.loadData();
      int day = DateTime.now().day != 15 ? 15 : 16;
      final DateTime newSelectedDay = DateTime(DateTime.now().year, DateTime.now().month, day);
      expect(calendarPageState.selectedDay?.day == newSelectedDay.day, false);
      expect(calendarPageState.focusedDay.day == newSelectedDay.day, false);
      calendarPageState.onDaySelected(newSelectedDay, newSelectedDay);
      expect(calendarPageState.selectedDay?.day == newSelectedDay.day, true);
      expect(calendarPageState.focusedDay.day == newSelectedDay.day, true);
    });

    testWidgets('Test confirmDelete', (WidgetTester tester) async {
      setScreenSize(tester);
      // tests involving updating data must use a new event, to not interfere with other tests, since they are async
      final Event deleteTestKey = Event(
        comment: 'Delete Test comment',
        fullDay: false,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        name: 'Delete Test Event',
        eventKey: 'Delete TestKey',
      );
      mockHiveBox!.put('Delete TestKey', deleteTestKey);
      await tester.pumpWidget(calendarPageMaterialApp!);
      final CalendarPageState calendarPageState = tester.state(find.byType(CalendarPage));
      calendarPageState.loadData();
      await tester.tap(find.text(deleteTestKey.name));
      await tester.pumpAndSettle();
      expect(find.text('Delete Test comment'), findsOneWidget);
      await tester.ensureVisible(find.byIcon(Icons.delete));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text(deleteTestKey.name), findsNothing);
    });
  });
}
