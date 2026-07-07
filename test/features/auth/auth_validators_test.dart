import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/features/auth/presentation/auth_validators.dart';

/// Pumps a minimal localized tree and hands back a live [BuildContext] so the
/// context-based validators can resolve their `l10n` error strings.
Future<BuildContext> _context(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  group('AuthValidators', () {
    testWidgets('email rejects malformed input, accepts a valid address', (
      tester,
    ) async {
      final context = await _context(tester);
      expect(AuthValidators.email(context, ''), isNotNull);
      expect(AuthValidators.email(context, 'nope'), isNotNull);
      expect(AuthValidators.email(context, 'a@b.com'), isNull);
    });

    testWidgets('password enforces strength only when asked', (tester) async {
      final context = await _context(tester);
      expect(AuthValidators.password(context, 'short'), isNotNull);
      expect(AuthValidators.password(context, 'longenough'), isNull);
      expect(
        AuthValidators.password(context, 'short', enforceStrength: false),
        isNull,
      );
      expect(
        AuthValidators.password(context, '', enforceStrength: false),
        isNotNull,
      );
    });

    testWidgets('confirm matches the original password', (tester) async {
      final context = await _context(tester);
      expect(AuthValidators.confirm(context, 'abc', 'abc'), isNull);
      expect(AuthValidators.confirm(context, 'abc', 'xyz'), isNotNull);
    });

    testWidgets('egyptPhone accepts a valid mobile, rejects junk', (
      tester,
    ) async {
      final context = await _context(tester);
      expect(AuthValidators.egyptPhone(context, '1012345678'), isNull);
      // A leading 0 is tolerated.
      expect(AuthValidators.egyptPhone(context, '01012345678'), isNull);
      expect(AuthValidators.egyptPhone(context, ''), isNotNull);
      expect(AuthValidators.egyptPhone(context, '123'), isNotNull);
      // Must start with 1.
      expect(AuthValidators.egyptPhone(context, '2012345678'), isNotNull);
    });
  });

  test('normalizeEgyptPhone strips a leading zero to E.164', () {
    expect(AuthValidators.normalizeEgyptPhone('1012345678'), '+201012345678');
    expect(AuthValidators.normalizeEgyptPhone('01012345678'), '+201012345678');
    expect(AuthValidators.normalizeEgyptPhone('101 234 5678'), '+201012345678');
  });
}
