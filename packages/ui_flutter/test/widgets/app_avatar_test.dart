import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ui/app_ui.dart';

Widget _wrap(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    );

void main() {
  group('AppAvatar initials algorithm', () {
    testWidgets('Latin two-word name → two uppercase initials', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: 'John Doe')));
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('Cyrillic two-word name → two uppercase initials', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: 'Иван Петров')));
      expect(find.text('ИП'), findsOneWidget);
    });

    testWidgets('single-word name → one initial', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: 'Zara')));
      expect(find.text('Z'), findsOneWidget);
    });

    testWidgets('empty name → ?', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: '')));
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('three-word name uses only first two words', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: 'Abu Ali Hassan')));
      expect(find.text('AA'), findsOneWidget);
    });
  });

  group('AppAvatar sizes', () {
    for (final size in AppAvatarSize.values) {
      testWidgets('renders size $size', (tester) async {
        await tester.pumpWidget(_wrap(AppAvatar(name: 'T', size: size)));
        expect(find.byType(AppAvatar), findsOneWidget);
      });
    }
  });

  group('AppAvatar tones', () {
    for (final tone in AppAvatarTone.values) {
      testWidgets('renders tone $tone', (tester) async {
        await tester.pumpWidget(_wrap(AppAvatar(name: 'T', tone: tone)));
        expect(find.byType(AppAvatar), findsOneWidget);
      });
    }
  });

  group('AppAvatar shapes', () {
    testWidgets('renders circle shape', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: 'T', shape: AppAvatarShape.circle)));
      expect(find.byType(AppAvatar), findsOneWidget);
    });

    testWidgets('renders square shape', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: 'T', shape: AppAvatarShape.square)));
      expect(find.byType(AppAvatar), findsOneWidget);
    });
  });
}
