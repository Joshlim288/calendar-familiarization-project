import 'dart:io';

import 'package:flutter/foundation.dart';
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
  DateTime initialDay = DateTime(DateTime.now().year, DateTime.now().month, 15, 7);

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

  group('Test selectDate', () {
    testWidgets('Test start date after end date', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      DateTime dayToSet;
      await tester.tap(find.text(eventPageState.dayFormatter.format(initialDay)).first);
      dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 31);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text(dayToSet.day.toString()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.dayFormatter.format(dayToSet)), findsNothing);
    });

    testWidgets('Test end date before start date', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      DateTime dayToSet;
      await tester.tap(find.text(eventPageState.dayFormatter.format(initialDay)).last);
      dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 1);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text(dayToSet.day.toString()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.dayFormatter.format(dayToSet)), findsNothing);
    });

    testWidgets('Test start date picker', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      DateTime dayToSet;
      // Test start date picker
      await tester.tap(find.text(eventPageState.dayFormatter.format(initialDay)).first);
      dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 1);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text(dayToSet.day.toString()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.dayFormatter.format(dayToSet)), findsOneWidget);
    });

    testWidgets('Test end date picker', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      DateTime dayToSet;
      await tester.tap(find.text(eventPageState.dayFormatter.format(initialDay)).last);
      dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 28);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text(dayToSet.day.toString()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.dayFormatter.format(dayToSet)), findsOneWidget);
    });
  });

  group('Test selectTime', () {
    testWidgets('Test start time after end time', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      DateTime dayToSet;
      // Test start date picker
      await tester.tap(find.text(eventPageState.timeFormatter.format(initialDay)).first);
      dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 15, 9);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Limitation of timepicker: this is the only way to tap a number (from the docs)
      var center = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      await tester.tapAt(Offset(center.dx - 10, center.dy)); // -10 picks 9

      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.timeFormatter.format(dayToSet)), findsNothing);
    });

    testWidgets('Test end time before start time', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      DateTime dayToSet;
      // Test start date picker
      await tester.tap(find.text(eventPageState.timeFormatter.format(initialDay.add(const Duration(hours: 1)))).first);
      dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 15, 3);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Limitation of timepicker: this is the only way to tap a number (from the docs)
      var center = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      await tester.tapAt(Offset(center.dx + 10, center.dy)); // +10 picks 3

      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.timeFormatter.format(dayToSet)), findsNothing);
    });

    testWidgets('Test start time picker', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      DateTime dayToSet;
      // Test start date picker
      await tester.tap(find.text(eventPageState.timeFormatter.format(initialDay)).first);
      dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 15, 6);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Limitation of timepicker: this is the only way to tap a number (from the docs)
      var center = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      await tester.tapAt(Offset(center.dx, center.dy + 10)); // +10 picks 6

      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.timeFormatter.format(dayToSet)), findsOneWidget);
    });

    testWidgets('Test end time picker', (tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(eventPageMaterialApp!);
      final EventPageState eventPageState = tester.state(find.byType(EventPage));
      DateTime dayToSet;
      // Test start date picker
      await tester.tap(find.text(eventPageState.timeFormatter.format(initialDay.add(const Duration(hours: 1)))).first);
      dayToSet = DateTime(DateTime.now().year, DateTime.now().month, 15, 9);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Limitation of timepicker: this is the only way to tap a number (from the docs)
      var center = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      await tester.tapAt(Offset(center.dx - 10, center.dy)); // -10 picks 9

      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(eventPageState.timeFormatter.format(dayToSet)), findsOneWidget);
    });
  });
}
