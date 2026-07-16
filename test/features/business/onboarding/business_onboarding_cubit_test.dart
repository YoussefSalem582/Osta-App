import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/business/onboarding/data/models/catalog_preset.dart';
import 'package:osta/features/business/onboarding/data/models/custom_service_input.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_onboarding_cubit.dart';

const _oil = CatalogPreset(
  id: 'p1',
  category: 'oil',
  name: 'Oil Change',
  defaultPrice: 350,
  defaultDurationMinutes: 30,
  categoryLabel: 'Oils',
);

const _brakes = CatalogPreset(
  id: 'p2',
  category: 'brakes',
  name: 'Brake Pads',
  defaultPrice: 250,
  defaultDurationMinutes: 60,
);

class _FakeRepo implements BusinessOnboardingRepository {
  _FakeRepo({
    this.profileError,
    this.catalogError,
    this.presetsError,
  });

  final List<CatalogPreset> presets = const [_oil, _brakes];
  final Exception? profileError;
  final Exception? catalogError;
  final Exception? presetsError;

  BusinessProfileInput? lastProfile;
  List<String>? lastCatalogIds;
  int attachCalls = 0;
  final List<CustomServiceInput> createdServices = [];

  @override
  Future<void> updateProfile(BusinessProfileInput input) async {
    lastProfile = input;
    if (profileError != null) throw profileError!;
  }

  @override
  Future<List<CatalogPreset>> fetchPresets() async {
    if (presetsError != null) throw presetsError!;
    return presets;
  }

  @override
  Future<void> attachCatalog(List<String> presetIds) async {
    attachCalls++;
    lastCatalogIds = presetIds;
    if (catalogError != null) throw catalogError!;
  }

  @override
  Future<void> createCustomService(CustomServiceInput input) async =>
      createdServices.add(input);
}

/// The cubit only touches the draft accessors.
class _FakeStore implements SessionStore {
  String? draft;

  @override
  String? get businessDraft => draft;

  @override
  Future<void> writeBusinessDraft(String json) async => draft = json;

  @override
  Future<void> clearBusinessDraft() async => draft = null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('BusinessOnboardingCubit', () {
    BusinessOnboardingCubit build([_FakeRepo? repo, _FakeStore? store]) =>
        BusinessOnboardingCubit(repo ?? _FakeRepo(), store ?? _FakeStore());

    test('loadPresets populates without selecting anything', () async {
      // #53: the merchant must actively add ≥1 service. Pre-selecting them all
      // made canActivate true on arrival, so the guard never fired.
      final cubit = build();
      await cubit.loadPresets();

      expect(cubit.state.presets, hasLength(2));
      expect(cubit.state.selectedPresetIds, isEmpty);
      expect(cubit.state.canActivate, isFalse);
      expect(cubit.state.status, BusinessOnboardingStatus.idle);
      await cubit.close();
    });

    test('togglePreset selects and deselects', () async {
      final cubit = build();
      await cubit.loadPresets();

      cubit.togglePreset(_oil.id);
      expect(cubit.state.selectedPresetIds.contains(_oil.id), isTrue);
      cubit.togglePreset(_oil.id);
      expect(cubit.state.selectedPresetIds.contains(_oil.id), isFalse);
      await cubit.close();
    });

    test('selectAllPresets is still the one-tap path', () async {
      final cubit = build();
      await cubit.loadPresets();
      cubit.selectAllPresets();

      expect(cubit.state.selectedPresetIds, {_oil.id, _brakes.id});
      expect(cubit.state.canActivate, isTrue);
      await cubit.close();
    });

    test('activate is a no-op with an empty catalog', () async {
      final repo = _FakeRepo();
      final cubit = build(repo);
      await cubit.loadPresets();

      await cubit.activate();
      expect(repo.attachCalls, 0);
      expect(cubit.state.status, isNot(BusinessOnboardingStatus.activated));
      await cubit.close();
    });

    test('activate posts selected ids and emits activated', () async {
      final repo = _FakeRepo();
      final cubit = build(repo);
      await cubit.loadPresets();
      cubit.togglePreset(_oil.id);

      await cubit.activate();
      expect(repo.attachCalls, 1);
      expect(repo.lastCatalogIds, [_oil.id]);
      expect(cubit.state.status, BusinessOnboardingStatus.activated);
      await cubit.close();
    });

    test('a custom service alone satisfies the catalog requirement', () async {
      // The catalog endpoint takes preset ids only, so a merchant with nothing
      // but custom services must still be able to finish — and posting an empty
      // `items` would 422 on `required|min:1`.
      final repo = _FakeRepo();
      final cubit = build(repo);
      await cubit.loadPresets();
      cubit.addCustomService(
        const CustomServiceInput(name: 'Ceramic coating', price: 1200),
      );

      expect(cubit.state.canActivate, isTrue);
      await cubit.activate();

      expect(repo.attachCalls, 0, reason: 'no presets selected → no /catalog');
      expect(repo.createdServices.single.name, 'Ceramic coating');
      expect(cubit.state.status, BusinessOnboardingStatus.activated);
      await cubit.close();
    });

    test('activate posts presets and custom services together', () async {
      final repo = _FakeRepo();
      final cubit = build(repo);
      await cubit.loadPresets();
      cubit
        ..togglePreset(_brakes.id)
        ..addCustomService(
          const CustomServiceInput(
            name: 'Wheel alignment',
            price: 400,
            durationMinutes: 45,
          ),
        );

      await cubit.activate();
      expect(repo.lastCatalogIds, [_brakes.id]);
      expect(repo.createdServices, hasLength(1));
      expect(cubit.state.status, BusinessOnboardingStatus.activated);
      await cubit.close();
    });

    test('removeCustomService drops the staged service', () async {
      final cubit = build()
        ..addCustomService(
          const CustomServiceInput(name: 'Detailing', price: 500),
        );
      expect(cubit.state.customServices, hasLength(1));
      cubit.removeCustomService(0);
      expect(cubit.state.customServices, isEmpty);
      await cubit.close();
    });

    test('submitProfile maps 422 field errors', () async {
      final repo = _FakeRepo(
        profileError: const ValidationException('bad', {
          'phone': ['Invalid phone'],
        }),
      );
      final cubit = build(repo)
        ..updateTradeName('Cairo Motors')
        ..updatePhone('1012345678')
        ..setLocation((lat: 30.0, lng: 31.0));

      await cubit.submitProfile();
      expect(cubit.state.status, BusinessOnboardingStatus.failure);
      expect(cubit.state.fieldErrors['phone']?.first, 'Invalid phone');
      await cubit.close();
    });

    test('submitProfile normalizes phone and sends profile', () async {
      final repo = _FakeRepo();
      final cubit = build(repo)
        ..updateTradeName('Cairo Motors')
        ..updatePhone('01012345678')
        ..setLocation((lat: 30.04, lng: 31.23));

      await cubit.submitProfile();
      expect(cubit.state.status, BusinessOnboardingStatus.profileSubmitted);
      expect(repo.lastProfile?.tradeName, 'Cairo Motors');
      expect(repo.lastProfile?.phone, '+201012345678');
      expect(repo.lastProfile?.latitude, 30.04);
      await cubit.close();
    });

    test('category filter narrows filteredPresets', () async {
      final cubit = build();
      await cubit.loadPresets();
      cubit.setCategoryFilter('oil');
      expect(cubit.state.filteredPresets, [_oil]);
      await cubit.close();
    });

    test('loadPresets surfaces network errors', () async {
      final cubit = build(_FakeRepo(presetsError: const NetworkException()));
      await cubit.loadPresets();
      expect(cubit.state.networkError, isTrue);
      expect(cubit.state.status, BusinessOnboardingStatus.failure);
      await cubit.close();
    });

    test('activate surfaces catalog validation errors', () async {
      final cubit = build(
        _FakeRepo(
          catalogError: const ValidationException('empty', {
            'items': ['At least one service is required'],
          }),
        ),
      );
      await cubit.loadPresets();
      cubit.togglePreset(_oil.id);
      await cubit.activate();
      expect(cubit.state.status, BusinessOnboardingStatus.failure);
      expect(cubit.state.fieldErrors['items']?.first, contains('required'));
      await cubit.close();
    });
  });

  group('BusinessOnboardingCubit — draft persistence (#53)', () {
    test('restores a persisted draft on construction', () async {
      final store = _FakeStore();
      final first = BusinessOnboardingCubit(_FakeRepo(), store)
        ..updateTradeName('Cairo Motors')
        ..updatePhone('01012345678')
        ..updateYearFounded(1998)
        ..addCustomService(
          const CustomServiceInput(name: 'Detailing', price: 500),
        );
      await first.close();

      // The wizard is mandatory, so a cold start mid-setup must not drop the
      // merchant back at an empty step 1.
      final restored = BusinessOnboardingCubit(_FakeRepo(), store);
      expect(restored.state.tradeName, 'Cairo Motors');
      expect(restored.state.phone, '01012345678');
      expect(restored.state.yearFounded, 1998);
      expect(restored.state.customServices.single.name, 'Detailing');
      await restored.close();
    });

    test(
      'a corrupt draft yields a blank wizard rather than throwing',
      () async {
        final store = _FakeStore()..draft = '{not json';
        final cubit = BusinessOnboardingCubit(_FakeRepo(), store);
        expect(cubit.state.tradeName, isEmpty);
        await cubit.close();
      },
    );

    test('activate clears the draft', () async {
      final store = _FakeStore();
      final cubit = BusinessOnboardingCubit(_FakeRepo(), store);
      await cubit.loadPresets();
      cubit
        ..updateTradeName('Cairo Motors')
        ..togglePreset(_oil.id);
      await cubit.activate();

      expect(store.draft, isNull);
      await cubit.close();
    });

    test('the logo path is never persisted', () async {
      // It is an image_picker cache path; the OS may reap it between launches,
      // so a restored one can dangle.
      final store = _FakeStore();
      final cubit = BusinessOnboardingCubit(_FakeRepo(), store)
        ..setLogoPath('/tmp/cache/logo.png');
      await cubit.close();

      expect(store.draft, isNot(contains('logo')));
      final restored = BusinessOnboardingCubit(_FakeRepo(), store);
      expect(restored.state.logoPath, isNull);
      await restored.close();
    });
  });
}
