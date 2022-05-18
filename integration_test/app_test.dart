import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:integration_test/integration_test.dart';
import 'package:temp/calendar_page.dart';
import 'package:temp/event_model.dart';
import 'package:temp/main.dart';

// run with: `flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart --profile`
// requires an emulator/device on API > 31 (android 12)
void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
  Box<Event>? mockHiveBox = null;
  // fullyLive: best for heavily-animated situations
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  setUp(() async {
    await Hive.initFlutter();
    final Directory applicationDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(applicationDocumentDir.path);
    Hive.registerAdapter(EventAdapter());
    mockHiveBox = await Hive.openBox<Event>('MockEvents'); // do not touch real data
  });

  group('Testing navigation', () {
    testWidgets('Testing for navigating to calendar page', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(eventBox: mockHiveBox!));
      final Finder locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });
  });
}
