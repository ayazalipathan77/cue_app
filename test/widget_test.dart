import 'package:flutter_test/flutter_test.dart';

import 'package:cue_app/main.dart';

void main() {
  testWidgets('App launches and shows role select screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CueApp());
    await tester.pumpAndSettle();

    // RoleSelectScreen should show Sender and Receiver options
    expect(find.text('Sender'), findsOneWidget);
    expect(find.text('Receiver'), findsOneWidget);
  });
}
