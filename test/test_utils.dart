import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temp/event_model.dart';

/// Helper file for methods and properties used in multiple test files

/// Properties
// Common event for testing reads
final Event testEvent = Event(
  comment: 'Test comment',
  fullDay: false,
  startTime: DateTime.now(),
  endTime: DateTime.now().add(const Duration(hours: 1)),
  name: 'Test Event',
  eventKey: 'TestKey',
);

/// Methods
// enter size of the testing device, can get by using MediaQuery.of(context).size
void setScreenSize(WidgetTester tester) {
  const double screenWidth = 392.7;
  const double screenHeight = 802.9;
  final TestViewConfiguration viewConfig = TestViewConfiguration(size: const Size(screenWidth, screenHeight));
  WidgetsBinding.instance?.renderView.configuration = viewConfig;
}
