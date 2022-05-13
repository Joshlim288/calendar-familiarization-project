import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:temp/calendar_page.dart';
import 'package:temp/event_model.dart';

// TODO figure out how to properly mock Hive stuff
// Run all tests with `flutter test`
void main() {
  Widget? calendarPage = null;
  Box<Event> mockHiveBox;
  setUp(() async {
    await Hive.initFlutter();
    final Directory applicationDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(applicationDocumentDir.path);
    Hive.registerAdapter(EventAdapter());
    mockHiveBox = await Hive.openBox<Event>('MockEvents'); // do not touch real data
    // creating the CalendarPage widget with 'mock' box
    calendarPage = MediaQuery(data: MediaQueryData(), child: MaterialApp(home: CalendarPage(box: mockHiveBox)));
  });
  group('Testing calendar widget', () {
    testWidgets('Check today highlighted', (tester) async {
      await tester.pumpWidget(calendarPage!);
      final String day = DateTime.now().day.toString(); // tap next day. If last day, tap first day
      final Text dayText = tester.widget<Text>(find.text(day));
      await tester.pumpAndSettle();
      expect(dayText.style?.color, const Color(0xfffafafa)); // check day is white (selected)
    });
  });
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:testing_app/models/favorites.dart';
import 'package:testing_app/screens/home.dart';

// follows widget build method in main.dart -> where the page is created
Widget createHomeScreen() => ChangeNotifierProvider<Favorites>(
    create: (context) => Favorites(),
    child: MaterialApp(
      home: HomePage(),
    ));

void main() {
  group('Home Page Widget Tests', () {
    testWidgets('Testing if ListView shows up', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Testing Scrolling', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.text('Item 0'), findsOneWidget);
      await tester.fling(find.byType(ListView), Offset(0, -200), 3000);
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('Testing IconButtons', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.byIcon(Icons.favorite), findsNothing);
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Added to favorites.'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsWidgets);
      await tester.tap(find.byIcon(Icons.favorite).first);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Removed from favorites.'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });
  });
}
import 'package:test/test.dart';
import 'package:testing_app/models/favorites.dart';

void main() {
  group('Testing App provider', () {
    var favorites = Favorites();

    test('A new item should be added', () {
      var number = 35;
      favorites.add(number);
      expect(favorites.items.contains(number), true);
    });

    test('An item should be removed', () {
      var number = 45;
      favorites.add(number);
      expect(favorites.items.contains(number), true);
      favorites.remove(number);
      expect(favorites.items.contains(number), false);
    });
  });
}

 */
