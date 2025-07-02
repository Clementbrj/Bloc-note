import 'package:flutter_test/flutter_test.dart';
import 'package:test/app.dart'; // chemin vers MyApp

void main() {
  testWidgets('MyApp test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('Hello'), findsOneWidget);
  });
}
