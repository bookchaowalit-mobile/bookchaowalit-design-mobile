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

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const HomeScreen(),
        ),
      );

  testWidgets('near-threshold ratio is not shown as passing', (tester) async {
    await tester.pumpWidget(home());
    await tester.enterText(find.byKey(const Key('hex-input')), '#003AFB');
    await tester.pump();
    expect(find.text('vs black: 2.99:1'), findsOneWidget);
    expect(find.text('vs black: 3.00:1'), findsNothing);
  });

  testWidgets('three-digit and hashless input render the full scale', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    await tester.enterText(find.byKey(const Key('hex-input')), 'f80');
    await tester.pump();
    expect(find.text('500  #FF8800'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('900  #'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('900  #'), findsOneWidget);
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('lays out at 200% text scale without overflow', (tester) async {
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
