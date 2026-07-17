import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_state.dart';
import 'package:osta/core/theme/app_theme.dart';
import 'package:osta/features/shared/auth/domain/auth_repository.dart';
import 'package:osta/features/shared/auth/presentation/register/bloc/register_bloc.dart';
import 'package:osta/features/shared/auth/presentation/register/pages/business_register_page.dart';
import 'package:osta/features/shared/auth/presentation/register/pages/customer_register_page.dart';
import 'package:osta/features/shared/auth/presentation/register/widgets/register_form.dart';

/// RegisterBloc only reads `state.activeRole` off the session.
class _StubSession extends Cubit<SessionState> implements SessionController {
  _StubSession(AppRole role) : super(SessionState(activeRole: role));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('not exercised here');
}

void main() {
  void register(AppRole role) {
    getIt
      ..registerFactory<RegisterBloc>(
        () => RegisterBloc(_StubAuthRepository(), _StubSession(role)),
      )
      ..registerSingleton<SessionController>(_StubSession(role));
  }

  tearDown(getIt.reset);

  Future<AppLocalizations> pump(
    WidgetTester tester,
    Widget page,
    AppRole role,
  ) async {
    register(role);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: page,
      ),
    );
    await tester.pump();
    return AppLocalizations.of(tester.element(find.byType(RegisterForm)));
  }

  testWidgets('customer register shows the customer heading', (tester) async {
    final l10n = await pump(
      tester,
      const CustomerRegisterPage(),
      AppRole.customer,
    );
    expect(find.text(l10n.authRegisterTitleCustomer), findsOneWidget);
    expect(find.text(l10n.authRegisterTitleBusiness), findsNothing);
  });

  testWidgets('business register shows the business heading', (tester) async {
    final l10n = await pump(
      tester,
      const BusinessRegisterPage(),
      AppRole.business,
    );
    expect(find.text(l10n.authRegisterTitleBusiness), findsOneWidget);
    expect(find.text(l10n.authRegisterTitleCustomer), findsNothing);
  });

  testWidgets('both render one shared form, not forked field lists', (
    tester,
  ) async {
    // The point of the split: two screens, one form. If these counts ever
    // disagree the fields have been forked and the duplication is back.
    await pump(tester, const CustomerRegisterPage(), AppRole.customer);
    expect(find.byType(RegisterForm), findsOneWidget);
    final customerFields = find.byType(TextFormField).evaluate().length;
    await tester.pumpWidget(const SizedBox.shrink());
    await getIt.reset();

    await pump(tester, const BusinessRegisterPage(), AppRole.business);
    expect(find.byType(RegisterForm), findsOneWidget);
    final businessFields = find.byType(TextFormField).evaluate().length;

    expect(customerFields, greaterThan(0));
    expect(customerFields, businessFields);
  });

  testWidgets('the two pages route to different paths', (tester) async {
    expect(CustomerRegisterPage.path, isNot(BusinessRegisterPage.path));
  });
}
