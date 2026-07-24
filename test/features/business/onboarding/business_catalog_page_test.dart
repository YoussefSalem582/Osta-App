import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/core/theme/app_theme.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/business/onboarding/data/models/catalog_preset.dart';
import 'package:osta/features/business/onboarding/data/models/custom_service_input.dart';
import 'package:osta/features/business/onboarding/domain/business_onboarding_repository.dart';
import 'package:osta/features/business/onboarding/presentation/catalog/business_catalog_page.dart';
import 'package:osta/features/business/onboarding/presentation/catalog/widgets/service_toggle_card.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_onboarding_cubit.dart';

/// Drives the real catalog page through its full build with the real cubit —
/// the changed footer (count label + review gate) and the add-all card exercise
/// the same code path a merchant hits, minus the map-bearing identity step.
const _oil = CatalogPreset(
  id: 'p1',
  category: 'oil',
  name: 'Oil change',
  defaultPrice: 350,
  defaultDurationMinutes: 30,
  categoryLabel: 'Oils',
);
const _brakes = CatalogPreset(
  id: 'p2',
  category: 'brakes',
  name: 'Brake pads',
  defaultPrice: 250,
  defaultDurationMinutes: 60,
  categoryLabel: 'Brakes',
);

class _FakeRepo implements BusinessOnboardingRepository {
  int attachCalls = 0;

  @override
  Future<List<CatalogPreset>> fetchPresets() async => const [_oil, _brakes];

  @override
  Future<void> attachCatalog(List<String> presetIds) async => attachCalls++;

  @override
  Future<void> createCustomService(CustomServiceInput input) async {}

  @override
  Future<void> updateProfile(BusinessProfileInput input) async {}

  @override
  Future<BusinessProfile> fetchProfile() => throw UnimplementedError();
}

class _FakeStore implements SessionStore {
  @override
  String? get businessDraft => null;
  @override
  Future<void> writeBusinessDraft(String json) async {}
  @override
  Future<void> clearBusinessDraft() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeRepo repo;
  late BusinessOnboardingCubit cubit;

  Future<AppLocalizations> pump(WidgetTester tester) async {
    repo = _FakeRepo();
    cubit = BusinessOnboardingCubit(repo, _FakeStore());
    await tester.pumpWidget(
      BlocProvider<BusinessOnboardingCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BusinessCatalogPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(const Locale('en'));
  }

  testWidgets('renders presets and gates activate until one is picked', (
    tester,
  ) async {
    final l10n = await pump(tester);

    expect(find.text('Oil change'), findsOneWidget);
    expect(find.text('Brake pads'), findsOneWidget);
    // Nothing selected yet: the hint shows, no count on the button.
    expect(find.text(l10n.businessCatalogSelectAtLeastOne), findsOneWidget);
    expect(find.text(l10n.businessCatalogAddCommonTitle(2)), findsOneWidget);

    await tester.tap(find.widgetWithText(ServiceToggleCard, 'Oil change'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.businessCatalogActivateWithCount(1)), findsOneWidget);
    expect(cubit.state.selectedServiceCount, 1);
  });

  testWidgets('activate opens the review sheet and only commits on confirm', (
    tester,
  ) async {
    final l10n = await pump(tester);
    await tester.tap(find.widgetWithText(ServiceToggleCard, 'Oil change'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.businessCatalogActivateWithCount(1)));
    await tester.pumpAndSettle();

    // The sheet is up; backing out must not activate.
    expect(find.text(l10n.businessCatalogReviewTitle), findsOneWidget);
    await tester.tap(find.text(l10n.businessCatalogReviewCancel));
    await tester.pumpAndSettle();
    expect(repo.attachCalls, 0);

    // Confirm this time → the catalog is posted.
    await tester.tap(find.text(l10n.businessCatalogActivateWithCount(1)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.businessCatalogReviewConfirm));
    await tester.pumpAndSettle();
    expect(repo.attachCalls, 1);
  });
}
