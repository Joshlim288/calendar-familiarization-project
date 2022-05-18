import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:temp/add_event_page.dart';
import 'package:temp/calendar_page.dart';
import 'package:temp/event_model.dart';
import 'package:sizer/sizer.dart';

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
      mockHiveBox!.put('TestKey', testEvent);
    } catch (e) {
      //Hive already initialized
    }
    calendarPageMaterialApp = Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: CalendarPage(box: mockHiveBox!),
        );
      },
    );
  });

  group('Testing calendar and event list widgets', () {
    testWidgets('Check today highlighted', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(calendarPageMaterialApp!);
      final String day = DateTime.now().day.toString();
      final Text dayText = tester.widget<Text>(find.text(day).first);
      await tester.pumpAndSettle();
      expect(dayText.style?.color, const Color(0xfffafafa)); // check day is white (selected)
    });

    testWidgets('Check multi-day event display', (WidgetTester tester) async {
      setScreenSize(tester);
      DateTime startTime = DateTime.now();
      DateTime endTime = DateTime.now().add(const Duration(days: 1));
      final Event multiDayTestEvent = Event(
        comment: 'Multi-Day Test comment',
        fullDay: false,
        startTime: startTime,
        endTime: endTime,
        name: 'Multi-Day Test Event',
        eventKey: 'Multi-Day TestKey',
      );
      mockHiveBox!.put(multiDayTestEvent.eventKey, multiDayTestEvent);

      // Check both dates are visible on current day
      await tester.pumpWidget(calendarPageMaterialApp!);
      final CalendarPageState calendarPageState = tester.state(find.byType(CalendarPage));
      expect(find.text(calendarPageState.multiDayFormatter.format(startTime)), findsOneWidget);
      expect(find.text(calendarPageState.multiDayFormatter.format(endTime)), findsOneWidget);

      // Check both dates are visible on next day
      await tester.tap(find.text(endTime.day.toString()).first);
      await tester.pumpAndSettle();
      expect(find.text(calendarPageState.multiDayFormatter.format(startTime)), findsOneWidget);
      expect(find.text(calendarPageState.multiDayFormatter.format(endTime)), findsOneWidget);

      // Remove event after done
      mockHiveBox!.delete(multiDayTestEvent.eventKey);
    });

    testWidgets('Test expanding event', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(calendarPageMaterialApp!);

      // check comment not visible
      expect(find.text(testEvent.comment), findsNothing);

      // expand and check comment visible
      await tester.tap(find.text(testEvent.name));
      await tester.pumpAndSettle();
      expect(find.text(testEvent.comment), findsOneWidget);

      // collapse and check comment not visible again
      await tester.tap(find.text(testEvent.name));
      await tester.pumpAndSettle();
      expect(find.text(testEvent.comment), findsNothing);
    });
  });

  group('Testing event management', () {
    testWidgets('Check add event', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(calendarPageMaterialApp!);

      // Check add event page opens
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

      // delete edit comment after done
      mockHiveBox!.delete('EditTestKey');
    });

    testWidgets('Test delete event', (WidgetTester tester) async {
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

      // Check event successfully added
      await tester.tap(find.text(deleteTestKey.name));
      await tester.pumpAndSettle();
      expect(find.text('Delete Test comment'), findsOneWidget);

      // Tap delete
      await tester.ensureVisible(find.byIcon(Icons.delete));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      // Test cancel delete
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text(deleteTestKey.name), findsOneWidget);

      // Test delete event
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text(deleteTestKey.name), findsNothing);
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
      await tester.pumpWidget(calendarPageMaterialApp!);
      final CalendarPageState calendarPageState = tester.state(find.byType(CalendarPage));
      final List<Event> eventList = calendarPageState.getEventsForDay(DateTime.now());
      expect(eventList.contains(testEvent), true);
    });

    testWidgets('Test onDaySelected', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(calendarPageMaterialApp!);
      final CalendarPageState calendarPageState = tester.state(find.byType(CalendarPage));
      int day = DateTime.now().day != 15 ? 15 : 16;
      final DateTime newSelectedDay = DateTime(DateTime.now().year, DateTime.now().month, day);
      expect(calendarPageState.selectedDay?.day == newSelectedDay.day, false);
      expect(calendarPageState.focusedDay.day == newSelectedDay.day, false);
      calendarPageState.onDaySelected(newSelectedDay, newSelectedDay);
      expect(calendarPageState.selectedDay?.day == newSelectedDay.day, true);
      expect(calendarPageState.focusedDay.day == newSelectedDay.day, true);
    });
  });
}
