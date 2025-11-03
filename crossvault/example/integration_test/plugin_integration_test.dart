// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing


import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:crossvault/crossvault.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('setValue and getValue test', (WidgetTester tester) async {
    final Crossvault plugin = Crossvault();
    
    const testKey = 'test_key';
    const testValue = 'test_value';
    
    // Set a value
    await plugin.setValue(testKey, testValue);
    
    // Get the value back
    final retrievedValue = await plugin.getValue(testKey);
    
    // Verify the value matches
    expect(retrievedValue, testValue);
    
    // Check if key exists
    final exists = await plugin.existsKey(testKey);
    expect(exists, true);
    
    // Delete the value
    await plugin.deleteValue(testKey);
    
    // Verify it's deleted
    final existsAfterDelete = await plugin.existsKey(testKey);
    expect(existsAfterDelete, false);
  });
}
