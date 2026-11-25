import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raumschach/main.dart';

Finder boardCell(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
    description: 'board cell "$label"',
  );
}

void main() {
  testWidgets('New Game lets White move the Ba2 pawn to Ca2', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MainApp());
    await tester.tap(find.text('New Game'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    expect(find.text('White to move'), findsOneWidget);
    final pawn = boardCell('Ba2, white pawn');
    expect(pawn, findsOneWidget);
    expect(boardCell('Ca2'), findsOneWidget);

    await tester.ensureVisible(pawn);
    await tester.tap(pawn);
    await tester.pumpAndSettle();

    final destination = boardCell('Ca2, legal destination');
    expect(destination, findsOneWidget);
    await tester.ensureVisible(destination);
    await tester.tap(destination);
    await tester.pumpAndSettle();

    expect(boardCell('Ba2'), findsOneWidget);
    expect(boardCell('Ca2, white pawn'), findsOneWidget);
    expect(destination, findsNothing);
    expect(find.text('Black to move'), findsOneWidget);
  });
}
