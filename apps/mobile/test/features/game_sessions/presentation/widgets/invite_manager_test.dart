import 'package:coriolis_companion/features/game_sessions/presentation/widgets/invite_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Generate CTA in none state', (tester) async {
    var generated = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InviteManagerWidget(
          state: InviteState.none,
          rotatedAt: null,
          revealUrl: null,
          onGenerate: () => generated = true,
          onRotate: () {},
          onRevoke: () {},
          onCopy: () {},
          onCloseReveal: () {},
        ),
      ),
    ));
    expect(find.text('Generate invite link'), findsOneWidget);
    await tester.tap(find.text('Generate invite link'));
    expect(generated, isTrue);
  });

  testWidgets('renders active state actions', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InviteManagerWidget(
          state: InviteState.active,
          rotatedAt: DateTime.utc(2026, 5, 15, 10, 0),
          revealUrl: null,
          onGenerate: () {},
          onRotate: () {},
          onRevoke: () {},
          onCopy: () {},
          onCloseReveal: () {},
        ),
      ),
    ));
    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Rotate'), findsOneWidget);
    expect(find.text('Revoke'), findsOneWidget);
  });

  testWidgets('reveal body shows the URL and close button', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InviteManagerWidget(
          state: InviteState.justGenerated,
          rotatedAt: null,
          revealUrl: 'https://app/join/X',
          onGenerate: () {},
          onRotate: () {},
          onRevoke: () {},
          onCopy: () {},
          onCloseReveal: () {},
        ),
      ),
    ));
    expect(find.text('Your new invite link'), findsOneWidget);
    expect(find.text('https://app/join/X'), findsOneWidget);
    expect(find.text("I've copied it — close"), findsOneWidget);
  });
}
