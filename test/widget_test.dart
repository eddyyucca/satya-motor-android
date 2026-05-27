import 'package:flutter_test/flutter_test.dart';
import 'package:satya_motor/main.dart';

void main() {
  testWidgets('App should launch', (WidgetTester tester) async {
    await tester.pumpWidget(const SatyaMotorApp());
    expect(find.text('Satya Motor'), findsOneWidget);
  });
}
