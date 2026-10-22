import 'package:flutter_google_places_plus/flutter_google_places_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FlutterGooglePlacesPlus instantiation and validation test', (WidgetTester tester) async {
    final client = FlutterGooglePlacesPlus();
    expect(client.isInitialized, isFalse);

    // Empty API key throws INVALID_ARGUMENT
    expect(
      () => client.initialize(apiKey: ''),
      throwsA(isA<PlacesException>().having((e) => e.code, 'code', 'INVALID_ARGUMENT')),
    );

    // Session token generation works
    final token = client.newSessionToken();
    expect(token.value, isNotEmpty);
  });
}
