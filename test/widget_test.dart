import 'package:flutter_test/flutter_test.dart';
import 'package:stick_adventure/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StickAdventureApp());
    expect(find.text('Stick Adventure'), findsOneWidget);
  });
}
