import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:temp/add_event_page.dart';
import 'package:temp/event_model.dart';

import 'test_utils.dart';

// Run all tests with `flutter test`, or `flutter run -t .\test\add_event_page_test.dart` to see the tests run on a simulator
// To see the coverage, run with option --coverage and run `perl %GENHTML% coverage/lcov.info -o coverage/html` in cmd terminal
void main() {
  Widget? eventPageMaterialApp;
  Box<Event>? mockHiveBox;
  final DateTime initialDay = DateTime(DateTime.now().year, DateTime.now().month, 15, 7);

  setUp(() async {
    try {
      await Hive.initFlutter();
      final Directory applicationDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      Hive.init(applicationDocumentDir.path);
      Hive.registerAdapter(EventAdapter());
      // mock box to simulate data
      mockHiveBox = await Hive.openBox<Event>('MockEventsEventsPage'); // do not touch real data
    } catch (e) {
      //Hive already initialized
    }
    eventPageMaterialApp = MaterialApp(
      home: EventPage(
        eventBox: mockHiveBox!,
        selectedDay: initialDay,
      ),
    );
  });

  // while logic can be extracted, repetition is left in for clarity -> to more easily see the flow for each test case
  group('Test selectDate', () {
    testWidgets('Test start date after end date', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      final DateTime dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 31);

      // tap start date
      await tester.tap(find.text(eventPageState.dayFormatter.format(initialDay)).first);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // change start date to after end date
      await tester.tap(find.text(dayToSet.day.toString()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.dayFormatter.format(dayToSet)), findsNothing);
    });

    testWidgets('Test end date before start date', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      final DateTime dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 1);

      // tap end date
      await tester.tap(find.text(eventPageState.dayFormatter.format(initialDay)).last);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // change end date to before start date
      await tester.tap(find.text(dayToSet.day.toString()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.dayFormatter.format(dayToSet)), findsNothing);
    });

    testWidgets('Test start date picker', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      final DateTime dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 1);

      // Tap start date
      await tester.tap(find.text(eventPageState.dayFormatter.format(initialDay)).first);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // change start date to valid value
      await tester.tap(find.text(dayToSet.day.toString()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.dayFormatter.format(dayToSet)), findsOneWidget);
    });

    testWidgets('Test end date picker', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      final DateTime dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 28);

      // tap end date
      await tester.tap(find.text(eventPageState.dayFormatter.format(initialDay)).last);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // set end date to valid value
      await tester.tap(find.text(dayToSet.day.toString()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.dayFormatter.format(dayToSet)), findsOneWidget);
    });
  });

  group('Test selectTime', () {
    // while logic can be extracted, repetition is left in for clarity -> to more easily see the flow for each test case
    testWidgets('Test start time after end time', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      final DateTime dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 15, 9);

      // Tap start time
      await tester.tap(find.text(eventPageState.timeFormatter.format(initialDay)).first);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Set start time after end time
      // Limitation of timepicker: the only way to tap a number is using Offset (from the docs)
      final Offset center = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      await tester.tapAt(Offset(center.dx - 10, center.dy)); // x-10 picks 9
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.timeFormatter.format(dayToSet)), findsNothing);
    });

    testWidgets('Test end time before start time', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      final DateTime dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 15, 3);

      // Tap end time
      await tester.tap(find.text(eventPageState.timeFormatter.format(initialDay.add(const Duration(hours: 1)))).first);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Set end time after start time
      // Limitation of timepicker: the only way to tap a number is using Offset (from the docs)
      final Offset center = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      await tester.tapAt(Offset(center.dx + 10, center.dy)); // x+10 picks 3
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.timeFormatter.format(dayToSet)), findsNothing);
    });

    testWidgets('Test start time picker', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      final DateTime dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 15, 6);

      // Tap start time
      await tester.tap(find.text(eventPageState.timeFormatter.format(initialDay)).first);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Set start time to valid value
      // Limitation of timepicker: the only way to tap a number is using Offset (from the docs)
      final Offset center = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      await tester.tapAt(Offset(center.dx, center.dy + 10)); // y+10 picks 6
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.timeFormatter.format(dayToSet)), findsOneWidget);
    });

    testWidgets('Test end time picker', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      final DateTime dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 15, 9);

      // Tap end time
      await tester.tap(find.text(eventPageState.timeFormatter.format(initialDay.add(const Duration(hours: 1)))).first);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Set end time to valid value
      // Limitation of timepicker: the only way to tap a number is using Offset (from the docs)
      final Offset center = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      await tester.tapAt(Offset(center.dx - 10, center.dy)); // x-10 picks 9
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.timeFormatter.format(dayToSet)), findsOneWidget);
    });
  });

  testWidgets('Test full day switch', (WidgetTester tester) async {
    setScreenSize(tester);
    await tester.pumpWidget(eventPageMaterialApp!);
    final EventPageState eventPageState = tester.state(find.byType(EventPage));

    // check full day switch not activated
    expect(eventPageState.fullDay, false);

    // check full day changes state and removes time widgets
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(eventPageState.fullDay, true);
    expect(find.text(eventPageState.timeFormatter.format(initialDay)), findsNothing);

    // check full day reverts state and time widgets
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(eventPageState.fullDay, false);
    expect(find.text(eventPageState.timeFormatter.format(initialDay)), findsOneWidget);
  });

  group('Test helper functions', () {
    test('Test generate key', () {
      final Set<String> keys = <String>{};
      // bare bones implementation: checks for duplicates in 50 generated keys to ensure generation is sufficiently random
      for (int i = 0; i < 50; i++) {
        keys.add(generateRandomString(16));
      }
      expect(keys.length == 50, true);
    });
  });
}
