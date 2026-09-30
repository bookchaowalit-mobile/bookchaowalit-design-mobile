import 'package:design/main.dart';
import 'package:design/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell shows palette and about tab', (tester) async {
    await tester.pumpWidget(const DesignApp());
    expect(find.text('Design'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('entering a colour updates contrast and errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.enterText(find.byKey(const Key('hex-input')), '#000');
    await tester.pump();
    expect(find.text('vs white: 21.00:1'), findsOneWidget);
    expect(find.text('Normal text: AAA'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('hex-input')), 'nope');
    await tester.pump();
    expect(find.text('Enter a colour like #1E88E5'), findsOneWidget);
    expect(find.textContaining('vs white'), findsNothing);
  });
}
