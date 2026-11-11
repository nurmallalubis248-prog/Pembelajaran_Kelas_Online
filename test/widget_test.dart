import 'package:flutter_test/flutter_test.dart';
import 'package:pembelajaran_kelas_online/main.dart';
import 'package:pembelajaran_kelas_online/widgets/nexa_logo.dart';

void main() {
  testWidgets('App smoke test renders NexaLogo', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(NexaLogo), findsOneWidget);
  });
}
