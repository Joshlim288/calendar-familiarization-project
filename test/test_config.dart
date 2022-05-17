import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

// enter size of the testing device, can get by using MediaQuery.of(context).size
void setScreenSize(WidgetTester tester) {
  const double screenWidth = 392.7;
  const double screenHeight = 802.9;
  final TestViewConfiguration viewConfig = TestViewConfiguration(size: const Size(screenWidth, screenHeight));
  WidgetsBinding.instance?.renderView.configuration = viewConfig;
}
