// This code enables the integration test driver and then waits for the test to run.
// The response data (if any) is stored in a file named integration_response_data.json after the tests are run.
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
