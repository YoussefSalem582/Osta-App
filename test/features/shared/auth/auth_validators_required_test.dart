import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';

void main() {
  late BuildContext ctx;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  testWidgets('rejects whitespace-only input', (tester) async {
    await pump(tester);
    // The inline validators this replaced tested `value.isEmpty`, so a field
    // holding only spaces passed. requiredField trims first.
    expect(AuthValidators.requiredField(ctx, '   '), isNotNull);
    expect(AuthValidators.requiredField(ctx, ''), isNotNull);
    expect(AuthValidators.requiredField(ctx, null), isNotNull);
  });

  testWidgets('accepts real input', (tester) async {
    await pump(tester);
    expect(AuthValidators.requiredField(ctx, 'Toyota'), isNull);
    expect(AuthValidators.requiredField(ctx, '  Toyota  '), isNull);
  });

  testWidgets('message overrides the generic required text', (tester) async {
    await pump(tester);
    expect(
      AuthValidators.requiredField(ctx, '', message: 'Enter the brand'),
      'Enter the brand',
    );
    // Without an override the shared localized string still wins.
    expect(AuthValidators.requiredField(ctx, ''), isNot('Enter the brand'));
    // An override must not turn a valid value invalid.
    expect(
      AuthValidators.requiredField(ctx, 'Toyota', message: 'Enter the brand'),
      isNull,
    );
  });
}
