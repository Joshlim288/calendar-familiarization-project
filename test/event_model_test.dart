import 'package:flutter_test/flutter_test.dart';
import 'package:temp/event_model.dart';

import 'test_utils.dart';

void main() {
  test('Test toString', () {
    expect(testEvent.toString() == testEvent.eventKey, true);
  });

  test('Test compareTo', () {
    // initialize new testing event for testing event comparison
    final Event compareTestEvent = Event(
      endTime: DateTime.now(),
      comment: 'Test compareTo comment',
      name: 'Test compareTo event',
      fullDay: true,
      eventKey: 'TestKey',
      startTime: DateTime.now(),
    );

    expect(compareTestEvent == testEvent, true);
    compareTestEvent.eventKey = 'TestNotEqualKey';
    expect(compareTestEvent == testEvent, false);
  });

  test('Test hashCode', () {
    expect(testEvent.hashCode == 'TestKey'.hashCode, true);
  });
}
